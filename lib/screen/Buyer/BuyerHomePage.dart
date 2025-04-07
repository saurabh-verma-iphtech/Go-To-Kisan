import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:signup_login_page/screen/Buyer/ProductDetailsPage.dart';
import 'package:signup_login_page/screen/Buyer/profile.dart';
import 'package:signup_login_page/screen/login.dart';

class BuyerHomePage extends StatelessWidget {
  const BuyerHomePage({Key? key}) : super(key: key);

  Future<void> addToCart(String productId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId);

      final cartDoc = await cartRef.get();

      if (cartDoc.exists) {
        // Increase quantity if already exists
        await cartRef.update({
          'quantity': (cartDoc.data()?['quantity'] ?? 1) + 1,
        });
      } else {
        // Add with quantity 1 if not exists
        await cartRef.set({'productId': productId, 'quantity': 1});
      }
    }
  }

  Future<void> buyNow(Map<String, dynamic> product) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orders')
          .add({...product, 'orderDate': Timestamp.now(), 'status': 'Pending'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go To Kisan'),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff6b63ff),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BuyerDashboard()),
                );
              } else if (value == 'logout') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Login()),
                );
              }
            },
            icon: const Icon(Icons.menu),
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'cart',
                    child: Text('Cart'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Text('Profile'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('products')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading products'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          var products = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.65,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index].data() as Map<String, dynamic>;
              List<dynamic> imageUrls = product['imageUrls'] ?? [];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProductDetailsPage(productData: product),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrls.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: SizedBox(
                            height: 120,
                            width: double.infinity,
                            child: CarouselSlider(
                              options: CarouselOptions(
                                height: 120,
                                autoPlay: true,
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                              ),
                              items:
                                  imageUrls.map((url) {
                                    return Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    );
                                  }).toList(),
                            ),
                          ),
                        )
                      else if (product['imageUrl'] != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.network(
                            product['imageUrl'],
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const SizedBox(
                          height: 120,
                          child: Center(
                            child: Icon(Icons.image_not_supported, size: 40),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          product['name'] ?? 'No Name',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          '₹${product['price'] ?? '0'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          (product['description'] ?? '').toString().length > 35
                              ? '${(product['description'] ?? '').toString().substring(0, 35)}...'
                              : product['description'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
