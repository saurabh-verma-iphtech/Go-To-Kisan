import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditSellerProfileScreen extends StatefulWidget {
  @override
  _EditSellerProfileScreenState createState() =>
      _EditSellerProfileScreenState();
}

class _EditSellerProfileScreenState extends State<EditSellerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  // String email = '';
  String address = '';
  String phone = '';
  String pincode = '';
  // String userType = '';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSellerData();
  }

  Future<void> _fetchSellerData() async {
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
          SnackBar(content: Text('Seller profile updated successfully!')),
        );

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Seller Profile'),
        backgroundColor: Color.fromARGB(255, 47, 138, 47),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: name,
                        decoration: InputDecoration(labelText: 'Name'),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Please enter name' : null,
                        onSaved: (value) => name = value!,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        initialValue: phone,
                        decoration: InputDecoration(labelText: 'Phone'),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Please enter email' : null,
                        onSaved: (value) => phone = value!,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        initialValue: address,
                        decoration: InputDecoration(labelText: 'Address'),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Please enter address' : null,
                        onSaved: (value) => address = value!,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        initialValue: pincode,
                        decoration: InputDecoration(
                          labelText: 'Pincode',
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Please enter role' : null,
                        onSaved: (value) => pincode = value!,
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(
                            Colors.white,
                          ), // Text color
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>((
                                Set<WidgetState> states,
                              ) {
                                if (states.contains(WidgetState.pressed)) {
                                  return Color.fromARGB(
                                    255,
                                    47,
                                    138,
                                    47,
                                  ); // Color when pressed
                                }
                                return Color.fromARGB(
                                  255,
                                  47,
                                  138,
                                  47,
                                ); // Default color
                              }),
                          shadowColor: WidgetStateProperty.all(Colors.black),
                          elevation: WidgetStateProperty.all(8), // Elevation
                          padding: WidgetStateProperty.all(
                            EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        onPressed: _updateSellerData,
                        child: Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
