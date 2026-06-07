import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // Fungsi untuk menyimpan hasil skrining
  Future<void> saveScreeningResult({
    required int score,
    required String status,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    try {
      await _supabase.from('screening_results').insert({
        'user_id': user.id,
        'score': score,
        'status': status,
      });
    } catch (e) {
      throw Exception('Gagal menyimpan hasil skrining: $e');
    }
  }
  
  // Update medication adherence target days for the user
  Future<void> updateMedicationTarget(int days) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User belum login');

    try {
      final updated = await _supabase.from('profiles').update({
        'medication_target_days': days,
      }).eq('id', user.id).select();
      
      if (updated.isEmpty) {
        throw Exception('Gagal memperbarui database. Pastikan kebijakan RLS (Row Level Security) untuk UPDATE aktif di tabel "profiles" Anda.');
      }
    } catch (e) {
      throw Exception('Gagal memperbarui target obat: $e');
    }
  }

  // Helper to convert UUID String to a positive 60-bit integer (bigint)
  int uuidToBigInt(String uuid) {
    final clean = uuid.replaceAll('-', '');
    // Take 15 hex characters (60 bits) to avoid overflow on signed 64-bit int
    final hex = clean.substring(0, 15);
    return int.parse(hex, radix: 16);
  }

  // Log that user took medication (a confirmation entry)
  Future<void> logMedicationTaken({dynamic reminderId, DateTime? takenAt}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User belum login');

    try {
      dynamic dbReminderId = reminderId;
      if (reminderId is String && reminderId.contains('-')) {
        dbReminderId = uuidToBigInt(reminderId);
      }

      await _supabase.from('medication_logs').insert({
        'user_id': user.id,
        if (dbReminderId != null) 'reminder_id': dbReminderId,
        'taken_at': (takenAt ?? DateTime.now()).toIso8601String(),
      });
    } catch (e) {
      throw Exception('Gagal menyimpan log obat: $e');
    }
  }

  // Fetch logs taken on a specific date (local time)
  Future<List<Map<String, dynamic>>> getMedicationLogsForDate(DateTime date) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toIso8601String();

      final data = await _supabase
          .from('medication_logs')
          .select()
          .eq('user_id', user.id)
          .gte('taken_at', startOfDay)
          .lte('taken_at', endOfDay);
      
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      return [];
    }
  }

  // Compute adherence metrics: progressPercent, adherencePercent, daysLeft
  Future<Map<String, dynamic>> getAdherenceMetrics({int lookbackDays = 30}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User belum login');

    try {
      final profile = await getUserProfile();
      final int target = profile?['medication_target_days'] ?? 0;

      // fetch reminders count (expected doses per day)
      final rem = await _supabase.from('medication_reminders').select().eq('user_id', user.id);
      final int remindersPerDay = (rem as List?)?.length ?? 0;

      // fetch recent logs in window
      final since = DateTime.now().subtract(Duration(days: lookbackDays)).toIso8601String();
      final logsData = await _supabase
          .from('medication_logs')
          .select()
          .eq('user_id', user.id)
          .gte('taken_at', since);
      final List logs = logsData as List? ?? [];

      final int takenCount = logs.length;
      final int expectedDoses = remindersPerDay * lookbackDays;
      final adherencePercent = expectedDoses > 0 ? ((takenCount / expectedDoses) * 100).clamp(0, 100) : 0.0;

      // compute treatment days (if any)
      int treatmentDays = 0;
      if (profile != null && profile['has_treatment'] == true && profile['treatment_start_date'] != null) {
        try {
          final start = DateTime.parse(profile['treatment_start_date']);
          treatmentDays = DateTime.now().difference(start).inDays + 1;
          if (treatmentDays < 1) treatmentDays = 1;
          if (treatmentDays > target) treatmentDays = target;
        } catch (_) {}
      }

      final progressPercent = (target > 0) ? ( (treatmentDays / target) * 100 ).clamp(0, 100) : 0.0;
      final daysLeft = (target > 0) ? (target - treatmentDays) : 0;

      return {
        'adherencePercent': adherencePercent.round(),
        'progressPercent': progressPercent.round(),
        'daysLeft': daysLeft < 0 ? 0 : daysLeft,
      };
    } catch (e) {
      throw Exception('Gagal mengambil metrik kepatuhan: $e');
    }
  }

  // Fungsi untuk mengambil riwayat skrining
  Future<List<Map<String, dynamic>>> getScreeningHistory() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    try {
      final data = await _supabase
          .from('screening_results')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return data;
    } catch (e) {
      throw Exception('Gagal mengambil riwayat skrining: $e');
    }
  }

  // Fungsi untuk mendapatkan profil user
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return data;
    } catch (e) {
      print('DEBUG [SupabaseService]: Error in getUserProfile = $e');
      return null;
    }
  }

  // Fungsi untuk memperbarui profil user
  Future<void> updateUserProfile({
    String? email,
    required String name,
    required String gender,
    String? birthDate,
    String? bio,
    required bool hasTreatment,
    DateTime? treatmentStartDate,
    int? medicationTargetDays,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    try {
      // Update auth email first (if provided and different)
      if (email != null && email.isNotEmpty && email != user.email) {
        try {
          await _supabase.auth.updateUser(UserAttributes(email: email));
        } catch (e) {
          // Bubble up a descriptive error
          throw Exception('Gagal memperbarui email: $e');
        }
      }
      final updatedData = await _supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': name,
        'gender': gender,
        if (medicationTargetDays != null) 'medication_target_days': medicationTargetDays,
        if (birthDate != null) 'birth_date': birthDate,
        if (bio != null) 'bio': bio,
        'has_treatment': hasTreatment,
        'treatment_start_date': treatmentStartDate?.toIso8601String(),
      }).select();

      if (updatedData.isEmpty) {
        throw Exception('Gagal memperbarui database. Pastikan kebijakan RLS (Row Level Security) untuk INSERT dan UPDATE aktif di tabel "profiles" Anda.');
      }
    } catch (e) {
      throw Exception('Gagal memperbarui profil: $e');
    }
  }
  // Fungsi untuk menyimpan pengingat obat
  Future<Map<String, dynamic>?> saveMedicationReminder({
    required String name,
    required String dosage,
    required String time, // format HH:MM
    String? notes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    try {
      final String dosageWithNotes = notes != null && notes.trim().isNotEmpty
          ? '$dosage • ${notes.trim()}'
          : dosage;

      final inserted = await _supabase.from('medication_reminders').insert({
        'user_id': user.id,
        'medication_name': name,
        'dosage': dosageWithNotes,
        'time_to_take': '$time:00', // Supabase time format
      }).select().maybeSingle();

      if (inserted is Map<String, dynamic>) return inserted;
      return null;
    } catch (e) {
      throw Exception('Gagal menyimpan pengingat: $e');
    }
  }
}
