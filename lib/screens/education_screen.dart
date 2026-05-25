import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article_model.dart';
import '../widgets/notification_panel.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({Key? key}) : super(key: key);

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Nutrisi', 'Efek Samping', 'Tips'];
  bool _isFeaturedLoading = false;

  // Data Artikel Valid (15 Artikel TBC tersaring dan terverifikasi)
  final List<Article> _allArticles = [
    // --- KATEGORI: NUTRISI ---
    Article(
      title: 'Daftar Makanan untuk Penderita TBC',
      description: 'Nutrisi memegang peran penting. Ketahui makanan tinggi protein yang direkomendasikan untuk pemulihan.',
      category: 'Nutrisi',
      icon: Icons.restaurant,
      iconBackgroundColor: const Color(0xFFC8E6C9),
      iconColor: const Color(0xFF2E7D32),
      url: 'https://www.alodokter.com/daftar-makanan-untuk-penderita-tbc-agar-cepat-pulih',
    ),
    Article(
      title: 'Panduan Gizi untuk Penderita TBC',
      description: 'Pemenuhan gizi yang baik membantu memperbaiki sistem imun untuk melawan bakteri penyebab TBC.',
      category: 'Nutrisi',
      icon: Icons.local_dining,
      iconBackgroundColor: const Color(0xFFE8F5E9),
      iconColor: const Color(0xFF1B5E20),
      url: 'https://hellosehat.com/infeksi/tuberkulosis/makanan-untuk-penderita-tbc/',
    ),
    Article(
      title: 'Makanan Sehat Pendamping OAT',
      description: 'Sayuran hijau, buah-buahan kaya antioksidan, dan protein tinggi sangat disarankan untuk pengidap TBC.',
      category: 'Nutrisi',
      icon: Icons.apple_outlined,
      iconBackgroundColor: const Color(0xFFFFF9C4),
      iconColor: const Color(0xFFF57F17),
      url: 'https://www.halodoc.com/artikel/ini-makanan-sehat-untuk-pengidap-tbc',
    ),
    Article(
      title: 'Pantangan Makanan bagi Pasien TBC',
      description: 'Hindari makanan olahan, alkohol, dan kafein berlebihan agar obat TBC dapat bekerja maksimal.',
      category: 'Nutrisi',
      icon: Icons.no_food_outlined,
      iconBackgroundColor: const Color(0xFFFFCDD2),
      iconColor: const Color(0xFFC62828),
      url: 'https://www.alodokter.com/tuberkulosis',
    ),
    Article(
      title: 'Pentingnya Gizi Selama Pengobatan',
      description: 'Menurut Kemenkes, gizi seimbang dapat mencegah pasien TBC mengalami malnutrisi berat yang berbahaya.',
      category: 'Nutrisi',
      icon: Icons.health_and_safety_outlined,
      iconBackgroundColor: const Color(0xFFC8E6C9),
      iconColor: const Color(0xFF2E7D32),
      url: 'https://ayosehat.kemkes.go.id/topik-penyakit/infeksi/tuberkulosis',
    ),

    // --- KATEGORI: EFEK SAMPING ---
    Article(
      title: 'Mengenal Efek Samping Obat TBC',
      description: 'Urine kemerahan dan mual adalah efek samping umum dari Rifampisin. Pelajari selengkapnya di sini.',
      category: 'Efek Samping',
      icon: Icons.medical_services_outlined,
      iconBackgroundColor: const Color(0xFFFFCDD2),
      iconColor: const Color(0xFFC62828),
      url: 'https://tbindonesia.or.id/artikel/apa-saja-efek-samping-obat-tbc',
    ),
    Article(
      title: 'Gejala Efek Samping Berbahaya',
      description: 'Mata menguning atau pendengaran menurun? Segera hubungi dokter Anda jika mengalami gejala ini.',
      category: 'Efek Samping',
      icon: Icons.warning_amber_rounded,
      iconBackgroundColor: const Color(0xFFFFF9C4),
      iconColor: const Color(0xFFF57F17),
      url: 'https://www.alodokter.com/tuberkulosis',
    ),
    Article(
      title: 'Cara Mengatasi Mual Saat Minum OAT',
      description: 'Tips sederhana meredakan rasa tidak nyaman di perut setelah mengonsumsi obat TBC harian Anda.',
      category: 'Efek Samping',
      icon: Icons.sick_outlined,
      iconBackgroundColor: const Color(0xFFE8F5E9),
      iconColor: const Color(0xFF1B5E20),
      url: 'https://www.halodoc.com/artikel/mengenal-efek-samping-obat-tbc-dan-cara-mengatasinya',
    ),
    Article(
      title: 'Kapan Harus Berhenti Minum Obat?',
      description: 'Jangan pernah menghentikan obat TBC tanpa anjuran dokter, meski efek samping terasa mengganggu.',
      category: 'Efek Samping',
      icon: Icons.block_outlined,
      iconBackgroundColor: const Color(0xFFFFCDD2),
      iconColor: const Color(0xFFC62828),
      url: 'https://hellosehat.com/infeksi/tuberkulosis/efek-samping-obat-tbc/',
    ),
    Article(
      title: 'Bahaya Penghentian Obat Sepihak',
      description: 'WHO memperingatkan bahaya TBC resistan obat (MDR-TB) jika pasien berhenti minum obat sembarangan.',
      category: 'Efek Samping',
      icon: Icons.coronavirus_outlined,
      iconBackgroundColor: const Color(0xFFD7CCC8),
      iconColor: const Color(0xFF4E342E),
      url: 'https://www.who.int/news-room/fact-sheets/detail/tuberculosis',
    ),

    // --- KATEGORI: TIPS ---
    Article(
      title: 'Mencegah Penularan TBC di Rumah',
      description: 'Gunakan masker dan pastikan ventilasi sirkulasi udara di rumah berjalan lancar demi keluarga Anda.',
      category: 'Tips',
      icon: Icons.family_restroom,
      iconBackgroundColor: const Color(0xFFC8E6C9),
      iconColor: const Color(0xFF2E7D32),
      url: 'https://ayosehat.kemkes.go.id/cara-pencegahan-penularan-tbc',
    ),
    Article(
      title: 'Latihan Pernapasan Pasien TBC',
      description: 'Beberapa teknik pernapasan sederhana dapat membantu menjaga kapasitas dan kesehatan paru-paru Anda.',
      category: 'Tips',
      icon: Icons.air,
      iconBackgroundColor: const Color(0xFFE3F2FD),
      iconColor: const Color(0xFF1565C0),
      url: 'https://www.alodokter.com/cara-menjaga-kesehatan-paru-paru-yang-mudah-dilakukan',
    ),
    Article(
      title: 'Pentingnya Gaya Hidup Sehat',
      description: 'Berhenti merokok dan mulai rutin berolahraga ringan sangat membantu percepatan proses penyembuhan TBC.',
      category: 'Tips',
      icon: Icons.directions_run,
      iconBackgroundColor: const Color(0xFFC8E6C9),
      iconColor: const Color(0xFF2E7D32),
      url: 'https://www.halodoc.com/artikel/gaya-hidup-sehat-untuk-cegah-tbc',
    ),
    Article(
      title: 'Dukungan Psikologis Pasien TBC',
      description: 'Perjalanan pengobatan TBC bisa melelahkan. Kelola stres Anda dan cari dukungan dari orang terdekat.',
      category: 'Tips',
      icon: Icons.psychology_outlined,
      iconBackgroundColor: const Color(0xFFF3E5F5),
      iconColor: const Color(0xFF6A1B9A),
      url: 'https://www.who.int/health-topics/tuberculosis',
    ),
    Article(
      title: 'Menjaga Konsistensi Minum Obat',
      description: 'Gunakan alarm atau libatkan Pengawas Menelan Obat (PMO) agar Anda tidak pernah melewatkan dosis.',
      category: 'Tips',
      icon: Icons.alarm_on_outlined,
      iconBackgroundColor: const Color(0xFFFFF3E0),
      iconColor: const Color(0xFFE65100),
      url: 'https://tbindonesia.or.id/',
    ),
  ];

  List<Article> get _filteredArticles {
    if (_selectedCategory == 'Semua') {
      return _allArticles;
    }
    return _allArticles.where((article) => article.category == _selectedCategory).toList();
  }

  // Fungsi openUrl dengan Error Handling
  Future<void> _openUrl(String urlString, {VoidCallback? onStart, VoidCallback? onEnd}) async {
    if (onStart != null) onStart();
    
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        // Simulasi loading sebentar agar UX spinner terlihat
        await Future.delayed(const Duration(milliseconds: 500));
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maaf, artikel tidak dapat dibuka'),
            backgroundColor: Color(0xFFC62828), // Dark Red
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (onEnd != null) onEnd();
    }
  }

  void _showArticleDetail(Article article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            bool isLoading = false;

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: article.iconBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(article.icon, color: article.iconColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          article.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Preview Artikel',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description,
                    style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              _openUrl(
                                article.url,
                                onStart: () => setModalState(() => isLoading = true),
                                onEnd: () {
                                  if (mounted) {
                                    setModalState(() => isLoading = false);
                                  }
                                },
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20), // Dark green
                        disabledBackgroundColor: const Color(0xFF1B5E20).withOpacity(0.7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Baca Selengkapnya',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.white), // Matching Figma strictly
        title: const Text(
          'Pusat Edukasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => NotificationPanel.show(context),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FEATURED ARTICLE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20), // Dark Green
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          bottom: -20,
                          child: Icon(Icons.menu_book, size: 100, color: Colors.white.withOpacity(0.05)),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FEATURED ARTICLE',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Apa itu TBC? Memahami dasar-dasar perjalanan Anda.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _isFeaturedLoading
                                  ? null
                                  : () {
                                      _openUrl(
                                        'https://tbindonesia.or.id/artikel/apa-itu-tbc/',
                                        onStart: () => setState(() => _isFeaturedLoading = true),
                                        onEnd: () => setState(() => _isFeaturedLoading = false),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A2B0E), // Very dark green
                                disabledBackgroundColor: const Color(0xFF0A2B0E).withOpacity(0.7),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: _isFeaturedLoading
                                  ? const SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Baca Selengkapnya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CATEGORY FILTER
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0F3D1B) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // LIST ARTIKEL
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final article = _filteredArticles[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showArticleDetail(article),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: article.iconBackgroundColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(article.icon, color: article.iconColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      article.description,
                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, color: Colors.black26),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _filteredArticles.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
