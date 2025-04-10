import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signup_login_page/screen/Seller/SellerDashboard.dart';
import 'package:signup_login_page/screen/home.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  bool isLoading = false;
  bool isFetching = true;

  bool showPhoneField = false;
  bool showAddressField = false;
  bool showPincodeField = false;

  @override
  void initState() {
    super.initState();
    _fetchUserFields();
  }

  Future<void> _fetchUserFields() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if ((data['phoneNumber'] ?? "").toString().isEmpty) {
        showPhoneField = true;
      }
      if ((data['address'] ?? "").toString().isEmpty) {
        showAddressField = true;
      }
      if ((data['pincode'] ?? "").toString().isEmpty) {
        showPincodeField = true;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching profile data: $e")),
      );
    } finally {
      setState(() {
        isFetching = false;
      });
    }
  }

  void _updateProfile() async {
    Map<String, dynamic> updates = {};

    // Check if any visible field is empty
    if ((showPhoneField && _phoneController.text.isEmpty) ||
        (showAddressField && _addressController.text.isEmpty) ||
        (showPincodeField && _pincodeController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All visible fields are required!")),
      );
      return;
    }

    // Validators
    if (showPhoneField) {
      String phone = _phoneController.text.trim();
      if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Enter a valid 10-digit phone number.")),
        );
        return;
      }
      updates['phoneNumber'] = phone;
    }

    if (showAddressField) {
      updates['address'] = _addressController.text.trim();
    }

    if (showPincodeField) {
      String pincode = _pincodeController.text.trim();
      if (!RegExp(r'^[0-9]{6}$').hasMatch(pincode)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Enter a valid 6-digit pincode.")),
        );
        return;
      }
      updates['pincode'] = pincode;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update(updates);

      DocumentSnapshot updatedUserDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .get();

      String userType = updatedUserDoc['userType'];

      if (userType == 'Seller') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SellerDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Update failed: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Complete Profile"),
        backgroundColor: const Color(0xFF2F8A2F),
        elevation: 0,
      ),
      body:
          isFetching
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (showPhoneField)
                      _buildInputField(
                        "Phone Number",
                        _phoneController,
                        TextInputType.phone,
                      ),
                    if (showPhoneField) const SizedBox(height: 16),
                    if (showAddressField)
                      _buildInputField(
                        "Address",
                        _addressController,
                        TextInputType.text,
                      ),
                    if (showAddressField) const SizedBox(height: 16),
                    if (showPincodeField)
                      _buildInputField(
                        "Pincode",
                        _pincodeController,
                        TextInputType.number,
                      ),
                    if (showPincodeField) const SizedBox(height: 25),
                    if (showPhoneField || showAddressField || showPincodeField)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF2F8A2F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              isLoading
                                  ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                  : const Text(
                                    "Update Profile",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      )
                    else
                      const Text(
                        "All required fields are already filled.",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    TextInputType inputType,
  ) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2F8A2F), width: 2),
        ),
      ),
    );
  }
}
