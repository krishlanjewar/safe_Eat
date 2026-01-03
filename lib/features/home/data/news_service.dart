import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A data model representing a news article fetched from the News API.
class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final String source;
  final String publishedAt;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.source,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      source: json['source'] != null ? json['source']['name'] : 'News',
      publishedAt: json['publishedAt'] ?? '',
    );
  }
}

/// A service that fetches the latest food safety and nutrition news.
class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2/everything';

  Future<List<NewsArticle>> fetchFoodNews() async {
    final apiKey = dotenv.env['NewsAPI'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('News API key not found');
    }

    final query =
        '("food safety" OR "nutrition" OR "healthy eating" OR "packaged food" OR "food regulations")';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse(
      '$_baseUrl?q=${Uri.encodeComponent(query)}&language=en&sortBy=publishedAt&pageSize=10&apiKey=$apiKey&_t=$timestamp',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List articles = data['articles'];
        return articles.map((json) => NewsArticle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Failed to connect to News API: $e');
    }
  }
}
