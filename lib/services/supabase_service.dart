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
      // Profil mungkin belum ada
      return null;
    }
  }

  // Fungsi untuk memperbarui profil user
  Future<void> updateUserProfile({
    required String name,
    required String gender,
    String? birthDate,
    String? bio,
    required bool hasTreatment,
    DateTime? treatmentStartDate,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    try {
      await _supabase.from('profiles').update({
        'full_name': name,
        'gender': gender,
        if (birthDate != null) 'birth_date': birthDate,
        if (bio != null) 'bio': bio,
        'has_treatment': hasTreatment,
        'treatment_start_date': treatmentStartDate?.toIso8601String(),
      }).eq('id', user.id);
    } catch (e) {
      throw Exception('Gagal memperbarui profil: $e');
    }
  }
  // Fungsi untuk menyimpan pengingat obat
  Future<void> saveMedicationReminder({
    required String name,
    required String dosage,
    required String time, // format HH:MM
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    try {
      await _supabase.from('medication_reminders').insert({
        'user_id': user.id,
        'medication_name': name,
        'dosage': dosage,
        'time_to_take': '$time:00', // Supabase time format
      });
    } catch (e) {
      throw Exception('Gagal menyimpan pengingat: $e');
    }
  }
}
