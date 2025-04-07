import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signup_login_page/screen/login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedOption = 'Buyer';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  bool _validatePhoneNumber() {
    String phone = _phoneNumber.text.trim();
    final regex = RegExp(r'^\d{10}$');
    return regex.hasMatch(phone);
  }




  bool _validateEmptyFields() {
    return _nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty ||
        _phoneNumber.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _pincodeController.text.trim().isEmpty;
  }

  void _signup() async {
    if (_validateEmptyFields()) {
      _showMessage("Please fill in all the required fields");
      return;
    }

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      _showMessage("Passwords do not match");
      return;
    }

    if (!_validatePhoneNumber()) {
      _showMessage("Phone number must be 10 digits");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': user.email,
          'userType': selectedOption,
          'address': _addressController.text.trim(),
          'phoneNumber': _phoneNumber.text.trim().replaceAll(RegExp(r'\D'), ''),
          'pincode': _pincodeController.text.trim(),
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } catch (e) {
      _showMessage("Signup failed: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    setState(() {
      _isLoading = false;
    });
  }

  void _togglePasswordView(bool isPassword) {
    setState(() {
      if (isPassword) {
        _obscurePassword = !_obscurePassword;
      } else {
        _obscureConfirmPassword = !_obscureConfirmPassword;
      }
    });
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    IconData? icon,
    bool obscureText = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 16),
        suffixIcon:
            onToggle != null
                ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.green,
                  ),
                  onPressed: onToggle,
                )
                : icon != null
                ? Icon(icon, color: Colors.green)
                : null,
      ),
      style: const TextStyle(fontSize: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth > 600 ? 600 : double.infinity;

        return Scaffold(
          backgroundColor: const Color.fromARGB(241, 202, 242, 202),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/farmer.gif', width: 140),
                          const SizedBox(width: 10),
                          Image.asset('assets/farmer1.gif', width: 140),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 88, 84, 84),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      hintText: "Enter Name",
                      controller: _nameController,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      hintText: "Enter Email",
                      controller: _emailController,
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      hintText: "Enter Password",
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onToggle: () => _togglePasswordView(true),
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      hintText: "Confirm Password",
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      onToggle: () => _togglePasswordView(false),
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        const Text("Select Your Field: "),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedOption,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedOption = newValue!;
                            });
                          },
                          items:
                              ['Buyer', 'Seller'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      hintText: "Enter Phone Number",
                      controller: _phoneNumber,
                      icon: Icons.call,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      hintText: "Enter Pincode",
                      controller: _pincodeController,
                      icon: Icons.pin,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),

                    _buildTextField(
                      hintText: "Enter Exact Address",
                      controller: _addressController,
                      icon: Icons.location_on,
                    ),
                    const SizedBox(height: 30),

                    GestureDetector(
                      onTap: () {
                        if (!_isLoading) {
                          _signup();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Login(),
                                ),
                              ),
                          child: const Text(
                            "LogIn",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
