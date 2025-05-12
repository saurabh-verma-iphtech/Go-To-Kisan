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
      duration: Duration(seconds: 4),
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

    Timer(Duration(seconds: 4), _checkLoginAndNavigate);
  }

  Future<void> _checkLoginAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');

    final user = await FirebaseAuth.instance.authStateChanges().first;

    if (user == null) {
      await prefs.remove('userRole');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          return Container(
            width: double.infinity,
            height: double.infinity,
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
                // Rotating Sun
                Positioned(
                  top: screenHeight * 0.14,
                  left: screenWidth * 0.05,
                  child: RotationTransition(
                    turns: _sunController,
                    child: SvgPicture.asset(
                      "assets/1sun.svg",
                      width: screenWidth * 0.2,
                    ),
                  ),
                ),

                // Background Clouds
                AnimatedBuilder(
                  animation: _sunController,
                  builder: (context, child) {
                    final dx = (screenWidth + 240) * _sunController.value - 120;
                    return Positioned(
                      top: screenHeight * 0.03,
                      left: -dx,
                      child: Row(
                        children: List.generate(5, (index) {
                          return Row(
                            children: [
                              Opacity(
                                opacity: 0.25,
                                child: SvgPicture.asset(
                                  "assets/clouds1.svg",
                                  width: screenWidth * 0.18,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.08),
                            ],
                          );
                        }),
                      ),
                    );
                  },
                ),

                // Foreground Clouds
                AnimatedBuilder(
                  animation: _sunController,
                  builder: (context, child) {
                    final dx = (screenWidth + 240) * _sunController.value - 120;
                    return Positioned(
                      top: screenHeight * 0.07,
                      left: -dx / 0.7,
                      child: Row(
                        children: List.generate(5, (index) {
                          return Row(
                            children: [
                              Opacity(
                                opacity: 0.4,
                                child: SvgPicture.asset(
                                  "assets/clouds1.svg",
                                  width: screenWidth * 0.22,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.08),
                            ],
                          );
                        }),
                      ),
                    );
                  },
                ),

                // Bird 1
                AnimatedBuilder(
                  animation: _birdController,
                  builder: (context, child) {
                    final birdX = screenWidth * _birdController.value;
                    return Positioned(
                      top:
                          screenHeight * 0.12 +
                          30 * sin(_birdController.value * 2 * pi),
                      left: birdX - 50,
                      child: Image.asset(
                        "assets/birds2.gif",
                        width: screenWidth * 0.3,
                        height: screenHeight * 0.1,
                      ),
                    );
                  },
                ),

                // Bird 2
                AnimatedBuilder(
                  animation: _bird2Controller,
                  builder: (context, child) {
                    final birdX = screenWidth * _bird2Controller.value;
                    return Positioned(
                      top:
                          screenHeight * 0.2 +
                          20 * sin(_bird2Controller.value * 2 * pi),
                      left: birdX - 50,
                      child: Image.asset(
                        "assets/birds2.gif",
                        width: screenWidth * 0.3,
                        height: screenHeight * 0.1,
                      ),
                    );
                  },
                ),

                // Centered Plant and Title
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _grassController,
                        child: SvgPicture.asset(
                          "assets/field.svg",
                          width: screenWidth * 0.35,
                        ),
                      ),
                      // SizedBox(height: screenHeight * 0.0001),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: FittedBox(
                          child: Text(
                            "Go To Kisan",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.black,
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Butterfly animations
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
                    animation: curved,
                    builder: (context, child) {
                      final dx = screenWidth * curved.value;
                      final dy =
                          screenHeight * 0.43 +
                          index * 40 +
                          20 *
                              (index.isEven ? 1 : -1) *
                              (1 - curved.value).abs();

                      return Positioned(
                        top: dy,
                        left: dx - 100,
                        child: Transform.rotate(
                          angle: 0.2 * (1 - curved.value),
                          child: Image.asset(
                            "assets/butterfly.gif",
                            width: screenWidth * 0.15,
                          ),
                        ),
                      );
                    },
                  );
                }),

                // Loading Text (moved slightly below title)
                Positioned(
                  top: screenHeight * 0.63,
                  left: screenWidth * 0.4,
                  child: Shimmer.fromColors(
                    baseColor: Colors.black,
                    highlightColor: Colors.greenAccent,
                    child: Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Signature
                Positioned(
                  bottom: screenHeight * 0.05,
                  right: screenWidth * 0.08,
                  child: AnimatedBuilder(
                    animation: _signatureController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          10 * (1 - _signatureAnimation.value).clamp(0.0, 1.0),
                        ),
                        child: Opacity(
                          opacity: _signatureAnimation.value.clamp(0.0, 1.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    255,
                                    102,
                                    138,
                                    45,
                                  ).withOpacity(
                                    0.3 +
                                        0.3 *
                                            _signatureAnimation.value.clamp(
                                              0.0,
                                              1.0,
                                            ),
                                  ),
                                  blurRadius:
                                      10 +
                                      4 *
                                          _signatureAnimation.value.clamp(
                                            0.0,
                                            1.0,
                                          ),
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Text(
                              'Saurabh Kumar Verma',
                              style: TextStyle(
                                fontFamily: "Sign1",
                                fontSize: screenWidth * 0.035,
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
          );
        },
      ),
    );
  }
}
