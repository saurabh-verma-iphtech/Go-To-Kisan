import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signup_login_page/screen/Seller/SellerDashboard.dart';
import 'package:signup_login_page/screen/home.dart';
import 'package:signup_login_page/screen/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  bool _obscurePassword = true;

  
  void _togglePasswordView() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login() async {
    setState(() {
      isLoading = true;
    });

    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar("Invalid email address");
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar("Password cannot be empty");
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userDoc.exists && userDoc.data() != null) {
          var userType = userDoc['userType'];
          if (userType != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            if (userType == 'Buyer') {
              await prefs.setString('userRole', 'buyer');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            } else if (userType == 'Seller') {
              await prefs.setString('userRole', 'seller');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SellerDashboard()),
              );
            }
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password. Please try again.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      }
      _showSnackBar(errorMessage);
    } catch (e) {
      _showSnackBar("Login failed: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double fontSize = width * 0.05;
          double inputFontSize = width * 0.045;
          double buttonWidth = width * 0.4;

          return SingleChildScrollView(
            child: Container(
              height: screen.height,
              width: screen.width,
              color: Color.fromARGB(241, 202, 242, 202),
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: screen.height * 0.14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/farmer.gif', width: width * 0.4),
                      Image.asset('assets/farmer1.gif', width: width * 0.4),
                    ],
                  ),
                  SizedBox(height: screen.height * 0.04),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome!",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "LogIn",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 30),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Enter Email",
                          hintStyle: TextStyle(fontSize: inputFontSize/1.2),
                          suffixIcon: Icon(Icons.email, color: Colors.green),
                        ),
                        style: TextStyle(fontSize: inputFontSize),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          hintStyle: TextStyle(fontSize: inputFontSize / 1.2),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.green,
                            ),
                            onPressed: _togglePasswordView,
                          ),
                        ),
                        style: TextStyle(fontSize: inputFontSize),
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (!isLoading) {
                                    // setState(() {
                                    //   _isLoading = true;
                                    // });
                                    _login();
                                  }
                                },
                                child: Container(
                                  width: buttonWidth * 2,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Log In",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: inputFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Don't have an account yet ?",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: inputFontSize/1.3,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Signup(),
                                    ),
                                  );
                                },
                                child: Center(
                                  child: Text(
                                    "Create an account",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: inputFontSize/1.2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
