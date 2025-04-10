import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signup_login_page/screen/CompleteProfilePage.dart';
import 'package:signup_login_page/screen/Seller/SellerDashboard.dart';
import 'package:signup_login_page/screen/home.dart';
import 'package:signup_login_page/screen/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  void _togglePasswordView() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() => isLoading = true);
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showSnackBar("Invalid email address");
      setState(() => isLoading = false);
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showSnackBar("Password cannot be empty");
      setState(() => isLoading = false);
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

        var userType = userDoc['userType'];
        var phone = userDoc['phoneNumber'] ?? '';
        var address = userDoc['address'] ?? '';
        var pincode = userDoc['pincode'] ?? '';

        if (phone == "" || address == "" || pincode == "") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CompleteProfilePage()),
          );
          return;
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (userType == 'Buyer') {
          await prefs.setString('userRole', 'buyer');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          await prefs.setString('userRole', 'seller');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SellerDashboard()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String msg = switch (e.code) {
        'user-not-found' => "No user found with this email.",
        'wrong-password' => "Incorrect password. Please try again.",
        'invalid-email' => "Invalid email format.",
        _ => "Login failed. Please try again.",
      };
      _showSnackBar(msg);
    } catch (e) {
      _showSnackBar("Login failed: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
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
      backgroundColor: const Color(0xFFF1FFF1),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 50),
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/farmer.gif', height: screen.height * 0.25),
                const SizedBox(height: 20),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Welcome Back 👋",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Email Address",
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.green,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.green,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: _togglePasswordView,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child:
                            isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Log In",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Signup()),
                          );
                        },
                        child: const Text(
                          "Create an Account",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
