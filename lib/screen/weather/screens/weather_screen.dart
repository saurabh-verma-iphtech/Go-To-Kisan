// import 'package:flutter/material.dart';
// import 'package:signup_login_page/screen/weather/models/weather_model.dart';
// import 'package:signup_login_page/screen/weather/services/weather_services.dart';
// import 'package:signup_login_page/screen/weather/weather_card/weather_card.dart';

// class WeatherScreen extends StatefulWidget {
//   const WeatherScreen({super.key});

//   @override
//   State<WeatherScreen> createState() => _WeatherScreenState();
// }

// class _WeatherScreenState extends State<WeatherScreen> {
//   final WeatherService _weatherService = WeatherService();

//   final TextEditingController _controller = TextEditingController();

//   bool _isLoading = false;

//   Weather? _weather;

//   void _getWeather() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final weather = await _weatherService.fetchingWeather(_controller.text);
//       setState(() {
//         _weather = weather;
//         _isLoading = false;
//       },
//       );
//     }
//     catch (e) {
//       // To check the API status response
//       // print('Error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error fetching weather data')),
//       );
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Weather App'),
//         centerTitle: true,
//         // backgroundColor: const Color.fromARGB(255, 12, 141, 16),
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(
//           gradient: _weather != null
//               ? _getWeatherGradient(_weather!.description)
//               :  LinearGradient(
//                   colors: [const Color.fromARGB(244, 54, 136, 65), const Color.fromARGB(255, 42, 79, 57)],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter),
//         ),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(40),
//             child: Column(
//               children: [

//                 TextField(
//                   controller: _controller,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: InputDecoration(
//                     hintText: 'Enter City',
//                     hintStyle: const TextStyle(color: Colors.white),
//                     filled: true,
//                     fillColor: const Color.fromARGB(110, 255, 255, 255),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(20),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _getWeather,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromARGB(209, 249, 249, 249),
//                     foregroundColor: Colors.blue,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator()
//                       : const Text('Get Weather'),
//                 ),
//                 const SizedBox(height: 40),
//                 if (_isLoading)
//                   const Padding(
//                     padding: EdgeInsets.all(20),
//                     child: CircularProgressIndicator(color: Colors.white),
//                   ),
//                 if (_weather != null) WeatherCard(weather: _weather!)
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

// // Method for the Box-Decoration
//   LinearGradient _getWeatherGradient(String description) {
//     if (description.toLowerCase().contains('rain')) {
//       return const LinearGradient(
//         colors: [Colors.grey, Colors.blue],
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//       );
//     } else if (description.toLowerCase().contains('clear')) {
//       return const LinearGradient(
//         colors: [Colors.orangeAccent, Colors.blueAccent],
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//       );
//     } else if (description.toLowerCase().contains('thunderstorm')) {
//       return const LinearGradient(
//         colors: [Colors.deepPurple, Colors.black87],
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//       );
//     } else if (description.toLowerCase().contains('snow')) {
//       return const LinearGradient(
//         colors: [Colors.lightBlue, Colors.blueGrey],
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//       );
//     } else if (description.toLowerCase().contains('cloud')) {
//       return const LinearGradient(
//         colors: [Colors.grey, Colors.blueGrey],
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//       );
//     } else if (description.toLowerCase().contains('mist') ||
//         description.toLowerCase().contains('fog') ||
//         description.toLowerCase().contains('haze')) {
//       return const LinearGradient(
//         colors: [Colors.grey, Colors.blueGrey],
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//       );
//     } else {
//       return  LinearGradient(
//         colors: [Colors.lightBlue, Colors.orange.shade400],
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//       );
//     }
//   }
// }

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:signup_login_page/screen/weather/models/weather_model.dart';
// import 'package:signup_login_page/screen/weather/services/helper.dart';
// import 'package:http/http.dart' as http;

// class WeatherHomePage extends StatelessWidget {
//   const WeatherHomePage({Key? key}) : super(key: key);

//   Future<Weather> fetchWeather() async {
//     // final url = Uri.parse(
//     //   'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric',
//     // );

//     // final response = await http.get(url);

//     final String apiKey = 'fe85634e84271722dca705388c0beb75';
//     final defaultCity = 'Delhi';

//     try {
//       Position? position = await getUserLocation();

//       if (position != null) {
//         final lat = position.latitude;
//         final lon = position.longitude;

//         final url = Uri.parse(
//           'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
//         );

//         final response = await http.get(url);

//         if (response.statusCode == 200) {
//           final data = jsonDecode(response.body);
//           return Weather.fromJson(data);
//         }
//       }
//     } catch (e) {
//       print("Location-based weather failed: $e");
//     }

//     // Fallback to default city if location fails
//     final url = Uri.parse(
//       'https://api.openweathermap.org/data/2.5/weather?q=$defaultCity&appid=$apiKey&units=metric',
//     );

//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return Weather.fromJson(data);
//     } else {
//       throw Exception('Failed to load weather data');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Weather Info')),
//       body: FutureBuilder<Weather>(
//         future: fetchWeather(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting)
//             return Center(child: CircularProgressIndicator());

//           if (snapshot.hasError)
//             return Center(child: Text('Error: ${snapshot.error}'));

//           final weather = snapshot.data!;
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'City: ${weather.cityName}',
//                   style: TextStyle(fontSize: 20),
//                 ),
//                 Text('Temperature: ${weather.temprature} °C'),
//                 Text('Description: ${weather.description}'),
//                 Text('Humidity: ${weather.humidity}%'),
//                 Text('Wind: ${weather.windSpeed} m/s'),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:signup_login_page/screen/weather/models/weather_model.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({Key? key}) : super(key: key);

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _searchController = TextEditingController();
  Weather? _weather;
  bool _isLoading = true;
  bool _locationDenied = false;
  bool _isDefaultWeather = false;

  final String _apiKey =
      'fe85634e84271722dca705388c0beb75';

  @override
  void initState() {
    super.initState();
    _loadInitialWeather();
  }

  String formatTime(int timestamp) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(
          timestamp * 1000,
          isUtc: true,
        ).toLocal();
    return DateFormat('hh:mm a').format(date);
  }

  Future<void> _loadInitialWeather() async {
    try {
      Position? position = await _getUserLocation();
      if (position != null) {
        _isDefaultWeather = false;
        await _fetchWeatherByLocation(position.latitude, position.longitude);
      } else {
        _isDefaultWeather = true;
        await _fetchWeatherByCity("Delhi");
      }
    } catch (e) {
      print("Error: $e");
      _isDefaultWeather = true;
      await _fetchWeatherByCity("Delhi");
    }
  }

  Future<Position?> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool? result = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Enable Location'),
              content: const Text(
                'Location is disabled. Please enable it to get your current weather.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // ❌ Deny
                  child: const Text('Deny'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true); 
                    await Geolocator.openLocationSettings();
                  },
                  child: const Text('Allow'),
                ),
              ],
            ),
      );

      if (result != true) {
        setState(() {
          _locationDenied = true;
        });
        return null;
      }

      return null;
    }

    PermissionStatus permission = await Permission.location.status;

    if (permission.isDenied) {
      PermissionStatus result = await Permission.location.request();
      if (!result.isGranted) {
        setState(() {
          _locationDenied = true;
        });
        return null;
      }
    } else if (permission.isPermanentlyDenied) {
      setState(() {
        _locationDenied = true;
      });
      return null;
    }

    setState(() {
      _locationDenied = false;
    });

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _fetchWeatherByCity(String city) async {
    setState(() => _isLoading = true);
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _weather = Weather.fromJson(data);
        _isLoading = false;
      });
    } else {
      _showError("City not found!");
    }
  }

  Future<void> _fetchWeatherByLocation(double lat, double lon) async {
    setState(() => _isLoading = true);
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _weather = Weather.fromJson(data);
        _isLoading = false;
      });
    } else {
      _showError("Unable to fetch location weather");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather Info"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: "Search by city",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed:
                            () => _fetchWeatherByCity(_searchController.text),
                      ),
                    ),
                    onSubmitted: (value) => _fetchWeatherByCity(value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _locationDenied && _isDefaultWeather && _weather != null
                ? Column(
                  children: [
                    const Text(
                      'Location denied. Showing weather for default city:',
                      style: TextStyle(color: Colors.orange),
                    ),
                    Card(
                      elevation: 15,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              _weather!.cityName,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${_weather!.temprature.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _weather!.description.toUpperCase(),
                              style: const TextStyle(fontSize: 18),
                            ),
                            const Divider(height: 20, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    const Icon(
                                      Icons.water_drop,
                                      color: Colors.blue,
                                    ),
                                    Text('${_weather!.humidity}%'),
                                    const Text(
                                      'Humidity',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Icon(Icons.air, color: Colors.grey),
                                    Text('${_weather!.windSpeed} km/h'),
                                    const Text(
                                      'Wind Speed',
                                      style: TextStyle(fontSize: 16),
                                    ),
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
                                    const Icon(
                                      Icons.wb_sunny_outlined,
                                      color: Colors.orange,
                                    ),
                                    Text(formatTime(_weather!.sunRise)),
                                    const Text(
                                      'Sunrise',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Icon(
                                      Icons.nights_stay_outlined,
                                      color: Colors.purple,
                                    ),
                                    Text(formatTime(_weather!.sunSet)),
                                    const Text(
                                      'Sunset',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await openAppSettings(); // open location settings
                      },
                      icon: const Icon(Icons.location_on),
                      label: const Text("Enable Location Manually"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        // Request location permission again
                        PermissionStatus permission =
                            await Permission.location.request();
                        if (permission.isGranted) {
                          setState(() {
                            _locationDenied = false;
                            _isLoading = true;
                          });

                          // Fetch the user's location after permission is granted
                          Position position =
                              await Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high,
                              );

                          // Fetch weather by location
                          await _fetchWeatherByLocation(
                            position.latitude,
                            position.longitude,
                          );
                        }
                      },
                      child: const Text("Retry Location Access"),
                    ),
                  ],
                )
                : _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _weather == null
                ? const Text("No weather data")
                : Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      RichText(text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 18), 
                        children: [
                          TextSpan(text:'Current Weather: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text:_weather!.description,style: TextStyle(color: Colors.red)),
                    ])),
                      Card(
                        elevation: 15,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                _weather!.cityName,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${_weather!.temprature.toStringAsFixed(1)}°C',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _weather!.description.toUpperCase(),
                                style: const TextStyle(fontSize: 18),
                              ),
                              const Divider(height: 20, thickness: 1),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(
                                        Icons.water_drop,
                                        color: Colors.blue,
                                      ),
                                      Text('${_weather!.humidity}%'),
                                      const Text(
                                        'Humidity',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.air, color: Colors.grey),
                                      Text('${_weather!.windSpeed} km/h'),
                                      const Text(
                                        'Wind Speed',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 20, thickness: 1),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(
                                        Icons.wb_sunny_outlined,
                                        color: Colors.orange,
                                      ),
                                      Text(formatTime(_weather!.sunRise)),
                                      const Text(
                                        'Sunrise',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Icon(
                                        Icons.nights_stay_outlined,
                                        color: Colors.purple,
                                      ),
                                      Text(formatTime(_weather!.sunSet)),
                                      const Text(
                                        'Sunset',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
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
}
