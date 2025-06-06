import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signup_login_page/screen/Buyer/productDetailsPage.dart';
import 'package:signup_login_page/services/wishlistService.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: FutureBuilder<List<String>>(
        future: WishlistService.getWishlistProductIds(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ids = snap.data ?? [];
          if (ids.isEmpty) {
            return const Center(child: Text('Your wishlist is empty.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: ids.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('products')
                        .doc(ids[index])
                        .get(),
                builder: (context, productSnap) {
                  final productId =
                      ids[index]; // ✅ Correct way to get productId
                  if (!productSnap.hasData) {
                    // Loading placeholder (shimmer-like)
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 16,
                                  width: 80,
                                  child: ColoredBox(color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                SizedBox(
                                  height: 14,
                                  width: 60,
                                  child: ColoredBox(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!productSnap.data!.exists) return const SizedBox();

                  final data = productSnap.data!.data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder:
                              (_, __, ___) => ProductDetailsPage(
                                productData: data,
                                productId: productId,
                              ),
                          transitionsBuilder: (_, anim, __, child) {
                            return FadeTransition(opacity: anim, child: child);
                          },
                        ),
                      );
                    },
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child:
                                    (data['imageUrls'] as List).isNotEmpty
                                        ? Image.network(
                                          (data['imageUrls'] as List).first,
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                        : Container(
                                          height: 120,
                                          width: double.infinity,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                          ),
                                        ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${data['price']} / ${data['unit']}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (data['description'] ?? '')
                                              .toString()
                                              .substring(
                                                0,
                                                min(
                                                  60,
                                                  (data['description'] ?? '')
                                                      .length,
                                                ),
                                              ) +
                                          ((data['description'] ?? '').length >
                                                  60
                                              ? '…'
                                              : ''),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Remove from wishlist button
                          Positioned(
                            top: -5,
                            right: -5,
                            child: IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.redAccent,
                              ),
                              onPressed: () async {
                                await WishlistService.toggleWishlist(
                                  ids[index],
                                );
                                setState(() {}); // Refresh wishlist
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
