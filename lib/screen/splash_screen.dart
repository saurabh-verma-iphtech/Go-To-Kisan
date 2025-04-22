// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:signup_login_page/screen/Seller/SellerDashboard.dart';
// import 'package:shimmer/shimmer.dart';

// import 'home.dart'; // Buyer homepage
// import 'login.dart'; // Login page

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _sunController;
//   late AnimationController _plantController;
//   late AnimationController _grassController;
//   late Animation<double> _fadeAnimation;
//   late AnimationController _birdController;


//   @override
//   void initState() {
//     super.initState();

//     _birdController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 6),
//     )..repeat(); // Makes birds keep flying


//     _sunController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 5),
//     )..repeat();

//     _grassController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 2),
//     )..forward();


//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _plantController, curve: Curves.easeIn));

//     // Use a timer to allow the splash animations to play,
//     // then check the authentication state.
//     // Timer(Duration(seconds: 4), _checkLoginAndNavigate);
//   }

//   Future<void> _checkLoginAndNavigate() async {
//     final prefs = await SharedPreferences.getInstance();
//     final role = prefs.getString('userRole'); // expected: 'seller' or 'buyer'

//     // Listen for the auth state change and wait for the first event.
//     final user = await FirebaseAuth.instance.authStateChanges().first;

//     if (user == null) {
//       // No authenticated user; ensure stored role is cleared.
//       await prefs.remove('userRole');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomePage()),
//       );
//     } else {
//       // Authenticated user found; now decide based on the stored role.
//       if (role == 'seller') {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SellerDashboard()),
//         );
//       } else if (role == 'buyer') {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomePage()),
//         );
//       } else {
//         // If the role isn’t set for some reason, go to the login page.
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => Login()),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _sunController.dispose();
//     _plantController.dispose();
//     _grassController.dispose();
//     _birdController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Colors.green[800]!,
//               const Color.fromARGB(255, 117, 203, 121)!,
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Rotating sun background
//             Positioned(
//               top: 160,
//               left: 20,
//               child: RotationTransition(
//                 turns: _sunController,
//                 child: SvgPicture.asset("assets/1sun.svg", width: 110),
//               ),
//             ),
//             Positioned(
//               top: 10,
//               right: 0,
//               child: AnimatedBuilder(
//                 animation: _sunController,
//                 builder: (context, child) {
//                   return Transform.translate(
//                     offset: Offset(50 * (_sunController.value - 0.5), 0),
//                     child: Row(
//                       children: [
//                         SvgPicture.asset("assets/clouds1.svg", width: 80),
//                         SizedBox(width: 40),
//                         SvgPicture.asset("assets/clouds1.svg", width: 80),
//                         SizedBox(width: 40),

//                         SvgPicture.asset("assets/clouds1.svg", width: 80),
//                         SizedBox(width: 40),

//                         SvgPicture.asset("assets/clouds1.svg", width: 80),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Positioned(
//               top: 80,
//               right: 80,
//               child: AnimatedBuilder(
//                 animation: _sunController,
//                 builder: (context, child) {
//                   return Transform.translate(
//                     offset: Offset(50 * (_sunController.value - 0.5), 0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         SvgPicture.asset("assets/clouds1.svg", width: 80),
//                         SizedBox(width: 40),
//                         SvgPicture.asset("assets/clouds1.svg", width: 80),
//                         SizedBox(width: 40),

//                         SvgPicture.asset("assets/clouds1.svg", width: 80),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // Center content: plant image and title
//             Align(
//               alignment: Alignment.center,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ScaleTransition(
//                     scale: _grassController,
//                     child: SvgPicture.asset("assets/field.svg", width: 170),
//                   ),
//                   SizedBox(height: 10),
//                   FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: SlideTransition(
//                       position: Tween<Offset>(
//                         begin: Offset(0, 0.5),
//                         end: Offset.zero,
//                       ).animate(
//                         CurvedAnimation(
//                           parent: _plantController,
//                           curve: Curves.bounceOut,
//                         ),
//                       ),
//                       child: Text(
//                         "Go To Kisan",
//                         style: TextStyle(
//                           decoration: TextDecoration.underline,
//                           decorationColor: Colors.black,
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                           letterSpacing: 1.5,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               bottom: 20,
//               left: 30,
//               child: Shimmer.fromColors(
//                 baseColor: Colors.black,
//                 highlightColor: Colors.greenAccent,
//                 child: Text(
//                   'Loading...',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             // Signature text at the bottom right
//             Positioned(
//               bottom: 40,
//               right: 30,
//               child: Text(
//                 'Saurabh Kumar Verma',
//                 style: TextStyle(
//                   fontFamily: "Sign1",
//                   fontSize: 15,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:signup_login_page/screen/Seller/SellerDashboard.dart';

