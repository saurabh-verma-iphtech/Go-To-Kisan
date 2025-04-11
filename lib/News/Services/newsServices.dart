import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  final String apiKey = '579b464db66ec23bdd000001e999b45fa45f4d0558f60af490ad09ad';
  final String baseUrl =
      'https://api.data.gov.in/resource/apiKey';

  Future<List<Map<String, dynamic>>> fetchNews() async {
    final url = '$baseUrl?api-key=$apiKey&format=json&limit=20';
    print('Fetching news from: $url');
    final response = await http.get(Uri.parse(url));

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['records'] != null) {
        return List<Map<String, dynamic>>.from(data['records']);
      } else {
        throw Exception('No records found');
      }
    } else {
      throw Exception('Failed to load news');
    }
  }

}
