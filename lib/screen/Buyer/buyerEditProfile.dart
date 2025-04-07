import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String address = '';
  String userType = '';

  bool isLoading = true;

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
          email = docSnapshot['email'] ?? '';
          address = docSnapshot['address'] ?? '';
          userType = docSnapshot['userType'] ?? '';
          isLoading = false;
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
              'email': email,
              'address': address,
              'userType': userType,
            });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pop(context); // Go back to the dashboard
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
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
                                value!.isEmpty
                                    ? 'Please enter your name'
                                    : null,
                        onSaved: (value) => name = value!,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        initialValue: email,
                        decoration: InputDecoration(labelText: 'Email'),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Please enter your email'
                                    : null,
                        onSaved: (value) => email = value!,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        initialValue: address,
                        decoration: InputDecoration(labelText: 'Address'),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Please enter your address'
                                    : null,
                        onSaved: (value) => address = value!,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        initialValue: userType,
                        decoration: InputDecoration(
                          labelText: 'Role (Buyer/Seller)',
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Please enter your role'
                                    : null,
                        onSaved: (value) => userType = value!,
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _updateData,
                        child: Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
