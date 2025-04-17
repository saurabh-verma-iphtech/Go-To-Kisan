import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const _key = 'bookmarked_articles';

  // Save a new article
  static Future<void> addBookmark(Map<String, dynamic> article) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList(_key) ?? [];

    // Prevent duplicates
    if (!saved.contains(jsonEncode(article))) {
      saved.add(jsonEncode(article));
      await prefs.setStringList(_key, saved);
    }
  }

  // Get all bookmarks
  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList(_key) ?? [];

    return saved
        .map((e) => jsonDecode(e))
        .cast<Map<String, dynamic>>()
        .toList();
  }

  // Remove bookmark
  static Future<void> removeBookmark(Map<String, dynamic> article) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList(_key) ?? [];

    saved.remove(jsonEncode(article));
    await prefs.setStringList(_key, saved);
  }
}
