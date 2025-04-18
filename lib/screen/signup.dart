// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:signup_login_page/screen/login.dart';

// class Signup extends StatefulWidget {
//   const Signup({super.key});

//   @override
//   State<Signup> createState() => _SignupState();
// }

// class _SignupState extends State<Signup> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   final TextEditingController _phoneNumber = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _pincodeController = TextEditingController();

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String selectedOption = 'Buyer';
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isLoading = false;

//   bool _validatePhoneNumber() {
//     String phone = _phoneNumber.text.trim();
//     final regex = RegExp(r'^\d{10}$');
//     return regex.hasMatch(phone);
//   }

//   bool _validatePhoneNumberFormat() {
//     String phone = _phoneNumber.text.trim();
//     final regex = RegExp(r'^\d{10}$');
//     return phone.isEmpty || regex.hasMatch(phone);
//   }

//   bool _validatePincodeFormat() {
//     String pincode = _pincodeController.text.trim();
//     final regex = RegExp(r'^\d{6}$');
//     return pincode.isEmpty || regex.hasMatch(pincode);
//   }


//   bool _validateEmptyFields() {
//     return _nameController.text.trim().isEmpty ||
//         _emailController.text.trim().isEmpty ||
//         _passwordController.text.trim().isEmpty ||
//         _confirmPasswordController.text.trim().isEmpty;
//     // _phoneNumber.text.trim().isEmpty ||
//     // _addressController.text.trim().isEmpty ||
//     // _pincodeController.text.trim().isEmpty;
//   }

// void _signup() async {
//     if (_validateEmptyFields()) {
//       _showMessage("Please fill in all the required fields");
//       return;
//     }

//     if (_passwordController.text.trim() !=
//         _confirmPasswordController.text.trim()) {
//       _showMessage("Passwords do not match");
//       return;
//     }

//     if (!_validatePhoneNumberFormat()) {
//       _showMessage("Phone number must be 10 digits");
//       return;
//     }

//     if (!_validatePincodeFormat()) {
//       _showMessage("Pincode must be 6 digits");
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       UserCredential userCredential = await _auth
//           .createUserWithEmailAndPassword(
//             email: _emailController.text.trim(),
//             password: _passwordController.text.trim(),
//           );

//       User? user = userCredential.user;

//       if (user != null) {
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//           'name': _nameController.text.trim(),
//           'email': user.email,
//           'userType': selectedOption,
//           'address': _addressController.text.trim(),
//           'phoneNumber': _phoneNumber.text.trim(),
//           'pincode': _pincodeController.text.trim(),
//         });

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const Login()),
//         );
//       }
//     } catch (e) {
//       _showMessage("Signup failed: ${e.toString()}");
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }


//   void _showMessage(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   void _togglePasswordView(bool isPassword) {
//     setState(() {
//       if (isPassword) {
//         _obscurePassword = !_obscurePassword;
//       } else {
//         _obscureConfirmPassword = !_obscureConfirmPassword;
//       }
//     });
//   }

//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     IconData? icon,
//     bool obscureText = false,
//     VoidCallback? onToggle,
//     bool isRequired = true,
//     TextInputType? keyboardType,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: TextField(
//         controller: controller,
//         obscureText: obscureText,
//         keyboardType: keyboardType ?? TextInputType.text,
//         decoration: InputDecoration(
//           labelText: "$label ${isRequired ? "*" : "(Optional)"}",
//           labelStyle: TextStyle(
//             color: Colors.grey[700],
//             fontWeight: FontWeight.w500,
//           ),
//           floatingLabelStyle: TextStyle(
//             color: Colors.green[700],
//             fontWeight: FontWeight.bold,
//           ),
//           suffixIcon:
//               onToggle != null
//                   ? IconButton(
//                     icon: Icon(
//                       obscureText ? Icons.visibility_off : Icons.visibility,
//                       color: Colors.green,
//                     ),
//                     onPressed: onToggle,
//                   )
//                   : null,
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.grey),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.green, width: 2),
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 16,
//             horizontal: 12,
//           ),
//         ),
//         style: const TextStyle(fontSize: 16),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         double maxWidth = constraints.maxWidth > 600 ? 600 : double.infinity;

//         return Scaffold(
//           backgroundColor: const Color.fromARGB(241, 202, 242, 202),
//           body: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(maxWidth: maxWidth),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header
//                     Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Image.asset('assets/farmer.gif', width: 140),
//                           const SizedBox(width: 10),
//                           Image.asset('assets/farmer1.gif', width: 140),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       "Sign up",
//                       style: TextStyle(
//                         fontSize: 35,
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 88, 84, 84),
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     _buildTextField(label: "Name", controller: _nameController),

//                     _buildTextField(
//                       label: "Email",
//                       controller: _emailController,
//                       keyboardType: TextInputType.emailAddress,
//                     ),

//                     _buildTextField(
//                       label: "Password",
//                       controller: _passwordController,
//                       obscureText: _obscurePassword,
//                       onToggle: () => _togglePasswordView(true),
//                     ),

//                     _buildTextField(
//                       label: "Confirm Password",
//                       controller: _confirmPasswordController,
//                       obscureText: _obscureConfirmPassword,
//                       onToggle: () => _togglePasswordView(false),
//                     ),

//                     _buildTextField(
//                       label: "Phone Number",
//                       controller: _phoneNumber,
//                       keyboardType: TextInputType.phone,
//                       isRequired: false,
//                     ),

