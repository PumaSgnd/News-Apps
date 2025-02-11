import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../news/history_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, String>>? history;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    await Future.delayed(const Duration(seconds: 2));
    history = await HistoryService.getHistory();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read History'),
      ),
      body: history == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : history!.isEmpty
              ? const Center(
                  child:
                      Text("No read history", style: TextStyle(fontSize: 18)))
              : ListView.builder(
                  itemCount: history!.length,
                  itemBuilder: (context, index) {
                    final article = history![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10), 
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: article['imageUrl']!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  article['imageUrl']!,
                                  width: 90,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image,
                                          size: 50, color: Colors.grey),
                                ),
                              )
                            : const Icon(Icons.image_not_supported,
                                size: 50, color: Colors.grey),
                        title: Text(
                          article['title']!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          article['url']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.teal),
                        ),
                        onTap: () => launchUrl(Uri.parse(article['url']!)),
                      ),
                    );
                  },
                ),
    );
  }
}
