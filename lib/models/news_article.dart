// Model untuk artikel yang datang dari API (GNews) maupun data kurated lokal
class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String? imageUrl;
  final String? publishedAt;
  final String? source;
  final String category; // 'Nutrisi', 'Efek Samping', 'Tips', 'Umum'

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.imageUrl,
    this.publishedAt,
    this.source,
    required this.category,
  });

  factory NewsArticle.fromGNews(Map<String, dynamic> json, String category) {
    return NewsArticle(
      title: json['title'] ?? 'Tanpa Judul',
      description: json['description'] ?? json['content'] ?? 'Deskripsi tidak tersedia.',
      url: json['url'] ?? '',
      imageUrl: json['image'],
      publishedAt: json['publishedAt'],
      source: json['source']?['name'],
      category: category,
    );
  }
}
