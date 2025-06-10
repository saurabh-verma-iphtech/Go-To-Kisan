// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:signup_login_page/screen/weather/models/weather_model.dart';

// class WeatherCard extends StatelessWidget {
//   final Weather weather;
//   final bool isDefaultLocation;
//   final VoidCallback? onRetryLocation;
//   final VoidCallback? onOpenSettings;

//   const WeatherCard({
//     Key? key,
//     required this.weather,
//     this.isDefaultLocation = false,
//     this.onRetryLocation,
//     this.onOpenSettings,
//   }) : super(key: key);

//   String getCompassDirection(double degree) {
//     const directions = [
//       "N",
//       "NNE",
//       "NE",
//       "ENE",
//       "E",
//       "ESE",
//       "SE",
//       "SSE",
//       "S",
//       "SSW",
//       "SW",
//       "WSW",
//       "W",
//       "WNW",
//       "NW",
//       "NNW",
//     ];

//     // Normalize degree between 0 and 360, then divide by 22.5 to get the index
//     int index = ((degree % 360) / 22.5).round() % 16;
//     return directions[index];
//   }

//   String _formatTime(int timestamp) {
//     final date =
//         DateTime.fromMillisecondsSinceEpoch(
//           timestamp * 1000,
//           isUtc: true,
//         ).toLocal();
//     return DateFormat('hh:mm a').format(date);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         if (isDefaultLocation)
//           const Text(
//             'Location denied. Showing weather for default city:',
//             style: TextStyle(color: Colors.orange),
//           ),
//         const SizedBox(height: 10),
//         SizedBox(
//           height: 450,
//           child: Card(
//             elevation: 15,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             // color: Colors.white.withOpacity(0.9),
//             child: Stack(
//               children: [
//                 Positioned(
//                   child: Image.asset(
//                     'assets/weather.png',
//                     fit: BoxFit.fill,
//                     height: 450,
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     // mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(height: 12),
//                             Text(
//                               weather.cityName,
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             Text("Now", style: const TextStyle(fontSize: 20)),
//                             Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   '${weather.temprature.toStringAsFixed(1)}°',
//                                   style: const TextStyle(
//                                     fontSize: 40,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 Image.network(
//                                   'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
//                                   // width: 100,
//                                   height: 60,
//                                   // fit: BoxFit.cover,
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Text(
//                                   'Min: ${weather.tempMin.toStringAsFixed(1)}°',
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Max ${weather.tempMax.toStringAsFixed(1)}°',
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 3,),
//                             Text(
//                               'Feels like ${weather.feelsLike.toStringAsFixed(1)}°',
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Divider(height: 20, thickness: 1),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             SizedBox(height: 20,),
//                             Text(
//                               weather.description.toUpperCase(),
//                               style: const TextStyle(fontSize: 18),
//                             ),
//                             SizedBox(height: 10),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 const Icon(
//                                   Icons.water_drop,
//                                   color: Colors.blue,
//                                 ),
//                                 const Text(
//                                   'Humidity: ',
//                                   style: TextStyle(fontSize: 15),
//                                 ),
//                                 Text('${weather.humidity}%'),
//                               ],
//                             ),
//                             SizedBox(height: 4),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 const Icon(Icons.air, color: Colors.grey),

//                                 const Text(
//                                   'Wind: ',
//                                   style: TextStyle(fontSize: 15),
//                                 ),
//                                 Text('${weather.windSpeed} kph'),
//                               ],
//                             ),
//                             SizedBox(height: 4),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 const Icon(Icons.air, color: Colors.grey),

