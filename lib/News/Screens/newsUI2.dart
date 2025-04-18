import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:signup_login_page/News/Screens/bookMark.dart';
import 'package:signup_login_page/News/Screens/servicesBookmark.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:badges/badges.dart' as badges;

class AgriNewsPage extends StatefulWidget {
  @override
  _AgriNewsPageState createState() => _AgriNewsPageState();
}

class _AgriNewsPageState extends State<AgriNewsPage> {
  final String apiKey =
      'pub_810852deb4a56e5f796eb00d7a41080011877'; // Replace with your actual API key
  List<dynamic> articles = [];
  bool isLoading = true;

  // Dropdown State
  String selectedCategory = 'all';
  String selectedLanguage = 'hi';

  final Map<String, String> categoryMapHindi = {
    'all': 'सभी',
    'environment': 'पर्यावरण',
    'food': 'खाद्य',
    'health': 'स्वास्थ्य',
    'science': 'विज्ञान',
    'business': 'व्यापार',
  };

  final Map<String, String> categoryMapEnglish = {
    'all': 'All',
    'environment': 'Environment',
    'food': 'Food',
    'health': 'Health',
    'science': 'Science',
    'business': 'Business',
  };

  Map<String, String> get currentCategoryMap =>
      selectedLanguage == 'hi' ? categoryMapHindi : categoryMapEnglish;


  final Map<String, String> languageMap = {'hi': 'हिंदी', 'en': 'English'};

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() => isLoading = true);
    List<String> categoriesToFetch =
        selectedCategory == 'all'
            ? ['environment', 'food', 'health', 'science', 'business']
            : [selectedCategory];

    List<dynamic> allArticles = [];

    try {
      for (String category in categoriesToFetch) {
        final url = Uri.parse(
          'https://newsdata.io/api/1/news?apikey=$apiKey&country=in&category=$category&language=$selectedLanguage',
        );

        final response = await http.get(url);
        print('Category: $category | Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = json.decode(utf8.decode(response.bodyBytes));
          final results = data['results'] ?? [];
          allArticles.addAll(results);
        } else {
          print('Error fetching $category: ${response.body}');
        }
      }

      // Sort articles by pubDate descending
      allArticles.sort((a, b) {
        final dateA = DateTime.tryParse(a['pubDate'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['pubDate'] ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      setState(() {
        articles = allArticles;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error: $e');
    }
  }

  void openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        // iconTheme: IconThemeData(color: Colors.white),
        // title: Text("Agri News",style: TextStyle(color: Colors.white),),
        title: Text("agriNews".tr()),

        actions: [
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: -5, end: -25),
            badgeContent: Text(
              'bookmark'.tr(),
              style: const TextStyle( fontSize: 10),
            ),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.transparent,
              padding: EdgeInsets.all(2),
              shape: badges.BadgeShape.instagram,
            ),
            child: IconButton(
              icon: Icon(Icons.bookmarks,),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookmarksPage()),
                );
              },
            ),
          ),
          SizedBox(width: screenWidth / 15),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedLanguage,
              icon: Icon(Icons.language, color: Colors.white),
              dropdownColor: Colors.white,
              items:
                  languageMap.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
              onChanged: (lang) {
                if (lang != null) {
                  setState(() {
                    selectedLanguage = lang;
                    selectedCategory = 'all'; // optional reset
                  });
                  fetchNews();
                }
              },
            ),

          ),
        ],
      ),
      body: Column(
        children: [
          // Category Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: "category".tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items:
                  currentCategoryMap.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedCategory = val);
                  fetchNews();
                }
              },
            ),
          ),

          // News List
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : articles.isEmpty
                    ? Center(child: Text('noNews'.tr()))
                    : ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: EdgeInsets.only(bottom: 15),
                          elevation: 4,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () => openUrl(article['link'] ?? ''),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (article['image_url'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: Image.network(
                                      article['image_url'],
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, _, __) => SizedBox.shrink(),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article['title'] ?? 'noTitle'.tr(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        article['pubDate'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        article['description'] ??
                                            'fullArticle'.tr(),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      IconButton(
                                        icon: Icon(Icons.bookmark_add),
                                        onPressed: () async {
                                          await BookmarkService.addBookmark(
                                            article,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'addBookmark'.tr(),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
