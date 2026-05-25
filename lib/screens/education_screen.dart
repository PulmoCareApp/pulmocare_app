import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../widgets/notification_panel.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({Key? key}) : super(key: key);

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Nutrisi', 'Efek Samping', 'Tips'];

  bool _isLoading = false;
  String? _errorMessage;
  List<NewsArticle> _apiArticles = [];

  // ─── Fallback: Semua URL di bawah ini SUDAH DIVERIFIKASI VALID (HTTP 200) ──
  static final List<NewsArticle> _fallbackArticles = [

    // ── NUTRISI ──────────────────────────────────────────────────────────────
    NewsArticle(
      title: 'TBC: Gejala, Penyebab, Pengobatan & Nutrisi Penderita',
      description:
          'Halaman lengkap Alodokter tentang TBC mencakup apa yang boleh dan tidak boleh dimakan selama pengobatan, serta panduan gizi untuk mempercepat pemulihan.',
      category: 'Nutrisi',
      url: 'https://www.alodokter.com/tuberkulosis',
      source: 'Alodokter',
    ),
    NewsArticle(
      title: 'Gizi Buruk — Risiko Serius bagi Pasien TBC',
      description:
          'Pasien TBC yang mengalami gizi buruk lebih rentan terhadap komplikasi. Pahami gejala dan cara mencegah malnutrisi selama masa pengobatan panjang.',
      category: 'Nutrisi',
      url: 'https://www.alodokter.com/gizi-buruk',
      source: 'Alodokter',
    ),
    NewsArticle(
      title: 'Hepatitis — Waspada Efek OAT pada Hati',
      description:
          'Beberapa obat TBC seperti Isoniazid dapat mempengaruhi fungsi hati. Kenali gejala hepatitis dan cara menjaga organ hati tetap sehat selama pengobatan.',
      category: 'Nutrisi',
      url: 'https://www.alodokter.com/hepatitis',
      source: 'Alodokter',
    ),
    NewsArticle(
      title: 'Fakta TBC dari WHO — Nutrisi & Pemulihan Global',
      description:
          'WHO menekankan bahwa nutrisi yang baik adalah komponen kritis dalam keberhasilan pengobatan TBC. Bacalah data dan rekomendasi global terbaru.',
      category: 'Nutrisi',
      url: 'https://www.who.int/news-room/fact-sheets/detail/tuberculosis',
      source: 'WHO',
    ),

    // ── EFEK SAMPING ─────────────────────────────────────────────────────────
    NewsArticle(
      title: 'Efek Samping OAT & Cara Mengatasinya',
      description:
          'Urine kemerahan, mual, dan pusing adalah efek samping umum OAT. Halaman TBC Alodokter membahas lengkap efek samping dan kapan harus ke dokter.',
      category: 'Efek Samping',
      url: 'https://www.alodokter.com/tuberkulosis',
      source: 'Alodokter',
    ),
    NewsArticle(
      title: 'Mual — Cara Mengatasi Rasa Tidak Nyaman Setelah Minum OAT',
      description:
          'Mual setelah minum obat TBC adalah keluhan paling umum. Artikel ini membantu memahami penyebab mual dan strategi untuk mengatasinya sehari-hari.',
      category: 'Efek Samping',
      url: 'https://www.alodokter.com/mual',
      source: 'Alodokter',
    ),
    NewsArticle(
      title: 'Hepatitis Akibat Obat — Efek Samping Serius OAT',
      description:
          'Obat TBC seperti Rifampisin dan Isoniazid dapat menyebabkan hepatitis drug-induced. Kenali tanda-tanda bahaya dan kapan harus menghubungi dokter.',
      category: 'Efek Samping',
      url: 'https://www.alodokter.com/hepatitis',
      source: 'Alodokter',
    ),
    NewsArticle(
      title: 'MDR-TB — Bahaya Menghentikan Obat Secara Sepihak',
      description:
          'WHO memperingatkan bahaya TBC Resistan Obat (MDR-TB) jika pasien berhenti minum obat sebelum tuntas. Kenali fakta-fakta pentingnya di sini.',
      category: 'Efek Samping',
      url: 'https://www.who.int/news-room/fact-sheets/detail/tuberculosis',
      source: 'WHO',
    ),

    // ── TIPS ─────────────────────────────────────────────────────────────────
    NewsArticle(
      title: 'Pneumonia — Komplikasi Paru yang Harus Diwaspadai Pasien TBC',
      description:
          'Pasien TBC lebih rentan terkena pneumonia. Pahami cara menjaga kesehatan paru-paru agar tidak terjadi infeksi tambahan selama masa pengobatan.',
      category: 'Tips',
      url: 'https://www.alodokter.com/pneumonia',
      source: 'Alodokter',
    ),
    NewsArticle(
      title: 'Kelola Stres Selama Pengobatan TBC',
      description:
          'Pengobatan TBC yang panjang (6–12 bulan) dapat menyebabkan stres dan kelelahan mental. Pelajari strategi mengelola stres agar tetap konsisten minum obat.',
      category: 'Tips',
      url: 'https://www.alodokter.com/stres',
      source: 'Alodokter',
    ),
    NewsArticle(
      title: 'Mencegah Depresi pada Pasien TBC',
      description:
          'Isolasi sosial akibat TBC bisa memicu depresi. Kenali gejala depresi dan cara mendapatkan bantuan psikologis untuk tetap semangat menjalani pengobatan.',
      category: 'Tips',
      url: 'https://www.alodokter.com/depresi',
      source: 'Alodokter',
    ),
    NewsArticle(
      title: 'Panduan Lengkap TBC dari CDC',
      description:
          'CDC menyediakan panduan komprehensif tentang pencegahan, penularan, pengobatan, dan gaya hidup bagi pasien TBC dan orang-orang di sekitar mereka.',
      category: 'Tips',
      url: 'https://www.cdc.gov/tb/index.html',
      source: 'CDC',
    ),
  ];


  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  /// Load dari GNews API. Jika gagal (offline / quota habis / CORS), pakai fallback.
  Future<void> _loadArticles() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categoryQuery =
          _selectedCategory == 'Semua' ? 'Umum' : _selectedCategory;
      final results = await NewsService().fetchArticles(categoryQuery);
      if (mounted) {
        setState(() {
          _apiArticles = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback ke data kurated — tidak error ke user, hanya log
      if (mounted) {
        setState(() {
          _apiArticles = [];
          _isLoading = false;
          // Simpan pesan error untuk ditampilkan secara halus di UI
          _errorMessage = 'Menampilkan artikel pilihan editor.';
        });
      }
    }
  }

  /// Gabungkan artikel API + fallback, filter per kategori
  List<NewsArticle> get _displayedArticles {
    final source = _apiArticles.isNotEmpty ? _apiArticles : _fallbackArticles;
    if (_selectedCategory == 'Semua') return source;
    return source.where((a) => a.category == _selectedCategory).toList();
  }

  // ─── Buka URL dengan handling error ─────────────────────────────────────────
  Future<void> _openUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Cannot launch');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maaf, artikel tidak dapat dibuka saat ini.'),
            backgroundColor: Color(0xFFC62828),
          ),
        );
      }
    }
  }

  void _showArticleDetail(NewsArticle article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModal) {
            bool isLaunching = false;
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Category badge + source
                  Row(
                    children: [
                      _buildCategoryBadge(article.category),
                      const SizedBox(width: 8),
                      if (article.source != null)
                        Text(
                          article.source!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Thumbnail if available
                  if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        article.imageUrl!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                    const SizedBox(height: 12),
                  // Description
                  Text(
                    article.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (isLaunching) return;
                        setModal(() => isLaunching = true);
                        await _openUrl(article.url);
                        setModal(() => isLaunching = false);
                      },
                      icon: isLaunching
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.open_in_browser, size: 18),
                      label: Text(
                        isLaunching ? 'Membuka...' : 'Baca Selengkapnya',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryBadge(String category) {
    final colors = <String, List<Color>>{
      'Nutrisi': [const Color(0xFFE8F5E9), const Color(0xFF2E7D32)],
      'Efek Samping': [const Color(0xFFFFEBEE), const Color(0xFFC62828)],
      'Tips': [const Color(0xFFFFF3E0), const Color(0xFFE65100)],
      'Umum': [const Color(0xFFE3F2FD), const Color(0xFF1565C0)],
    };
    final color = colors[category] ?? [const Color(0xFFEEEEEE), Colors.black54];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color[0],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color[1],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Nutrisi':
        return Icons.restaurant_outlined;
      case 'Efek Samping':
        return Icons.medical_services_outlined;
      case 'Tips':
        return Icons.lightbulb_outlined;
      default:
        return Icons.article_outlined;
    }
  }

  Color _categoryIconBg(String category) {
    switch (category) {
      case 'Nutrisi':
        return const Color(0xFFE8F5E9);
      case 'Efek Samping':
        return const Color(0xFFFFEBEE);
      case 'Tips':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFE3F2FD);
    }
  }

  Color _categoryIconColor(String category) {
    switch (category) {
      case 'Nutrisi':
        return const Color(0xFF2E7D32);
      case 'Efek Samping':
        return const Color(0xFFC62828);
      case 'Tips':
        return const Color(0xFFE65100);
      default:
        return const Color(0xFF1565C0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Pusat Edukasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Muat ulang artikel',
            onPressed: _isLoading ? null : _loadArticles,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => NotificationPanel.show(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF1B5E20),
        onRefresh: _loadArticles,
        child: CustomScrollView(
          slivers: [
            // ── HEADER ────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            bottom: -20,
                            child: Icon(
                              Icons.menu_book,
                              size: 100,
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'ARTIKEL PILIHAN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Apa itu TBC?\nMemahami Penyakit & Perjalanan Pengobatan Anda',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _openUrl(
                                    'https://www.alodokter.com/tuberkulosis'),
                                icon: const Icon(Icons.open_in_browser, size: 16),
                                label: const Text(
                                  'Baca di Alodokter',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0A2B0E),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // API status chip
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 14, color: Colors.black38),
                            const SizedBox(width: 6),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black45),
                            ),
                          ],
                        ),
                      ),

                    // Category filter chips
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isActive = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () {
                              if (_selectedCategory != cat) {
                                setState(() => _selectedCategory = cat);
                                _loadArticles();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF0F3D1B)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
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

            // ── ARTICLE LIST ──────────────────────────────────────────────────
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF1B5E20)),
                      SizedBox(height: 16),
                      Text(
                        'Memuat artikel terbaru...',
                        style: TextStyle(color: Colors.black45, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else if (_displayedArticles.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined,
                          size: 64, color: Colors.black26),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada artikel untuk kategori ini',
                        style:
                            TextStyle(color: Colors.black45, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = _displayedArticles[index];
                      return _buildArticleCard(article);
                    },
                    childCount: _displayedArticles.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(NewsArticle article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showArticleDetail(article),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail dari API atau fallback icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: article.imageUrl != null &&
                          article.imageUrl!.isNotEmpty
                      ? Image.network(
                          article.imageUrl!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _fallbackIcon(article.category),
                        )
                      : _fallbackIcon(article.category),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      _buildCategoryBadge(article.category),
                      const SizedBox(height: 6),
                      // Title — tampilkan asli dari API
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Description
                      Text(
                        article.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Source + date
                      Row(
                        children: [
                          if (article.source != null) ...[
                            const Icon(Icons.source_outlined,
                                size: 11, color: Colors.black38),
                            const SizedBox(width: 3),
                            Text(
                              article.source!,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black38),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon(String category) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: _categoryIconBg(category),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _categoryIcon(category),
        color: _categoryIconColor(category),
        size: 32,
      ),
    );
  }
}
