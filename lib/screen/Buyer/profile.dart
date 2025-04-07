import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signup_login_page/screen/Buyer/buyerEditProfile.dart';
import 'package:signup_login_page/screen/login.dart';

class BuyerDashboard extends StatefulWidget {
  @override
  _BuyerDashboardState createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  String buyerName = "";
  String buyerEmail = "";
  String buyerAddress = "";
  String buyerRole = "";
  String buyerPhone = "";
  String buyerPincode = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getBuyerDetails();
  }

  Future<void> _getBuyerDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      print("Fetching data for user: $userId");

      try {
        var userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(userId);
        var docSnapshot = await userDoc.get();

        if (docSnapshot.exists) {
          print("Document found: ${docSnapshot.data()}");
          setState(() {
            buyerName = docSnapshot['name'] ?? 'No Name';
            buyerEmail = docSnapshot['email'] ?? 'No Email';
            buyerAddress = docSnapshot['address'] ?? 'No Address';
            buyerRole = docSnapshot['userType'] ?? 'No Role';
            buyerPhone = docSnapshot['phoneNumber'] ?? 'No Phone';
            buyerPincode = docSnapshot['pincode'] ?? 'No Pincode';
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print("No data found for this user.");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print("Error fetching data: $e");
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
        backgroundColor: const Color.fromARGB(255, 47, 138, 47),
        title: Text("Your Profile"),

      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.account_circle, size: 50),
                    SizedBox(height: 20),
                    Text(
                      "Welcome, $buyerName!",
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
                              "Email: $buyerEmail",
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Phone: $buyerPhone",
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Address: $buyerAddress",
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Pincode: $buyerPincode",
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Role: $buyerRole",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(),
                          ),
                        ).then((_) {
                          _getBuyerDetails(); // Refresh data after returning from edit screen
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // Text color
                        backgroundColor: Colors.blue, // Button background color
                        shadowColor: Colors.black, // Shadow color
                        elevation: 5, // Shadow depth
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Rounded corners
                        ),
                      ),

                      child: Text("Edit Details"),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white, // Text color
                        backgroundColor: Colors.red, // Button background color
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Log Out",),
                    ),
                  ],
                ),
      ),
    );
  }
}
