// import 'dart:convert';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:signup_login_page/screen/weather/models/weather_model.dart';
// import 'package:signup_login_page/screen/weather/weather_card/weather_card.dart';

// class WeatherHomePage extends StatefulWidget {
//   const WeatherHomePage({Key? key}) : super(key: key);

//   @override
//   State<WeatherHomePage> createState() => _WeatherHomePageState();
// }

// class _WeatherHomePageState extends State<WeatherHomePage>
//     with WidgetsBindingObserver {
//   final TextEditingController _searchController = TextEditingController();
//   Weather? _weather;
//   bool _isLoading = true;
//   bool _locationDenied = false;
//   bool _isDefaultWeather = false;

//   final String _apiKey = 'fe85634e84271722dca705388c0beb75';

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this); // Register observer
//     _loadInitialWeather();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this); // Remove observer
//     super.dispose();
//   }

//   // 2. Add this new method to handle app lifecycle changes
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // Reload weather when app comes back from settings
//       _loadInitialWeather();
//     }
//   }

//   String formatTime(int timestamp) {
//     final date =
//         DateTime.fromMillisecondsSinceEpoch(
//           timestamp * 1000,
//           isUtc: true,
//         ).toLocal();
//     return DateFormat('hh:mm a').format(date);
//   }

//   Future<void> _loadInitialWeather() async {
//     try {
//       setState(() => _isLoading = true);
//       Position? position = await _getUserLocation();
//       if (position != null) {
//         _isDefaultWeather = false;
//         await _fetchWeatherByLocation(position.latitude, position.longitude);
//       } else if (_locationDenied || _weather == null) {
//         await _fetchWeatherByCity("Delhi");
//         setState(() => _isDefaultWeather = true);
//       }
//     } catch (e) {
//       _showError("Failed to load weather: ${e.toString()}");
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<Position?> _getUserLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       bool? result = await showDialog<bool>(
//         context: context,
//         builder:
//             (context) => AlertDialog(
//               title: const Text('Enable Location'),
//               content: const Text(
//                 'Location is disabled. Please enable it to get your current weather.',
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(false), // ❌ Deny
//                   child: const Text('Deny'),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     Navigator.of(context).pop(true);
//                     await Geolocator.openLocationSettings();
//                   },
//                   child: const Text('Allow'),
//                 ),
//               ],
//             ),
//       );

//       if (result == true) {
//         await Geolocator.openLocationSettings();
//         // After returning from settings, check again
//         serviceEnabled = await Geolocator.isLocationServiceEnabled();
//         if (!serviceEnabled) return null;
//       } else {
//         return null;
//       }
//       if (result != true) {
//         setState(() {
//           _locationDenied = true;
//         });
//         return null;
//       }

//       return null;
//     }

//     PermissionStatus permission = await Permission.location.status;

//     if (permission.isDenied) {
//       PermissionStatus result = await Permission.location.request();
//       if (!result.isGranted) {
//         setState(() {
//           _locationDenied = true;
//         });
//         return null;
//       }
//     } else if (permission.isPermanentlyDenied) {
//       setState(() {
//         _locationDenied = true;
//       });
//       return null;
//     }

//     setState(() {
//       _locationDenied = false;
//     });

//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//   }

//   Future<void> _fetchWeatherByCity(String city) async {
//     setState(() => _isLoading = true);
//     final url = Uri.parse(
//       'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric',
//     );
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       setState(() {
//         _weather = Weather.fromJson(data);
//         _isLoading = false;
//       });
//     } else {
//       final errorData = jsonDecode(response.body);
//       final message = errorData['message'] ?? "City not found!";
//       _showError(message.toString());
//     }
//   }

//   Future<void> _fetchWeatherByLocation(double lat, double lon) async {
//     setState(() => _isLoading = true);
//     final url = Uri.parse(
//       'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
//     );
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       setState(() {
//         _weather = Weather.fromJson(data);
//         _isLoading = false;
//       });
//     } else {
//       _showError("Unable to fetch location weather");
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//     setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("🌤️ Weather Info"), centerTitle: true),
//       body: RefreshIndicator(
//         onRefresh: _loadInitialWeather,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               // Search bar (keep existing)
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _searchController,
//                       decoration: InputDecoration(
//                         hintText: "Search by city",
//                         border: const OutlineInputBorder(),
//                         suffixIcon: IconButton(
//                           icon: const Icon(Icons.search),
//                           onPressed:
//                               () => _fetchWeatherByCity(_searchController.text),
//                         ),
//                       ),
//                       onSubmitted: (value) => _fetchWeatherByCity(value),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),

//               // Main content area
//               if (_isLoading)
//                 const Center(child: CircularProgressIndicator())
//               else if (_weather == null)
//                 const Text("No weather data")
//               else
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         if (_locationDenied && _isDefaultWeather)
//                           WeatherCard(
//                             weather: _weather!,
//                             isDefaultLocation: true,
//                             onRetryLocation: () async {
//                               PermissionStatus permission =
//                                   await Permission.location.request();
//                               if (permission.isGranted) {
//                                 setState(() => _locationDenied = false);
//                                 Position position =
//                                     await Geolocator.getCurrentPosition();
//                                 await _fetchWeatherByLocation(
//                                   position.latitude,
//                                   position.longitude,
//                                 );
//                               }
//                             },
//                             onOpenSettings: openAppSettings,
//                           )
//                         else
//                           Column(
//                             children: [
//                               RichText(
//                                 text: TextSpan(
//                                   style: const TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 18,
//                                   ),
//                                   children: [
//                                     const TextSpan(
//                                       text: 'Current Weather: ',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     TextSpan(
//                                       text: _weather!.description.toUpperCase(),
//                                       style: const TextStyle(color: Colors.red),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               WeatherCard(weather: _weather!),
//                             ],
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:signup_login_page/screen/weather/models/weather_model.dart';
import 'package:signup_login_page/screen/weather/weather_card/weather_card.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({Key? key}) : super(key: key);

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  Weather? _weather;
  bool _isLoading = true;
  bool _locationDenied = false;
  bool _isDefaultWeather = false;

  final String _apiKey = 'fe85634e84271722dca705388c0beb75';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialWeather();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadInitialWeather();
    }
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
      setState(() => _isLoading = true);
      Position? position = await _getUserLocation();
      if (position != null) {
        _isDefaultWeather = false;
        await _fetchWeatherByLocation(position.latitude, position.longitude);
      } else if (_locationDenied || _weather == null) {
        await _fetchWeatherByCity("Delhi");
        setState(() => _isDefaultWeather = true);
      }
    } catch (e) {
      _showError("Failed to load weather: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                  onPressed: () => Navigator.of(context).pop(false),
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
        setState(() => _locationDenied = true);
        return null;
      }
      return null;
    }

    PermissionStatus permission = await Permission.location.status;
    if (permission.isDenied || permission.isPermanentlyDenied) {
      final result = await Permission.location.request();
      if (!result.isGranted) {
        setState(() => _locationDenied = true);
        return null;
      }
    }

    setState(() => _locationDenied = false);
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
      });
    } else {
      final errorData = jsonDecode(response.body);
      final message = errorData['message'] ?? "City not found!";
      _showError(message.toString());
    }
    setState(() => _isLoading = false);
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
      });
    } else {
      _showError("Unable to fetch location weather");
    }
    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDayTime = DateTime.now().hour > 6 && DateTime.now().hour < 18;
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌤️ Weather Info"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: isDayTime
              ? [Colors.lightBlue.shade200, const Color.fromARGB(255, 242, 214, 114)]
              : [const Color.fromARGB(255, 112, 116, 160), const Color.fromARGB(221, 31, 30, 30)],
          // gradient: LinearGradient(
          //   colors:
          //       isDayTime
          //           ? [const Color.fromARGB(255, 112, 116, 160), const Color.fromARGB(221, 31, 30, 30)]
          //           : [Colors.indigo.shade900, Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            backgroundColor: Colors.black,
            onRefresh: _loadInitialWeather,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.location_city_outlined,color: Colors.white54,),
                            hintText: "Search by city",
                            hintStyle: TextStyle(color: Colors.white54),
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(16)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 221, 221, 221),
                                width: 2,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                final city = _searchController.text.trim();
                                if (city.isNotEmpty) _fetchWeatherByCity(city);
                              },
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _fetchWeatherByCity(value.trim());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_weather == null)
                    const Center(child: Text("No weather data"))
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (_locationDenied && _isDefaultWeather)
                              WeatherCard(
                                weather: _weather!,
                                isDefaultLocation: true,
                                onRetryLocation: () async {
                                  PermissionStatus permission =
                                      await Permission.location.request();
                                  if (permission.isGranted) {
                                    setState(() => _locationDenied = false);
                                    Position position =
                                        await Geolocator.getCurrentPosition();
                                    await _fetchWeatherByLocation(
                                      position.latitude,
                                      position.longitude,
                                    );
                                  }
                                },
                                onOpenSettings: openAppSettings,
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Current Weather: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              _weather?.description
                                                  .toUpperCase() ??
                                              '',
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 251, 251, 251),
                                            fontStyle: FontStyle.italic
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  WeatherCard(weather: _weather!),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
