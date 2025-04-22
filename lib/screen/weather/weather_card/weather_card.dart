import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signup_login_page/screen/weather/models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;
  const WeatherCard({super.key, required this.weather});

  String formatTime(int timestamp) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
            .toLocal();
    return DateFormat('hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 15,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              weather.cityName,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${weather.temprature.toStringAsFixed(1)}°C',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const SizedBox(height: 10),
            Text(
              weather.description.toUpperCase(),
              style: const TextStyle(fontSize: 18,),
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.blue),
                    Text('${weather.humidity}%'),
                    const Text('Humidity', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.air, color: Colors.grey),
                    Text('${weather.windSpeed} km/h'),
                    const Text('Wind Speed', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(Icons.wb_sunny_outlined, color: Colors.orange),
                    Text(formatTime(weather.sunRise)),
                    const Text('Sunrise', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.nights_stay_outlined,
                        color: Colors.purple),
                    Text(formatTime(weather.sunSet)),
                    const Text('Sunset', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
