import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/notification_panel.dart';


class ScreeningScreen extends StatefulWidget {
  const ScreeningScreen({Key? key}) : super(key: key);

  @override
  State<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends State<ScreeningScreen> {
  // Gejala states
  bool _batuk = false;
  bool _demam = false;
  bool _keringatMalam = false;
  bool _penurunanBerat = false;

  // Riwayat Kontak state
  bool? _riwayatKontak; // true for Ya, false for Tidak

  final TextEditingController _durasiController = TextEditingController();

  void _cekHasil() async {
    // Basic logic
    bool adaGejala = _batuk || _demam || _keringatMalam || _penurunanBerat;

    // Calculate a simple score for the database
    int score = 0;
    if (_batuk) score++;
    if (_demam) score++;
    if (_keringatMalam) score++;
    if (_penurunanBerat) score++;
    if (_riwayatKontak == true) score++;

    String status = score > 2 ? 'Risiko Tinggi' : (score > 0 ? 'Perlu Perhatian' : 'Risiko Rendah');

    // Simpan ke database — jika gagal, lanjutkan tetap ke hasil (jangan blokir user)
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('screening_results').insert({
          'user_id': user.id,
          'score': score,
          'status': status,
          'batuk': _batuk,
          'demam': _demam,
          'keringat_malam': _keringatMalam,
          'penurunan_berat': _penurunanBerat,
          'riwayat_kontak': _riwayatKontak ?? false,
        });
      }
    } catch (e) {
      // Simpan ke DB gagal tapi tidak perlu blokir user — lanjut ke hasil
      debugPrint('[Screening] Gagal simpan ke DB: $e');
    }

    if (mounted) {
      Navigator.pushNamed(
        context,
        '/result',
        arguments: {
          'adaGejala': adaGejala,
          'batuk': _batuk,
          'demam': _demam,
          'keringatMalam': _keringatMalam,
          'penurunanBerat': _penurunanBerat,
          'score': score,
          'status': status,
        },
      );
    }
  }

  @override
  void dispose() {
    _durasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button because it's a tab now
        title: const Text(
          'Skrining Mandiri',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => NotificationPanel.show(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mari kita periksa kondisi\nAnda hari ini.',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pilih gejala yang sedang Anda alami untuk mendapatkan analisis kesehatan yang lebih akurat dan terpadu.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2E5B53),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Gejala yang\nDirasakan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Gejala List
            _buildGejalaItem(
              title: 'Batuk > 2 minggu',
              subtitle: 'Batuk terus menerus berkepanjangan',
              icon: Icons.air,
              value: _batuk,
              onChanged: (val) {
                setState(() => _batuk = val!);
              },
            ),
            _buildGejalaItem(
              title: 'Demam',
              subtitle: 'Suhu tubuh tinggi di atas normal',
              icon: Icons.thermostat,
              value: _demam,
              onChanged: (val) {
                setState(() => _demam = val!);
              },
            ),
            _buildGejalaItem(
              title: 'Keringat malam',
              subtitle: 'Tanpa melakukan aktivitas fisik berlebih',
              icon: Icons.nightlight_round,
              value: _keringatMalam,
              onChanged: (val) {
                setState(() => _keringatMalam = val!);
              },
            ),
            _buildGejalaItem(
              title: 'Penurunan berat badan',
              subtitle: 'Turun drastis tanpa diet khusus',
              icon: Icons.trending_down,
              value: _penurunanBerat,
              onChanged: (val) {
                setState(() => _penurunanBerat = val!);
              },
            ),

            const SizedBox(height: 16),

            // Riwayat Kontak
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5F1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.people_outline, color: Color(0xFF1B5E20)),
                      SizedBox(width: 8),
                      Text(
                        'Riwayat Kontak',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Apakah Anda pernah melakukan kontak erat dengan penderita TBC?',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _riwayatKontak = true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _riwayatKontak == true
                                  ? const Color(0xFF1B5E20)
                                  : Colors.transparent,
                              border: Border.all(
                                color: _riwayatKontak == true
                                    ? const Color(0xFF1B5E20)
                                    : Colors.black26,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Ya',
                              style: TextStyle(
                                color: _riwayatKontak == true
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _riwayatKontak = false);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _riwayatKontak == false
                                  ? const Color(0xFF1B5E20)
                                  : Colors.transparent,
                              border: Border.all(
                                color: _riwayatKontak == false
                                    ? const Color(0xFF1B5E20)
                                    : Colors.black26,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Tidak',
                              style: TextStyle(
                                color: _riwayatKontak == false
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Durasi Gejala
            Row(
              children: const [
                Icon(Icons.access_time, size: 18, color: Color(0xFF1B5E20)),
                SizedBox(width: 8),
                Text(
                  'Durasi Gejala (Hari)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durasiController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Contoh: 14',
                hintStyle: const TextStyle(color: Colors.black38),
                filled: true,
                fillColor: const Color(0xFFF9FBF9),
                suffixText: 'HARI',
                suffixStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                  fontSize: 12,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cekHasil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Cek Hasil Skrining',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Hasil ini bukan merupakan diagnosis medis final. Harap\nhubungi tenaga medis profesional untuk konsultasi lebih\nlanjut.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGejalaItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFD4EED8), // Light green
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF1B5E20), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              value ? Icons.check_circle : Icons.circle_outlined,
              color: value ? const Color(0xFF1B5E20) : Colors.black26,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
