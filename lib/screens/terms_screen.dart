import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Syarat & Ketentuan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Membangun Kepercayaan Melalui Transparansi.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Selamat datang di Aplikasi PulmoCare. Kami berkomitmen untuk melindungi perjalanan kesehatan Anda dengan standar keamanan dan etika tertinggi.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // CARD MENU (3 ITEMS)
            _buildMenuCard(
              icon: Icons.menu,
              title: 'Penggunaan Aplikasi',
              description: 'Ketentuan mengenai lisensi, akses, dan pembatasan platform.',
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              icon: Icons.security,
              title: 'Privasi Data',
              description: 'Bagaimana kami mengelola dan melindungi data kesehatan sensitif Anda.',
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              icon: Icons.gavel,
              title: 'Tanggung Jawab',
              description: 'Kewajiban pengguna dalam memelihara integritas informasi medis.',
            ),
            const SizedBox(height: 24),

            // KONTEN TEXT
            const Text(
              'Penggunaan Aplikasi & Layanan',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dengan mengakses Aplikasi PulmoCare, Anda setuju untuk menggunakan platform ini hanya untuk tujuan pemantauan kesehatan pribadi sesuai dengan protokol medis yang ditentukan. Kami memberikan lisensi terbatas, non-eksklusif, dan tidak dapat dipindahtangankan untuk mengakses konten kami.',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 16),
            
            // Kepatuhan Pengguna Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.check_circle_outline, size: 16, color: Colors.black54),
                      SizedBox(width: 8),
                      Text(
                        'Kepatuhan Pengguna',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Layanan ini bukan pengganti saran medis profesional, diagnosis, atau perawatan. Selalu cari saran dari dokter Anda atau penyedia kesehatan berkualitas lainnya terkait kondisi medis.',
                    style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Anda dilarang keras untuk mencoba merekayasa balik perangkat lunak, menggunakan bot otomatis untuk ekstraksi data, atau mengganggu integritas server kami.',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 24),

            const Text(
              'Kebijakan Privasi & Keamanan Data',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Privasi Anda adalah inti dari Aplikasi PulmoCare. Kami menerapkan enkripsi end-to-end untuk data kesehatan Anda dan mematuhi regulasi perlindungan data internasional.',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 16),

            _buildBulletPoint(
              icon: Icons.lock_outline,
              title: 'Penyimpanan Terenkripsi',
              description: 'Seluruh catatan medis digital disimpan dalam server dengan standar keamanan tingkat militer.',
            ),
            const SizedBox(height: 12),
            _buildBulletPoint(
              icon: Icons.shield_outlined,
              title: 'Tidak Ada Penjualan Data',
              description: 'Kami menjamin bahwa data kesehatan pribadi Anda tidak akan pernah dijual atau dibagikan kepada pihak ketiga untuk tujuan pemasaran.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Pengguna memiliki hak penuh untuk meminta penghapusan data permanen melalui pengaturan profil atau menghubungi tim dukungan teknis kami.',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 24),

            const Text(
              'Tanggung Jawab Pengguna',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sebagai pengguna, Anda bertanggung jawab penuh atas keakuratan data yang Anda masukkan ke dalam sistem. Informasi yang tidak akurat dapat mempengaruhi hasil pemantauan dan rekomendasi yang diberikan oleh sistem.',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 24),

            // WARNING BOX
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE), // Soft pink
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Peringatan Penting',
                    style: TextStyle(
                      color: Color(0xFFC62828), // Dark red for title
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Keamanan akun Anda adalah tanggung jawab Anda. Jangan pernah membagikan kredensial login atau PIN akses kesehatan Anda kepada siapapun. Tim kami tidak akan pernah meminta kata sandi Anda melalui pesan singkat atau telepon.',
                    style: TextStyle(
                      color: Color(0xFFB71C1C), // Deep red for text
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pelanggaran terhadap ketentuan tanggung jawab ini dapat mengakibatkan penangguhan akun secara permanen tanpa pemberitahuan sebelumnya demi menjaga keamanan ekosistem pengguna lainnya.',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({required IconData icon, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint({required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
