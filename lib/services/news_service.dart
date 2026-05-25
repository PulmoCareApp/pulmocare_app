import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class NewsService {
  static const String _apiKey = '709b375b2043109cbe18af585064076a';
  static const String _baseUrl = 'https://gnews.io/api/v4';

  static const Map<String, String> _categoryQueries = {
    'Umum': 'tuberkulosis TBC paru paru kesehatan',
    'Nutrisi': 'nutrisi gizi makanan tuberkulosis TBC',
    'Efek Samping': 'efek samping obat tuberkulosis OAT',
    'Tips': 'tips gaya hidup sehat paru tuberkulosis',
  };

  // Cukup pastikan key tidak kosong dan bukan placeholder bawaan
  bool get _isConfigured =>
      _apiKey.isNotEmpty && _apiKey != 'YOUR_GNEWS_API_KEY';

  Future<List<NewsArticle>> fetchArticles(String category) async {
    if (!_isConfigured) {
      throw Exception('API key GNews belum dikonfigurasi');
    }

    final query = _categoryQueries[category] ?? _categoryQueries['Umum']!;
    final uri = Uri.parse(
      '$_baseUrl/search'
      '?q=${Uri.encodeComponent(query)}'
      '&lang=id'
      '&country=id'
      '&max=10'
      '&apikey=$_apiKey',
    );

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final rawList = data['articles'] as List<dynamic>? ?? [];
      return rawList
          .map((j) => NewsArticle.fromGNews(j as Map<String, dynamic>, category))
          .where((a) =>
              a.url.isNotEmpty &&
              a.title != '[Removed]' &&
              !a.title.startsWith('['))
          .toList();
    } else if (response.statusCode == 403) {
      throw Exception('API key tidak valid atau quota habis');
    } else {
      throw Exception('GNews API error ${response.statusCode}');
    }
  }
}