//                                 const Text(
//                                   'Wind Direction: ',
//                                   style: TextStyle(fontSize: 15),
//                                 ),
//                                 Text(getCompassDirection(weather.windDirection)),
//                               ],
//                             ),
//                             SizedBox(height: 4),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 const Icon(Icons.compass_calibration_sharp, color: Colors.grey),
//                                 const Text(
//                                   'Pressure: ',
//                                   style: TextStyle(fontSize: 15),
//                                 ),
//                                 Text('${weather.pressure} hPa'),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 170,
//                   left: 80,
//                   child:
//                 Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Column(
//                         children: [
//                           const Icon(
//                             Icons.wb_sunny_outlined,
//                             color: Colors.orange,
//                           ),
//                           Text(_formatTime(weather.sunRise)),
//                           const Text('Sunrise', style: TextStyle(fontSize: 16)),
//                         ],
//                       ),
//                       SizedBox(width: 70),
//                       Column(
//                         children: [
//                           const Icon(
//                             Icons.nights_stay_outlined,
//                             color: Colors.purple,
//                           ),
//                           Text(_formatTime(weather.sunSet)),
//                           const Text('Sunset', style: TextStyle(fontSize: 16)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//         // These buttons are now outside the card and will always show when isDefaultLocation is true
//         if (isDefaultLocation)
//           Padding(
//             padding: const EdgeInsets.only(top: 20),
//             child: Column(
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: onOpenSettings,
//                   icon: const Icon(Icons.location_on),
//                   label: const Text("Enable Location Manually",style: TextStyle(color: Colors.black),),
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: onRetryLocation,
//                   child: const Text("Retry Location Access"),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:signup_login_page/screen/weather/models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;
  final bool isDefaultLocation;
  final VoidCallback? onRetryLocation;
  final VoidCallback? onOpenSettings;

  const WeatherCard({
    Key? key,
    required this.weather,
    this.isDefaultLocation = false,
    this.onRetryLocation,
    this.onOpenSettings,
  }) : super(key: key);

  String getCompassDirection(double degree) {
    const directions = [
      "N",
      "NNE",
      "NE",
      "ENE",
      "E",
      "ESE",
      "SE",
      "SSE",
      "S",
      "SSW",
      "SW",
      "WSW",
      "W",
      "WNW",
      "NW",
      "NNW",
    ];
    int index = ((degree % 360) / 22.5).round() % 16;
    return directions[index];
  }

  String _formatTime(int timestamp) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(
          timestamp * 1000,
          isUtc: true,
        ).toLocal();
    return DateFormat('hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDayTime = DateTime.now().hour > 6 && DateTime.now().hour < 18;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        if (isDefaultLocation)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              'Location denied. Showing weather for default city:',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Container(
          height: screenHeight / 1.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2),
                      BlendMode.darken,
                    ),
                    child: Image.asset(
                      isDayTime ? "assets/weather.png" : "assets/night.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weather.cityName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE, MMM d').format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Now',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Temperature
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback:
                                (bounds) => LinearGradient(
                                  colors: [
                                    Colors.yellow.shade300,
                                    Colors.orange,
                                  ],
                                ).createShader(bounds),
                            child: Text(
                              '${weather.temprature.toStringAsFixed(0)}°',
                              style: const TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Image.network(
                              'https://openweathermap.org/img/wn/${weather.icon}@4x.png',
                              width: 80,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Feels Like and Description
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Feels like ${weather.feelsLike.toStringAsFixed(0)}°',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weather.description.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Weather Details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        childAspectRatio: screenWidth > 400 ? 3 : 2.5,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildDetailItem(
                            Icons.thermostat,
                            '${weather.tempMin.toStringAsFixed(0)}° / ${weather.tempMax.toStringAsFixed(0)}°',
                            'Min / Max',
                          ),
                          _buildDetailItem(
                            Icons.water_drop,
                            '${weather.humidity}%',
                            'Humidity',
                          ),
                          _buildDetailItem(
                            Icons.air,
                            '${weather.windSpeed} km/h',
                            'Wind',
                            extra: Transform.rotate(
                              angle:
                                  weather.windDirection * (3.1415926535 / 180),
                              child: const Icon(
                                Icons.navigation,
                                size: 18,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          _buildDetailItem(
                            Icons.speed,
                            '${weather.pressure} hPa',
                            'Pressure',
                          ),
                        ],
                      ),
                    ),

                    // Sunrise & Sunset
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSunTime(
                            Icons.wb_twilight,
                            _formatTime(weather.sunRise),
                            'Sunrise',
                          ),
                          _buildSunTime(
                            Icons.nightlight_round,
                            _formatTime(weather.sunSet),
                            'Sunset',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (isDefaultLocation) ...[
          const SizedBox(height: 10),
          _buildLocationButtons(),
        ],
      ],
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String value,
    String label, {
    Widget? extra,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                if (extra != null) ...[const SizedBox(width: 4), extra],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSunTime(IconData icon, String time, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 30),
        const SizedBox(height: 8),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildLocationButtons() {
    return Column(
      children: [
        // Enable Location Button (same as before)
        TweenAnimationBuilder(
          tween: ColorTween(
            begin: Colors.blueAccent,
            end: Colors.lightBlueAccent,
          ),
          duration: const Duration(seconds: 2),
          builder: (context, color, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [color!, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: onOpenSettings,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white),
                        const SizedBox(width: 10),
                        const Text(
                          'Enable Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 15),

        // Retry Button with proper animation handling
        StatefulBuilder(
          builder: (context, setState) {
            return OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                side: BorderSide(color: Colors.blueAccent, width: 1.5),
              ),
              onPressed: () async {
                if (onRetryLocation != null) {
                  final controller = AnimationController(
                    vsync: Scaffold.of(context),
                    duration: const Duration(milliseconds: 500),
                  );
                  final animation = CurvedAnimation(
                    parent: controller,
                    curve: Curves.easeInOut,
                  );

                  // Start rotation animation
                  await controller.forward();

                  // Call the retry function
                  onRetryLocation!();

                  // Reverse animation
                  await controller.reverse();
                  controller.dispose();
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotationTransition(
                    turns: AlwaysStoppedAnimation(0),
                    child: const Icon(Icons.refresh, color: Colors.blueAccent),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Retry Enable Location',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
