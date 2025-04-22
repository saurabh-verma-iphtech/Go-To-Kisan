import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:signup_login_page/screen/weather/models/weather_model.dart';

class WeatherService {
  final String apiKey = 'fe85634e84271722dca705388c0beb75';

  Future<Weather> fetchingWeather(String cityName) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric');

    final response = await http.get(url);

      // print('Response Code: ${response.statusCode}');
    // print('Response Body: ${response.body}');

    if(response.statusCode == 200){
      return Weather.fromJson(jsonDecode(response.body));
    }
    else{
      throw Exception('Failed to load weather data');
    }
  }
}
