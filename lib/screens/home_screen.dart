import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../widgets/medication_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Ambil nama dari auth metadata (dikirim saat register)
      final user = Supabase.instance.client.auth.currentUser;
      final metaName = user?.userMetadata?['full_name'] as String? ?? '';

      // Ambil profil dari tabel profiles
      final profile = await SupabaseService().getUserProfile();

      // Ambil jadwal obat dari Supabase jika ada
      List<Map<String, dynamic>> meds = [];
      if (profile != null && profile['has_treatment'] == true) {
        try {
          final data = await Supabase.instance.client
              .from('medication_reminders')
              .select()
              .eq('user_id', user!.id)
              .order('time_to_take', ascending: true);
          meds = List<Map<String, dynamic>>.from(data);
        } catch (_) {
          meds = [];
        }
      }

      // Hitung hari pengobatan
      int treatmentDay = 0;
      int treatmentTotal = 128; // TBC standar 128 hari (4 bulan)
      if (profile != null && profile['treatment_start_date'] != null) {
        try {
          final startDate = DateTime.parse(profile['treatment_start_date']);
          treatmentDay = DateTime.now().difference(startDate).inDays + 1;
          if (treatmentDay < 0) treatmentDay = 0;
          if (treatmentDay > treatmentTotal) treatmentDay = treatmentTotal;
        } catch (_) {}
      }

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
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Fallback: gunakan nama dari auth saja
        final user = Supabase.instance.client.auth.currentUser;
        final metaName = user?.userMetadata?['full_name'] as String? ?? 'Pengguna';
        setState(() {
          _userName = metaName;
          _isLoading = false;
        });
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
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Mulai hari dengan semangat\ndan jaga kesehatan Anda!';
    if (hour >= 12 && hour < 15) return 'Jangan lupa istirahat sejenak\ndan minum air yang cukup!';
    if (hour >= 15 && hour < 18) return 'Semangat menjalani sore hari,\ntap kesehatan Anda selalu!';
    return 'Istirahat yang cukup\nuntuk tubuh yang sehat!';
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
                        onPressed: () {},
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
                        final timeRaw = med['time_to_take'] as String? ?? '00:00';
                        final timeParts = timeRaw.split(':');
                        final hour = int.tryParse(timeParts[0]) ?? 0;
                        final timeLabel = hour < 12
                            ? 'PAGI • ${timeParts[0]}:${timeParts[1]} AM'
                            : hour < 15
                                ? 'SIANG • ${timeParts[0]}:${timeParts[1]} PM'
                                : hour < 18
                                    ? 'SORE • ${timeParts[0]}:${timeParts[1]} PM'
                                    : 'MALAM • ${timeParts[0]}:${timeParts[1]} PM';
                        return MedicationCard(
                          title: '${med['medication_name']} ${med['dosage']}',
                          timeText: timeLabel,
                          description: 'Pengingat obat',
                          status: 'todo',
                          isLast: index == _medications.length - 1,
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
