import 'package:flutter/material.dart';
import 'package:signup_login_page/News/Services/newsServices.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsFeedPage extends StatefulWidget {
  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  late Future<List<Map<String, dynamic>>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = NewsService().fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('किसान न्यूज़')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error loading news'));

          final newsList = snapshot.data!;
          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(news['news_title'] ?? ''),
                  subtitle: Text(news['news_description'] ?? ''),
                  onTap: () => launchUrl(Uri.parse(news['news_link'] ?? '')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
