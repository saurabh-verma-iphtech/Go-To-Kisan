// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class EditSellerProfileScreen extends StatefulWidget {
//   @override
//   _EditSellerProfileScreenState createState() =>
//       _EditSellerProfileScreenState();
// }

// class _EditSellerProfileScreenState extends State<EditSellerProfileScreen> {
//   final _formKey = GlobalKey<FormState>();

//   String name = '';
//   String address = '';
//   String phone = '';
//   String pincode = '';
//   bool isLoading = true;
//   bool formVisible = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSellerData();
//   }

//   Future<void> _fetchSellerData() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       var docSnapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user.uid)
//               .get();

//       if (docSnapshot.exists) {
//         setState(() {
//           name = docSnapshot['name'] ?? '';
//           phone = docSnapshot['phoneNumber'] ?? '';
//           address = docSnapshot['address'] ?? '';
//           pincode = docSnapshot['pincode'] ?? '';
//           isLoading = false;
//         });

//         Future.delayed(Duration(milliseconds: 200), () {
//           setState(() {
//             formVisible = true;
//           });
//         });
//       }
//     }
//   }

//   Future<void> _updateSellerData() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       User? user = FirebaseAuth.instance.currentUser;

//       if (user != null) {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .update({
//               'name': name,
//               'phoneNumber': phone,
//               'address': address,
//               'pincode': pincode,
//             });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Seller profile updated successfully!')),
//         );

//         Navigator.pop(context);
//       }
//     }
//   }

//   Widget buildTextField({
//     required String label,
//     required IconData icon,
//     required String initialValue,
//     required FormFieldSetter<String> onSaved,
//     required FormFieldValidator<String> validator,
//     TextInputType keyboardType = TextInputType.text,
//     List<TextInputFormatter>? inputFormatters,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: TextFormField(
//         initialValue: initialValue,
//         keyboardType: keyboardType,
//         inputFormatters: inputFormatters,
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon, color: Colors.green),
//           labelText: label,
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 18,
//             horizontal: 15,
//           ),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         validator: validator,
//         onSaved: onSaved,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7FFF7),
//       appBar: AppBar(
//         title: const Text('Edit Seller Profile'),
//         backgroundColor: const Color.fromARGB(255, 47, 138, 47),
//         elevation: 4,
//       ),
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: AnimatedOpacity(
//                   opacity: formVisible ? 1.0 : 0.0,
//                   duration: const Duration(milliseconds: 500),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 500),
//                     curve: Curves.easeInOut,
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade50,
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.green.shade100,
//                           blurRadius: 10,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           Text(
//                             "Update your profile details below",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[800],
//                             ),
//                           ),
//                           const SizedBox(height: 25),
//                           buildTextField(
//                             label: "Name",
//                             icon: Icons.person,
//                             initialValue: name,
//                             validator:
//                                 (value) =>
//                                     value!.isEmpty ? 'Please enter name' : null,
//                             onSaved: (value) => name = value!,
//                           ),
//                           buildTextField(
//                             label: "Address",
//                             icon: Icons.home,
//                             initialValue: address,
//                             validator:
//                                 (value) =>
//                                     value!.isEmpty
//                                         ? 'Please enter address'
//                                         : null,
//                             onSaved: (value) => address = value!,
//                           ),
//                           buildTextField(
//                             label: "Phone Number",
//                             icon: Icons.phone,
//                             initialValue: phone,
//                             keyboardType: TextInputType.number,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                             ],
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter phone number';
//                               } else if (value.length != 10) {
//                                 return 'Phone number must be 10 digits';
//                               }
//                               return null;
//                             },
//                             onSaved: (value) => phone = value!,
//                           ),
//                           buildTextField(
//                             label: "Pincode",
//                             icon: Icons.pin_drop,
//                             initialValue: pincode,
//                             keyboardType: TextInputType.number,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                             ],
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter pincode';
//                               } else if (value.length != 6) {
//                                 return 'Pincode must be 6 digits';
//                               }
//                               return null;
//                             },
//                             onSaved: (value) => pincode = value!,
//                           ),
//                           const SizedBox(height: 30),
//                           ElevatedButton.icon(
//                             onPressed: _updateSellerData,
//                             icon: Icon(Icons.save),
//                             label: const Text('Save Changes'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Color.fromARGB(255, 47, 138, 47),
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 30,
//                                 vertical: 15,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 8,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditSellerProfileScreen extends StatefulWidget {
  @override
  _EditSellerProfileScreenState createState() =>
      _EditSellerProfileScreenState();
}

class _EditSellerProfileScreenState extends State<EditSellerProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  String name = '';
  String address = '';
  String phone = '';
  String pincode = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _fetchSellerData();
  }

  Future<void> _fetchSellerData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        setState(() {
          name = doc['name'] ?? '';
          phone = doc['phoneNumber'] ?? '';
          address = doc['address'] ?? '';
          pincode = doc['pincode'] ?? '';
          isLoading = false;
        });

        _animationController.forward();
      }
    }
  }

  Future<void> _updateSellerData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'name': name,
              'phoneNumber': phone,
              'address': address,
              'pincode': pincode,
            });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pop(context);
      }
    }
  }

  Widget buildTextField({
    required String label,
    required IconData icon,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          labelText: label,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 15,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        title: Text(
          'Edit Seller Profile',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
        elevation: 2,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : FadeTransition(
                opacity: _fadeInAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Update your seller profile",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          SizedBox(height: 25),
                          buildTextField(
                            label: "Name",
                            icon: Icons.person,
                            initialValue: name,
                            validator:
                                (value) =>
                                    value!.isEmpty ? 'Please enter name' : null,
                            onSaved: (value) => name = value!,
                          ),
                          buildTextField(
                            label: "Address",
                            icon: Icons.home,
                            initialValue: address,
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Please enter address'
                                        : null,
                            onSaved: (value) => address = value!,
                          ),
                          buildTextField(
                            label: "Phone Number",
                            icon: Icons.phone,
                            initialValue: phone,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              } else if (value.length != 10) {
                                return 'Phone number must be 10 digits';
                              }
                              return null;
                            },
                            onSaved: (value) => phone = value!,
                          ),
                          buildTextField(
                            label: "Pincode",
                            icon: Icons.pin_drop,
                            initialValue: pincode,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter pincode';
                              } else if (value.length != 6) {
                                return 'Pincode must be 6 digits';
                              }
                              return null;
                            },
                            onSaved: (value) => pincode = value!,
                          ),
                          const SizedBox(height: 25),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _updateSellerData,
                              icon: Icon(Icons.save),
                              label: const Text('Save Changes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 6,
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
