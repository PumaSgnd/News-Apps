import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../news/history_service.dart';
import '../news/news_service.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List articles = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('E, d MMM HH.mm', 'id_ID').format(date);
  }

  Future<void> fetchNews({String query = ''}) async {
    setState(() => isLoading = true);
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Low Connection!')),
      );
      setState(() => isLoading = false);
      return;
    }
    articles = await NewsService.fetchNews(query);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 15.0, right: 18.0, left: 18.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => fetchNews(query: searchController.text),
                ),
              ),
              onSubmitted: (value) => fetchNews(query: value),
            ),
          ),
          Expanded(
            child: isLoading ? _buildShimmerLoading() : _buildNewsLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          height: 100.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNewsLayout() {
    List<Widget> newsWidgets = [];
    for (int i = 0; i < articles.length; i++) {
      if (i % 5 == 0) {
        newsWidgets.add(buildMainNews(articles[i]));
      } else {
        if (i % 5 == 1 || i % 5 == 3) {
          newsWidgets.add(Row(
            children: [
              Expanded(child: buildSmallNews(articles[i])),
              if (i + 1 < articles.length)
                Expanded(child: buildSmallNews(articles[i + 1])),
            ],
          ));
        }
      }
    }
    return SingleChildScrollView(
      child: Column(children: newsWidgets),
    );
  }

  Widget buildMainNews(dynamic article) {
    return GestureDetector(
      onTap: () => openArticle(
          article['url'], article['title'], article['urlToImage'] ?? ''),
      child: Card(
        margin: const EdgeInsets.only(
            top: 8.0, bottom: 8.0, left: 18.0, right: 18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            article['urlToImage'] != null
                ? ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                    child: CachedNetworkImage(
                      imageUrl: article['urlToImage'] ?? '',
                      width: double.infinity,
                      height: 170,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white, height: 170),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 170,
                        color: Colors.grey,
                        child: const Icon(Icons.broken_image,
                            size: 50, color: Colors.white),
                      ),
                    ),
                  )
                : Container(height: 170, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['name'] ?? 'Unknown Source',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic),
                  ),
                  Text(
                    article['title'] ?? 'No Title',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (article['author'] != null)
                    Text(
                      'By ${article['author']}',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500),
                    ),
                  Text(
                    article['description'] ?? 'No Description available',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDate(article['publishedAt']),
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSmallNews(dynamic article) {
    return GestureDetector(
      onTap: () => openArticle(
          article['url'], article['title'], article['urlToImage'] ?? ''),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(
            top: 8.0, bottom: 8.0, left: 18.0, right: 18.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 5,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: article['urlToImage'] != null
                  ? CachedNetworkImage(
                      imageUrl: article['urlToImage'] ?? '',
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white, height: 170),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 170,
                        color: Colors.grey,
                        child: const Icon(Icons.broken_image,
                            size: 50, color: Colors.white),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['name'] ?? 'Unknown Source',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic),
                  ),
                  Text(
                    article['title'] ?? 'No Title',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  if (article['author'] != null)
                    Text(
                      article['author']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontStyle: FontStyle.italic),
                    ),
                  Text(
                    article['description'] ?? 'No Description',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      formatDate(article['publishedAt']),
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openArticle(String url, String title, String imageUrl) async {
    await HistoryService.saveArticle(title, url, imageUrl);

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open the news!')),
      );
    }
  }
}
