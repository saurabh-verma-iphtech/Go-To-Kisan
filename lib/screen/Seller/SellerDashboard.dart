import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signup_login_page/screen/Seller/EditProductPage.dart';
import 'package:signup_login_page/screen/Seller/addProductPage.dart';
import 'package:signup_login_page/screen/Seller/sellerProfile.dart';
import 'package:signup_login_page/screen/home.dart';
import 'package:signup_login_page/screen/login.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser!.uid;
  }

  // To display Seller Name on Drawer
  Future<String> _getSellerName() async {
    var userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data()?['name'] ?? 'Seller';
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Product deleted!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete product: $e')));
    }
  }

  void _showDeleteDialog(String productId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text("Delete Product"),
            content: Text("Are you sure you want to delete this product?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteProduct(productId);
                },
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Dashboard'),
        backgroundColor: Color.fromARGB(255, 47, 138, 47),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              // Navigator.of(
              //   context,
              // ).pushNamedAndRemoveUntil('/', (route) => false);
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
        ],
      ),
      drawer:
      // Inside the Drawer ListView in SellerDashboard:
      Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 47, 138, 47),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.account_circle, size: 50),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<String>(
                    future: _getSellerName(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Loading...',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        );
                      } else if (snapshot.hasError) {
                        return const Text(
                          'Error loading name',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        );
                      } else {
                        return Text(
                          snapshot.data ?? 'Seller',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SellerProfile()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_back_ios),
              title: const Text('Logout'),
              onTap: () async{
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ],
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('products')
                // .where('sellerId', isEqualTo: userId)
                .where('sellerId', isEqualTo: userId)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching products:${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products listed.'));
          }

          var products = snapshot.data!.docs;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];
                var productData = product.data() as Map<String, dynamic>;

                String thumbnailUrl =
                    productData['imageUrls'] != null &&
                            productData['imageUrls'].isNotEmpty
                        ? productData['imageUrls'][0]
                        : '';

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading:
                        productData['imageUrls'] != null &&
                                (productData['imageUrls'] as List).isNotEmpty
                            ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                productData['imageUrls'][0],
                              ),
                            )
                            : productData['imageUrl'] != null
                            ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                productData['imageUrl'],
                              ),
                            )
                            : CircleAvatar(
                              child: Icon(Icons.image_not_supported),
                            ),
                    title: Text(productData['name'] ?? 'No name'),
                    subtitle: Text(
                      '₹${productData['price'] ?? '0'}\n${productData['description'] ?? ''}\n'
                      'Qty: ${productData['quantity'] ?? 'N/A'} ${productData['unit'] ?? ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EditProductPage(
                                      productId: product.id,
                                      existingData:
                                          product.data()
                                              as Map<String, dynamic>,
                                    ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(product.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 47, 138, 47), // Button color
        foregroundColor: Colors.white, // Icon color
        elevation: 6, // Shadow depth
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Custom shape
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
