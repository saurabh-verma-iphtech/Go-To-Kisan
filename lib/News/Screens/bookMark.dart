// lib/News/Screens/bookMark.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:signup_login_page/News/Screens/servicesBookmark.dart';
import 'package:url_launcher/url_launcher.dart';

class BookmarksPage extends StatefulWidget {
  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Map<String, dynamic>> bookmarks = [];

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  void loadBookmarks() async {
    final data = await BookmarkService.getBookmarks();
    setState(() => bookmarks = data);
  }

  void openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('bookmark'.tr())),
      body:
          bookmarks.isEmpty
              ? Center(child: Text('noBookmark'.tr()))
              : ListView.builder(
                itemCount: bookmarks.length,
                itemBuilder: (context, index) {
                  final article = bookmarks[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(article['title'] ?? 'noTitle'.tr()),
                        subtitle: Text(article['pubDate'] ?? ''),
                        trailing: IconButton(
                          icon: Icon(Icons.delete,color: Colors.red,),
                          onPressed: () async {
                            await BookmarkService.removeBookmark(article);
                            loadBookmarks();
                          },
                        ),
                        onTap: () => openUrl(article['link']),
                      ),
                      Divider(
                        color: Theme.of(context).dividerColor,
                        thickness: 1,
                        height: 0,
                      ),
                    ],
                  );
                },
              ),
    );
  }
}