//                     _buildTextField(
//                       label: "Pincode",
//                       controller: _pincodeController,
//                       keyboardType: TextInputType.number,
//                       isRequired: false,
//                     ),

//                     _buildTextField(
//                       label: "Exact Address",
//                       controller: _addressController,
//                       isRequired: false,
//                     ),

//                     const SizedBox(height: 15),

//                     Row(
//                       children: [
//                         const Text("Select Your Field: "),
//                         const SizedBox(width: 10),
//                         DropdownButton<String>(
//                           value: selectedOption,
//                           onChanged: (String? newValue) {
//                             setState(() {
//                               selectedOption = newValue!;
//                             });
//                           },
//                           items:
//                               ['Buyer', 'Seller'].map((String value) {
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Text(value),
//                                 );
//                               }).toList(),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 30),

//                     GestureDetector(
//                       onTap: () {
//                         if (!_isLoading) {
//                           _signup();
//                         }
//                       },
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.green,
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: Center(
//                           child:
//                               _isLoading
//                                   ? const CircularProgressIndicator(
//                                     color: Colors.white,
//                                   )
//                                   : const Text(
//                                     "Sign Up",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text("Already have an account? "),
//                         GestureDetector(
//                           onTap:
//                               () => Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const Login(),
//                                 ),
//                               ),
//                           child: const Text(
//                             "LogIn",
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signup_login_page/screen/login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with SingleTickerProviderStateMixin {
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

  late AnimationController _animationController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _validatePhoneNumberFormat() {
    final regex = RegExp(r'^\d{10}$');
    return _phoneNumber.text.trim().isEmpty ||
        regex.hasMatch(_phoneNumber.text.trim());
  }

  bool _validatePincodeFormat() {
    final regex = RegExp(r'^\d{6}$');
    return _pincodeController.text.trim().isEmpty ||
        regex.hasMatch(_pincodeController.text.trim());
  }

  bool _validateEmptyFields() {
    return _nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty;
  }

  void _signup() async {
    if (_validateEmptyFields()) {
      _showMessage("Please fill in all required fields");
      return;
    }

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      _showMessage("Passwords do not match");
      return;
    }

    if (!_validatePhoneNumberFormat()) {
      _showMessage("Phone number must be 10 digits");
      return;
    }

    if (!_validatePincodeFormat()) {
      _showMessage("Pincode must be 6 digits");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': user.email,
          'userType': selectedOption,
          'address': _addressController.text.trim(),
          'phoneNumber': _phoneNumber.text.trim(),
          'pincode': _pincodeController.text.trim(),
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    } catch (e) {
      _showMessage("Signup failed: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    setState(() => _isLoading = false);
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool obscureText = false,
    VoidCallback? onToggle,
    bool isRequired = true,
    TextInputType? keyboardType,
    bool? isValid,
    ValueChanged<String>? onChanged,
  }) {
    Icon? validationIcon;
    if (isValid != null) {
      validationIcon =
          isValid
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.cancel, color: Colors.red);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        style: TextStyle(color: Colors.black),
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: "$label ${isRequired ? "*" : "(Optional)"}",
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
          suffixIcon:
              onToggle != null
                  ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.green,
                    ),
                    onPressed: onToggle,
                  )
                  : validationIcon,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.green, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
    double maxWidth =
        MediaQuery.of(context).size.width > 600 ? 600 : double.infinity;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 255, 237),
      body: FadeTransition(
        opacity: _fadeIn,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 25,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      spreadRadius: 4,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/farmer.gif', width: 120),
                        const SizedBox(width: 12),
                        Image.asset('assets/farmer1.gif', width: 120),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Create Your Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildTextField(label: "Name", controller: _nameController),
                    _buildTextField(
                      label: "Email",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      isValid: _emailController.text.contains('@'),
                      onChanged: (_) => setState(() {}),
                    ),
                    _buildTextField(
                      label: "Password",
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onToggle:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                    ),
                    _buildTextField(
                      label: "Confirm Password",
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      onToggle:
                          () => setState(
                            () =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                          ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Register As:",
                          style: TextStyle(fontWeight: FontWeight.w600,
                            color: isDark ? const Color.fromARGB(255, 100, 98, 98) : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedOption,
                          onChanged:
                              (val) => setState(() => selectedOption = val!),
                          
                            dropdownColor:
                              isDark
                                  ? Colors.grey[900]
                                  : Colors.white, // optional: dropdown bg color

                          items:
                              ['Buyer', 'Seller']
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type,style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.green
                                                  :Color.fromARGB(
                                                    255,
                                                    100,
                                                    98,
                                                    98,
                                                  ),
                                        ),),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    _buildTextField(
                      label: "Phone Number",
                      controller: _phoneNumber,
                      keyboardType: TextInputType.phone,
                      isRequired: false,
                      isValid: _validatePhoneNumberFormat(),
                      onChanged: (_) => setState(() {}),
                    ),
                    _buildTextField(
                      label: "Pincode",
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      isRequired: false,
                      isValid: _validatePincodeFormat(),
                      onChanged: (_) => setState(() {}),
                    ),
                    _buildTextField(
                      label: "Exact Address",
                      controller: _addressController,
                      isRequired: false,
                    ),

                    const SizedBox(height: 10),
                    
                    GestureDetector(
                      onTap: () => !_isLoading ? _signup() : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color:
                              _isLoading ? Colors.green.shade300 : Colors.green,
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ",style: TextStyle(color: isDark ? Colors.black: Colors.white),),
                        GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Login(),
                                ),
                              ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
