// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:signup_login_page/screen/home.dart';
// import 'package:signup_login_page/screen/login.dart';

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _sunController;
//   late AnimationController _plantController;
//   late Animation<double> _plantAnimation;
//   late AnimationController _grassController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // Sun Rotation Animation
//     _sunController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 5),
//     )..repeat(); // Infinite rotation

//     // Plant Growing Animation
//     _plantController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 3),
//     )..forward();

//     // Grass Animation Controller (used for the ScaleTransition)
//     _grassController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 2),
//     )..forward();

//     _plantAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _plantController, curve: Curves.easeInOut),
//     );

//     // Fade-in Effect for the title text
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _plantController, curve: Curves.easeIn));

//     // Navigation timer commented out
//     Timer(Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomePage()),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _sunController.dispose();
//     _plantController.dispose();
//     _grassController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.green[800]!, const Color.fromARGB(255, 117, 203, 121)!],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Rotating Sun in the Background
//             Positioned(
//               top: 120,
//               left: 20,
//               child: RotationTransition(
//                 turns: _sunController,
//                 child: SvgPicture.asset("assets/1sun.svg", width: 110),
//               ),
//             ),

//             // Center content: Plant, Title
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
//                     child: Text(
//                       "Go To Kisan",
//                       style: TextStyle(
//                         decoration: TextDecoration.underline,
//                         decorationColor: Colors.black,
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                         letterSpacing: 1.5,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Signature text positioned at the bottom right
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
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late Animation<double> _plantAnimation;
  late AnimationController _grassController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _sunController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )..repeat();

    _plantController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..forward();

    _grassController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..forward();

    _plantAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _plantController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _plantController, curve: Curves.easeIn));

    // Use a timer to allow the splash animations to play,
    // then check the authentication state.
    Timer(Duration(seconds: 3), _checkLoginAndNavigate);
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
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    }
  }

  @override
  void dispose() {
    _sunController.dispose();
    _plantController.dispose();
    _grassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            // Rotating sun background
            Positioned(
              top: 120,
              left: 20,
              child: RotationTransition(
                turns: _sunController,
                child: SvgPicture.asset("assets/1sun.svg", width: 110),
              ),
            ),
            // Center content: plant image and title
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
            // Signature text at the bottom right
            Positioned(
              bottom: 40,
              right: 30,
              child: Text(
                'Saurabh Kumar Verma',
                style: TextStyle(
                  fontFamily: "Sign1",
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
