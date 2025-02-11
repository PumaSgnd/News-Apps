// news_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsService {
  static const String apiKey = 'ec69b18c90154b61b6a5a2b2e25cf099';

  static Future<List> fetchNews(String query) async {
    HttpClient client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    String url = 'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey';
    if (query.isNotEmpty) {
      url = 'https://newsapi.org/v2/everything?q=$query&apiKey=$apiKey';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['articles'];
    }
    return [];
  }
}

