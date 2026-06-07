import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../widgets/home_medication_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onViewAllMedications;
  final bool isActive;
  const HomeScreen({Key? key, this.onViewAllMedications, this.isActive = false}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  bool _hasTreatment = false;
  int _treatmentDay = 0;
  int _treatmentTotal = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _medications = [];
  List<Map<String, dynamic>> _medicationLogs = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final metaName = user?.userMetadata?['full_name'] as String? ?? '';

      final profile = await SupabaseService().getUserProfile();
      print('DEBUG [HomeScreen]: profile fetched = $profile');
      print('DEBUG [HomeScreen]: user metadata name = $metaName');

      List<Map<String, dynamic>> meds = [];
      List<Map<String, dynamic>> logs = [];
      if (profile != null && profile['has_treatment'] == true) {
        try {
          final data = await Supabase.instance.client
              .from('medication_reminders')
              .select()
              .eq('user_id', user!.id)
              .order('time_to_take', ascending: true);
          meds = List<Map<String, dynamic>>.from(data);
          print('DEBUG [HomeScreen]: medication reminders fetched = ${meds.length}');
        } catch (err) {
          print('DEBUG [HomeScreen]: error fetching reminders = $err');
          meds = [];
        }

        try {
          logs = await SupabaseService().getMedicationLogsForDate(DateTime.now());
          print('DEBUG [HomeScreen]: medication logs fetched = ${logs.length}');
        } catch (err) {
          print('DEBUG [HomeScreen]: error fetching logs = $err');
          logs = [];
        }
      }

      int treatmentDay = 0;
      int treatmentTotal = profile?['medication_target_days'] ?? 128;
      if (profile != null && profile['treatment_start_date'] != null) {
        try {
          final startDate = DateTime.parse(profile['treatment_start_date']);
          treatmentDay = DateTime.now().difference(startDate).inDays + 1;
          if (treatmentDay < 0) treatmentDay = 0;
          if (treatmentDay > treatmentTotal) treatmentDay = treatmentTotal;
        } catch (err) {
          print('DEBUG [HomeScreen]: error parsing treatment start date = $err');
        }
      }

      print('DEBUG [HomeScreen]: treatmentDay = $treatmentDay, treatmentTotal = $treatmentTotal, has_treatment = ${profile?['has_treatment']}');

      if (mounted) {
        setState(() {
          _userName = (profile?['full_name'] as String?)?.isNotEmpty == true
              ? profile!['full_name']
              : metaName.isNotEmpty
                  ? metaName
                  : 'Pengguna';
          _hasTreatment = profile?['has_treatment'] == true;
          _treatmentDay = treatmentDay;
          _treatmentTotal = treatmentTotal;
          _medications = meds;
          _medicationLogs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG [HomeScreen]: outer exception in _loadUserData = $e');
      if (mounted) {
        final user = Supabase.instance.client.auth.currentUser;
        final metaName = user?.userMetadata?['full_name'] as String? ?? 'Pengguna';
        setState(() {
          _userName = metaName;
          _isLoading = false;
        });
      }
    }
  }

  String _determineMedicationStatus(Map<String, dynamic> med) {
    final String reminderId = med['id'] as String;
    final int hashedId = SupabaseService().uuidToBigInt(reminderId);

    final alreadyTaken = _medicationLogs.any((log) => log['reminder_id'] == hashedId);
    if (alreadyTaken) return 'done';

    final String timeRaw = med['time_to_take'] as String? ?? '00:00:00';
    final parts = timeRaw.split(':');
    final int hour = int.tryParse(parts[0]) ?? 0;
    final int minute = int.tryParse(parts[1]) ?? 0;
    
    final now = DateTime.now();
    final medTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (medTime.isAfter(now)) {
      return 'waiting';
    }

    return 'todo';
  }

  Future<void> _confirmMedication(String reminderId) async {
    try {
      await SupabaseService().logMedicationTaken(reminderId: reminderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Status obat berhasil diperbarui!'),
          backgroundColor: Color(0xFF1B5E20),
          duration: Duration(seconds: 2),
        ));
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menyimpan log: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Selamat Pagi';
    if (hour >= 12 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _getGreetingSubtitle() {
    return 'Semangat terus di perjalanan\npemulihanmu!';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7F6),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF1B5E20),
          onRefresh: _loadUserData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Greeting — nama & waktu dinamis
                Text(
                  '${_getGreeting()}, $_userName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getGreetingSubtitle(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2E5B53),
                  ),
                ),
                const SizedBox(height: 32),

                // Progres Pengobatan — hanya tampil jika user punya treatment
                if (_hasTreatment) ...[
                  _buildTreatmentCard(),
                  const SizedBox(height: 32),

                  // Jadwal Obat
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jadwal Obat Hari Ini',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onViewAllMedications,
                        child: const Text(
                          'LIHAT SEMUA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_medications.isEmpty)
                    _buildEmptyMedication()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _medications.length,
                      itemBuilder: (context, index) {
                        final med = _medications[index];
                        final String fullDosage = med['dosage'] as String? ?? '';
                        final parts = fullDosage.split(' • ');
                        final String dosage = parts.isNotEmpty ? parts[0] : '';
                        final String? notes = parts.length > 1 ? parts[1] : null;
                        
                        final timeRaw = med['time_to_take'] as String? ?? '00:00:00';
                        final timeParts = timeRaw.split(':');
                        final hourRaw = timeParts[0];
                        final minuteRaw = timeParts[1];
                        final hour = int.tryParse(hourRaw) ?? 0;
                        final period = hour < 12 ? 'AM' : 'PM';
                        final h12 = hour % 12 == 0 ? 12 : hour % 12;
                        final timeFormatted = '${h12.toString().padLeft(2, '0')}:$minuteRaw $period';
                        
                        final subtitle = notes != null
                            ? '$timeFormatted • $notes'
                            : timeFormatted;

                        final status = _determineMedicationStatus(med);

                        return HomeMedicationCard(
                          title: med['medication_name'] as String? ?? '',
                          subtitle: subtitle,
                          status: status,
                          onConfirm: status == 'todo'
                              ? () => _confirmMedication(med['id'] as String)
                              : null,
                        );
                      },
                    ),
                ] else ...[
                  // Card info untuk user yang belum setup pengobatan
                  _buildNoTreatmentCard(),
                ],

                const SizedBox(height: 32),

                // Card skrining cepat selalu tampil
                _buildScreeningBanner(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTreatmentCard() {
    final progress = _treatmentTotal > 0 ? _treatmentDay / _treatmentTotal : 0.0;
    final sisa = _treatmentTotal - _treatmentDay;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFD4EED8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progres Pengobatan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hari $_treatmentDay/$_treatmentTotal',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sisa > 0 ? '$sisa Hari Tersisa' : 'Selamat! Pengobatan Selesai 🎉',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMedication() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4EED8), width: 1.5),
      ),
      child: Column(
        children: const [
          Icon(Icons.medication_outlined, color: Color(0xFF1B5E20), size: 40),
          SizedBox(height: 12),
          Text(
            'Belum ada jadwal obat',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          SizedBox(height: 4),
          Text(
            'Tambahkan jadwal obat di menu Medication',
            style: TextStyle(fontSize: 12, color: Colors.black45),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoTreatmentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4EED8), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.health_and_safety_outlined, color: Color(0xFF1B5E20), size: 28),
              SizedBox(width: 10),
              Text(
                'Pantau Kesehatan Anda',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Gunakan fitur skrining mandiri untuk memeriksa kondisi kesehatan paru-paru Anda secara berkala.',
            style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Jika Anda sedang menjalani pengobatan TBC, aktifkan fitur pengobatan di menu Profil untuk memantau progres dan jadwal obat.',
            style: TextStyle(fontSize: 12, color: Colors.black38, fontStyle: FontStyle.italic, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildScreeningBanner() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/screening'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Skrining Mandiri',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Periksa kondisi paru-paru Anda sekarang',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
