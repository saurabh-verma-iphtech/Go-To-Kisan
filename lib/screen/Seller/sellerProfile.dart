import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signup_login_page/screen/login.dart';
import 'package:signup_login_page/screen/Seller/sellerEditProfilePage.dart';

class SellerProfile extends StatefulWidget {
  @override
  _SellerProfileState createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile> {
  String sellerName = "";
  String sellerEmail = "";
  String sellerAddress = "";
  String sellerRole = "";
  String sellerNumber = "";
  String sellerPincode = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getSellerDetails();
  }

  Future<void> _getSellerDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      var userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      var docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        setState(() {
          sellerName = docSnapshot['name'] ?? 'No Name';
          sellerEmail = docSnapshot['email'] ?? 'No Email';
          sellerAddress = docSnapshot['address'] ?? 'No Address';
          sellerRole = docSnapshot['userType'] ?? 'No Role';
          sellerNumber = docSnapshot['phoneNumber'] ?? 'No Number';
          sellerPincode = docSnapshot['pincode'] ?? 'No Pincode';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("No data found for this seller.");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print("No user is logged in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 47, 138, 47),
        title: Text("Your Profile"),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.account_circle, size: 50),
                    SizedBox(height: 20),
                    Text(
                      "Welcome, $sellerName!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Email: $sellerEmail",
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Phone: $sellerNumber",
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Address: $sellerAddress",
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Pincode: $sellerPincode",
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            
                            Text(
                              "Role: $sellerRole",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color.fromARGB(255, 47, 138, 47),
                        shadowColor: Colors.black,
                        elevation: 8,
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditSellerProfileScreen(),
                          ),
                        ).then((_) {
                          _getSellerDetails(); // Refresh after edit
                        });
                      },
                      child: Text("Edit Details"),
                    ),
                    Spacer(), // Pushes the Logout button to the bottom
                    TextButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Log Out",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
