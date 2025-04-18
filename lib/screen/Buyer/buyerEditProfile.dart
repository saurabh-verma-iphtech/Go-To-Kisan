// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class EditProfileScreen extends StatefulWidget {
//   @override
//   _EditProfileScreenState createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();

//   String name = '';
//   String phone = '';
//   String address = '';
//   String pincode = '';

//   bool isLoading = true;
//   bool showForm = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCurrentData();
//   }

//   Future<void> _fetchCurrentData() async {
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

//         Future.delayed(Duration(milliseconds: 300), () {
//           setState(() {
//             showForm = true;
//           });
//         });
//       }
//     }
//   }

//   Future<void> _updateData() async {
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
//           SnackBar(content: Text('Profile updated successfully!')),
//         );

//         Navigator.pop(context);
//       }
//     }
//   }

//   Widget buildTextField({
//     required String label,
//     required String initialValue,
//     required IconData icon,
//     required TextInputType inputType,
//     List<TextInputFormatter>? inputFormatters,
//     required FormFieldValidator<String> validator,
//     required FormFieldSetter<String> onSaved,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: TextFormField(
//         initialValue: initialValue,
//         keyboardType: inputType,
//         inputFormatters: inputFormatters,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon, color: Colors.green),
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
//         iconTheme: const IconThemeData(
//           color: Colors.white, // <-- This changes the back arrow color
//         ),
//         title: const Text('Edit Profile',style: TextStyle(color: Colors.white),),
//         backgroundColor: Color(0xFF2E7D32),
//       ),
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : AnimatedOpacity(
//                 opacity: showForm ? 1.0 : 0.0,
//                 duration: const Duration(milliseconds: 500),
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(20),
//                   child: Form(
//                     key: _formKey,
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 500),
//                       curve: Curves.easeInOut,
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.green.shade50,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.green.shade100,
//                             blurRadius: 12,
//                             spreadRadius: 2,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           buildTextField(
//                             label: "Name",
//                             icon: Icons.person,
//                             initialValue: name,
//                             inputType: TextInputType.name,
//                             validator:
//                                 (value) =>
//                                     value!.isEmpty
//                                         ? 'Please enter your name'
//                                         : null,
//                             onSaved: (value) => name = value!,
//                           ),
//                           buildTextField(
//                             label: "Address",
//                             icon: Icons.home,
//                             initialValue: address,
//                             inputType: TextInputType.streetAddress,
//                             validator:
//                                 (value) =>
//                                     value!.isEmpty
//                                         ? 'Please enter your address'
//                                         : null,
//                             onSaved: (value) => address = value!,
//                           ),
//                           buildTextField(
//                             label: "Phone Number",
//                             icon: Icons.phone,
//                             initialValue: phone,
//                             inputType: TextInputType.phone,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                             ],
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter your phone number';
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
//                             inputType: TextInputType.number,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                             ],
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter your pincode';
//                               } else if (value.length != 6) {
//                                 return 'Pincode must be 6 digits';
//                               }
//                               return null;
//                             },
//                             onSaved: (value) => pincode = value!,
//                           ),
//                           const SizedBox(height: 30),
//                           ElevatedButton.icon(
//                             onPressed: _updateData,
//                             icon: const Icon(Icons.save),
//                             label: const Text('Save Changes'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green.shade700,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 30,
//                                 vertical: 15,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               elevation: 10,
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

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String phone = '';
  String address = '';
  String pincode = '';

  bool isLoading = true;
  bool showForm = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentData();
  }

  Future<void> _fetchCurrentData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var docSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (docSnapshot.exists) {
        setState(() {
          name = docSnapshot['name'] ?? '';
          phone = docSnapshot['phoneNumber'] ?? '';
          address = docSnapshot['address'] ?? '';
          pincode = docSnapshot['pincode'] ?? '';
          isLoading = false;
        });

        Future.delayed(Duration(milliseconds: 300), () {
          setState(() {
            showForm = true;
          });
        });
      }
    }
  }

  Future<void> _updateData() async {
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
    required String initialValue,
    required IconData icon,
    required TextInputType inputType,
    List<TextInputFormatter>? inputFormatters,
    required FormFieldValidator<String> validator,
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Theme.of(context).textTheme.bodyMedium,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : AnimatedOpacity(
                opacity: showForm ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.1),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          buildTextField(
                            label: "Name",
                            icon: Icons.person,
                            initialValue: name,
                            inputType: TextInputType.name,
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Please enter your name'
                                        : null,
                            onSaved: (value) => name = value!,
                          ),
                          buildTextField(
                            label: "Address",
                            icon: Icons.home,
                            initialValue: address,
                            inputType: TextInputType.streetAddress,
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Please enter your address'
                                        : null,
                            onSaved: (value) => address = value!,
                          ),
                          buildTextField(
                            label: "Phone Number",
                            icon: Icons.phone,
                            initialValue: phone,
                            inputType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
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
                            inputType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your pincode';
                              } else if (value.length != 6) {
                                return 'Pincode must be 6 digits';
                              }
                              return null;
                            },
                            onSaved: (value) => pincode = value!,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: _updateData,
                            icon: const Icon(Icons.save),
                            label: const Text('Save Changes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 10,
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
