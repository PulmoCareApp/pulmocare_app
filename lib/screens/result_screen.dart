import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {
              'adaGejala': false,
              'batuk': false,
              'demam': false,
              'keringatMalam': false,
              'penurunanBerat': false,
            };

    final bool adaGejala = args['adaGejala'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hasil Skrining',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: adaGejala ? const Color(0xFFFFF3E0) : const Color(0xFFD4EED8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      adaGejala ? Icons.info_outline : Icons.check,
                      color: adaGejala ? Colors.orange : const Color(0xFF1B5E20),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    adaGejala ? 'Risiko Sedang' : 'Risiko Rendah',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    adaGejala
                        ? 'Berdasarkan gejala yang dilaporkan, Anda disarankan untuk memeriksakan diri ke dokter.'
                        : 'Kondisi paru-paru Anda saat ini tampaknya dalam keadaan baik berdasarkan gejala yang Anda laporkan.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Gejala Dilaporkan
            Row(
              children: const [
                Icon(Icons.list_alt, color: Color(0xFF1B5E20)),
                SizedBox(width: 8),
                Text(
                  'Gejala Dilaporkan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSymptomItem('Batuk > 2 minggu', args['batuk'] ?? false),
            _buildSymptomItem('Demam', args['demam'] ?? false),
            _buildSymptomItem('Keringat Malam', args['keringatMalam'] ?? false),
            _buildSymptomItem('Penurunan Berat Badan', args['penurunanBerat'] ?? false),
            const SizedBox(height: 24),

            // Rekomendasi
            Row(
              children: const [
                Icon(Icons.lightbulb_outline, color: Color(0xFF1B5E20)),
                SizedBox(width: 8),
                Text(
                  'Rekomendasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              adaGejala
                  ? 'Kami sangat menyarankan Anda untuk segera mengunjungi fasilitas kesehatan terdekat untuk pemeriksaan lebih lanjut.'
                  : 'Meskipun hasil skrining menunjukkan risiko rendah, menjaga kesehatan paru-paru tetap penting.',
              style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Very light green
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.assistant_direction, size: 18, color: Color(0xFF1B5E20)),
                      SizedBox(width: 8),
                      Text(
                        'Langkah Selanjutnya:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRecommendationStep(
                      adaGejala ? 'Segera periksa ke dokter.' : 'Tetap jaga kondisi tubuh dengan olahraga rutin.'),
                  _buildRecommendationStep(
                      adaGejala ? 'Gunakan masker jika berinteraksi.' : 'Lakukan pola hidup sehat dan konsumsi makanan bergizi.'),
                  _buildRecommendationStep(
                      adaGejala ? 'Istirahat yang cukup.' : 'Hindari paparan asap rokok dan polusi berlebih.'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Back to Home Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.home_outlined, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomItem(String title, bool isPresent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isPresent ? Icons.add_circle_outline : Icons.remove_circle_outline,
            color: Colors.black54,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            isPresent ? title : 'Tidak ada $title',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 26),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }
}
