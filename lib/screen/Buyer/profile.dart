// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:signup_login_page/screen/Buyer/buyerEditProfile.dart';
// import 'package:signup_login_page/screen/home.dart';

// class BuyerDashboard extends StatefulWidget {
//   @override
//   _BuyerDashboardState createState() => _BuyerDashboardState();
// }

// class _BuyerDashboardState extends State<BuyerDashboard> {
//   String buyerName = "";
//   String buyerEmail = "";
//   String buyerAddress = "";
//   String buyerRole = "";
//   String buyerPhone = "";
//   String buyerPincode = "";
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _getBuyerDetails();
//   }

//   Future<void> _getBuyerDetails() async {
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       try {
//         var docSnapshot =
//             await FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(user.uid)
//                 .get();

//         if (docSnapshot.exists) {
//           setState(() {
//             buyerName = docSnapshot['name'] ?? 'No Name';
//             buyerEmail = docSnapshot['email'] ?? 'No Email';
//             buyerAddress = docSnapshot['address'] ?? 'No Address';
//             buyerRole = docSnapshot['userType'] ?? 'No Role';
//             buyerPhone = docSnapshot['phoneNumber'] ?? 'No Phone';
//             buyerPincode = docSnapshot['pincode'] ?? 'No Pincode';
//             isLoading = false;
//           });
//         } else {
//           setState(() => isLoading = false);
//           print("No data found for this buyer.");
//         }
//       } catch (e) {
//         setState(() => isLoading = false);
//         print("Error fetching data: $e");
//       }
//     } else {
//       setState(() => isLoading = false);
//       print("No user is logged in.");
//     }
//   }

//   Widget buildInfoTile(String label, String value, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.green),
//           SizedBox(width: 10),
//           Expanded(
//             // child: Text("$label: $value", style: TextStyle(fontSize: 18)),
//             child: RichText(text: TextSpan(
//               children: [
//                 TextSpan(text: "$label: ", style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400,color: Colors.black)),
//                 TextSpan(text: "$value", style: TextStyle(fontSize: 18, color: Colors.blue)),
//               ]
//             )),
//           ),
//         ],
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
//         backgroundColor: const Color.fromARGB(255, 47, 138, 47),
//         title: const Text("Profile",style: TextStyle(color: Colors.white),),
//       ),
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     AnimatedContainer(
//                       duration: Duration(milliseconds: 600),
//                       curve: Curves.easeInOut,
//                       alignment: Alignment.center,
//                       child: Column(
//                         children: [
//                           CircleAvatar(
//                             radius: 45,
//                             backgroundColor: Colors.green.shade100,
//                             child: Icon(
//                               Icons.person,
//                               size: 50,
//                               color: Colors.green.shade700,
//                             ),
//                           ),
//                           const SizedBox(height: 15),
//                           RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: 'Welcome, ',
//                                    style: const TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                   text: buyerName,
//                                   style: const TextStyle(
//                                     color: Colors.red,
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ]
//                             )
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     Card(
//                       elevation: 6,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(18.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             buildInfoTile("Email", buyerEmail, Icons.email),
//                             buildInfoTile("Phone", buyerPhone, Icons.phone),
//                             buildInfoTile("Address", buyerAddress, Icons.home),
//                             buildInfoTile(
//                               "Pincode",
//                               buyerPincode,
//                               Icons.location_on,
//                             ),
//                             buildInfoTile("Role", buyerRole, Icons.badge),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => EditProfileScreen(),
//                           ),
//                         ).then((_) => _getBuyerDetails());
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                         elevation: 8,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 25,
//                           vertical: 15,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                       icon: Icon(Icons.edit),
//                       label: const Text("Edit Details"),
//                     ),
//                     const SizedBox(height: 30),
//                     Center(
//                       child: TextButton.icon(
//                         onPressed: () {
//                           FirebaseAuth.instance.signOut();
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(builder: (context) => HomePage()),
//                           );
//                         },
//                         icon: Icon(Icons.logout),
//                         label: const Text("Log Out"),
//                         style: TextButton.styleFrom(
//                           backgroundColor: Colors.red,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 10,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signup_login_page/screen/Buyer/buyerEditProfile.dart';
import 'package:signup_login_page/screen/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _getBuyerDetails();
  }

  Future<void> _pickAndUploadImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final supabase = Supabase.instance.client;
      final bytes = await picked.readAsBytes();
      final fileName =
          'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final uploadResponse = await supabase.storage
          .from('user-images') // Your Supabase bucket
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final imageUrl = supabase.storage
          .from('user-images')
          .getPublicUrl(fileName);

      // Save image URL in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'profileImage': imageUrl},
      );

      setState(() {
        profileImageUrl = imageUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }


  Future<void> _getBuyerDetails() async {
fb_auth.User? user = fb_auth.FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        var docSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (docSnapshot.exists) {
          setState(() {
            buyerName = docSnapshot['name'] ?? 'No Name';
            buyerEmail = docSnapshot['email'] ?? 'No Email';
            buyerAddress = docSnapshot['address'] ?? 'No Address';
            buyerRole = docSnapshot['userType'] ?? 'No Role';
            buyerPhone = docSnapshot['phoneNumber'] ?? 'No Phone';
            buyerPincode = docSnapshot['pincode'] ?? 'No Pincode';
            profileImageUrl = docSnapshot['profileImage'] ?? null;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          print("No data found for this buyer.");
        }
      } catch (e) {
        setState(() => isLoading = false);
        print("Error fetching data: $e");
      }
    } else {
      setState(() => isLoading = false);
      print("No user is logged in.");
    }
  }

  Widget buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
            // child: Text("$label: $value", style: TextStyle(fontSize: 18)),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: "$value",
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFF7),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // <-- This changes the back arrow color
        ),
        backgroundColor: const Color.fromARGB(255, 47, 138, 47),
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.green.shade100,
                                backgroundImage:
                                    profileImageUrl != null
                                        ? NetworkImage(profileImageUrl!)
                                        : null,
                                child:
                                    profileImageUrl == null
                                        ? Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.green.shade700,
                                        )
                                        : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 4,
                                child: InkWell(
                                  onTap: () => _pickAndUploadImage(),
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Welcome, ',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: buyerName,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildInfoTile("Email", buyerEmail, Icons.email),
                            buildInfoTile("Phone", buyerPhone, Icons.phone),
                            buildInfoTile("Address", buyerAddress, Icons.home),
                            buildInfoTile(
                              "Pincode",
                              buyerPincode,
                              Icons.location_on,
                            ),
                            buildInfoTile("Role", buyerRole, Icons.badge),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(),
                          ),
                        ).then((_) => _getBuyerDetails());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: Icon(Icons.edit),
                      label: const Text("Edit Details"),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                        icon: Icon(Icons.logout),
                        label: const Text("Log Out"),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
