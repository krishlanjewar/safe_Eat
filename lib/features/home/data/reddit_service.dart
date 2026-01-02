import 'dart:convert';
import 'package:http/http.dart' as http;

class RedditPost {
  final String title;
  final String author;
  final int ups;
  final int numComments;
  final String? thumbnailUrl;
  final String url;
  final String subreddit;

  RedditPost({
    required this.title,
    required this.author,
    required this.ups,
    required this.numComments,
    this.thumbnailUrl,
    required this.url,
    required this.subreddit,
  });

  factory RedditPost.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    String? thumb = data['thumbnail'];
    if (thumb == 'self' || thumb == 'default' || thumb == 'image') {
      thumb = null;
    }

    return RedditPost(
      title: data['title'] ?? 'No Title',
      author: data['author'] ?? 'unknown',
      ups: data['ups'] ?? 0,
      numComments: data['num_comments'] ?? 0,
      thumbnailUrl: thumb,
      url: 'https://reddit.com${data['permalink']}',
      subreddit: data['subreddit'] ?? 'food',
    );
  }
}

class RedditService {
  static const String _defaultUrl =
      'https://www.reddit.com/r/foodreviews/new.json';

  Future<List<RedditPost>> fetchFoodReviews() async {
    try {
      final response = await http.get(Uri.parse(_defaultUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List children = data['data']['children'];
        return children.map((post) => RedditPost.fromJson(post)).toList();
      } else {
        throw Exception('Failed to load reddit posts');
      }
    } catch (e) {
      throw Exception('Failed to connect to Reddit: $e');
    }
  }
}