import 'home.dart'; // Buyer homepage
import 'login.dart'; // Login page

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _sunController;
  late AnimationController _plantController;
  late AnimationController _grassController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bird1Controller;
  late AnimationController _bird2Controller;
  late AnimationController _birdController;
  late AnimationController _signatureController;
  late Animation<double> _signatureAnimation;



  @override
  void initState() {
    super.initState();
    

    _birdController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4), // Slow flight
    )..repeat();


    _sunController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 40),
    )..repeat();

    _plantController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..forward();

    _grassController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..forward();

    

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _plantController, curve: Curves.easeIn));

    // Flying birds
    _bird1Controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();

    _bird2Controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    )..repeat();

    _signatureController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..forward();

    _signatureAnimation = CurvedAnimation(
      parent: _signatureController,
      curve: Curves.easeOutBack,
    );


    // Delay to allow splash animations
    Timer(Duration(seconds: 4), _checkLoginAndNavigate);
  }

    Future<void> _checkLoginAndNavigate() async {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('userRole'); // expected: 'seller' or 'buyer'

      // Listen for the auth state change and wait for the first event.
      final user = await FirebaseAuth.instance.authStateChanges().first;

      if (user == null) {
        // No authenticated user; ensure stored role is cleared.
        await prefs.remove('userRole');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // Authenticated user found; now decide based on the stored role.
        if (role == 'seller') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SellerDashboard()),
          );
        } else if (role == 'buyer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          // If the role isn’t set for some reason, go to the login page.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }
    }

  @override
  void dispose() {
    _sunController.dispose();
    _plantController.dispose();
    _grassController.dispose();
    _bird1Controller.dispose();
    _bird2Controller.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green[800]!,
              const Color.fromARGB(255, 117, 203, 121)!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Background cloud layer (slower, semi-transparent)
            // Rotating sun
            Positioned(
              top: 120,
              left: 20,
              child: RotationTransition(
                turns: _sunController,
                child: SvgPicture.asset("assets/1sun.svg", width: 110),
              ),
            ),
            AnimatedBuilder(
              animation: _sunController,
              builder: (context, child) {
                final screenWidth = MediaQuery.of(context).size.width;
                final dx = (screenWidth + 240) * _sunController.value - 120;

                return Positioned(
                  top: 10,
                  left: -dx,
                  child: Row(
                    children: List.generate(5, (index) {
                      return Row(
                        children: [
                          Opacity(
                            opacity: 0.25,
                            child: SvgPicture.asset(
                              "assets/clouds1.svg",
                              width: 100,
                            ),
                          ),
                          SizedBox(width: 60),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),

            // Foreground cloud layer (faster, more vivid)
            AnimatedBuilder(
              animation: _sunController,
              builder: (context, child) {
                final screenWidth = MediaQuery.of(context).size.width;
                final dx = (screenWidth + 240) * _sunController.value - 120;

                return Positioned(
                  top: 50,
                  left: -dx/0.7,
                  child: Row(
                    children: List.generate(5, (index) {
                      return Row(
                        children: [
                          Opacity(
                            opacity: 0.4,
                            child: SvgPicture.asset(
                              "assets/clouds1.svg",
                              width: 120,
                            ),
                          ),
                          SizedBox(width: 60),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),


            // Flying bird 1
            AnimatedBuilder(
              animation: _birdController,
              builder: (context, child) {
                final birdX = screenWidth * _birdController.value;
                return Positioned(
                  top: 80 + 30 * sin(_birdController.value * 2 * pi),
                  left: birdX - 50,
                  child: Image.asset(
                    'assets/birds2.gif',
                    width: 150,
                    height: 90,
                  ),
                );
              },
            ),

            // Flying bird 2
            AnimatedBuilder(
              animation: _birdController,
              builder: (context, child) {
                final birdX = screenWidth * _bird2Controller.value;
                return Positioned(
                  top: 140 + 20 * sin(_bird2Controller.value * 2 * pi),
                  left: birdX - 50,
                  child: Image.asset(
                    'assets/birds2.gif',
                    width: 150,
                    height: 100,
                  ),
                );
              },
            ),

            // Center plant + title
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _grassController,
                    child: SvgPicture.asset("assets/field.svg", width: 170),
                  ),


                  SizedBox(height: 10),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      "Go To Kisan",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
            ...List.generate(3, (index) {
              final animation = AnimationController(
                vsync: this,
                duration: Duration(seconds: 5 + index * 2),
              )..repeat();

              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              );

              return AnimatedBuilder(
                animation: _birdController,
                builder: (context, child) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final dx = screenWidth * curved.value;
                  final dy =
                      370.0 +
                      index * 50 +
                      20 *
                          (index.isEven ? 1 : -1) *
                          (1 - curved.value).abs(); // slight up-down flutter

                  return Positioned(
                    top: dy,
                    left: dx - 100, // start offscreen
                    child: Transform.rotate(
                      angle: 0.2 * (1 - curved.value),
                      child: Image.asset(
                        "assets/butterfly.gif",
                        width: 80 + index * 10,
                      ),
                    ),
                  );
                },
              );
            }),

            Positioned(
              bottom: 290,
              left: 160,
              child: Shimmer.fromColors(
                baseColor: Colors.black,
                highlightColor: Colors.greenAccent,
                child: Text(
                  'Loading...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Signature
            Positioned(
              bottom: 40,
              right: 30,
              child: AnimatedBuilder(
                animation: _signatureController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      10 * (1 - _signatureAnimation.value).clamp(0.0, 1.0),
                    ), // slight bounce
                    child: Opacity(
                      opacity: _signatureAnimation.value.clamp(
                        0.0,
                        1.0,
                      ), // Clamp to avoid range issues
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 102, 138, 45).withOpacity(
                                0.3 +
                                    0.3 *
                                        _signatureAnimation.value.clamp(
                                          0.0,
                                          1.0,
                                        ),
                              ),
                              blurRadius:
                                  10 +
                                  4 * _signatureAnimation.value.clamp(0.0, 1.0),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          'Saurabh Kumar Verma',
                          style: TextStyle(
                            fontFamily: "Sign1",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
