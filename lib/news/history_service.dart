import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static Future<void> saveArticle(
    String title, String url, String imageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('read_articles') ?? [];

    // Cek apakah berita sudah ada dalam history
    Map<String, String> article = {
      'title': title,
      'url': url,
      'imageUrl': imageUrl
    };
    String articleJson = jsonEncode(article);

    if (!history.contains(articleJson)) {
      history.add(articleJson);
      prefs.setStringList('read_articles', history);
    }
  }

  static Future<List<Map<String, String>>> getHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('read_articles');

    if (history == null) return []; // Hindari nilai null

    return history.map((item) {
      return Map<String, String>.from(jsonDecode(item)); // Decode JSON
    }).toList();
  }
}
