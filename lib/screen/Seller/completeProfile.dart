import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String userId;
  CompleteProfileScreen(this.userId);

  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  bool isLoading = false;

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
            'state': _stateController.text.trim(),
            'city': _cityController.text.trim(),
            'pincode': _pincodeController.text.trim(),
          });

      Navigator.pop(context); // Return to Seller Profile after updating
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complete Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(labelText: "State"),
                validator:
                    (value) => value!.isEmpty ? "State is required" : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: "City"),
                validator:
                    (value) => value!.isEmpty ? "City is required" : null,
              ),
              TextFormField(
                controller: _pincodeController,
                decoration: InputDecoration(labelText: "Pincode"),
                validator:
                    (value) => value!.isEmpty ? "Pincode is required" : null,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text("Save"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
