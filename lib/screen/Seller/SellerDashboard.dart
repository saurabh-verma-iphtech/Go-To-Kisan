import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signup_login_page/Theme/theme_provider.dart';
import 'package:signup_login_page/screen/Review%20System/viewReviewPage.dart';
import 'package:signup_login_page/screen/Seller/EditProductPage.dart';
import 'package:signup_login_page/screen/Seller/addProductPage.dart';
import 'package:signup_login_page/screen/Seller/SproductDetail.dart';
import 'package:signup_login_page/screen/Seller/sellerProfile.dart';
import 'package:signup_login_page/screen/home.dart';

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

  Future<String> _getSellerName() async {
    var userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data()?['name'] ?? 'Seller';
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product deleted!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete product: $e')));
    }
  }

  void _showDeleteDialog(String productId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Product"),
            content: const Text(
              "Are you sure you want to delete this product?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteProduct(productId);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Go To Kisan - Seller Panel',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        elevation: 4,
        centerTitle: true,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final themeMode = ref.watch(themeProvider);
              final isDark = themeMode == ThemeMode.dark;

              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: isDark ? Colors.black : Colors.white,
                ),
                tooltip:
                    isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
              );
            },
          ),
          SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: colorScheme.primary),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .get(),
                    builder: (context, snapshot) {
                      final textStyle = Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onPrimary);

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError ||
                          !snapshot.hasData ||
                          !snapshot.data!.exists) {
                        return const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.account_circle,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      }

                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final imageUrl = data['profileImage'] as String?;
                      final name = data['name'] ?? 'Seller';

                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                imageUrl != null
                                    ? NetworkImage(imageUrl)
                                    : null,
                            child:
                                imageUrl == null
                                    ? const Icon(
                                      Icons.account_circle,
                                      size: 50,
                                      color: Colors.grey,
                                    )
                                    : null,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            name,
                            style: textStyle?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SellerProfile()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
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
                .where('sellerId', isEqualTo: userId)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching products: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products listed.'));
          }

          var products = snapshot.data!.docs;

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];
                var productData = product.data() as Map<String, dynamic>;

                String thumbnailUrl =
                    (productData['imageUrls'] != null &&
                            productData['imageUrls'].isNotEmpty)
                        ? productData['imageUrls'][0]
                        : '';

                return Card(
                  color: theme.cardColor,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      12
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap:
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ProductDetails(
                                                productId: product.id,
                                                sellerId: userId,
                                              ),
                                        ),
                                      ),

                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage:
                                        thumbnailUrl.isNotEmpty
                                            ? NetworkImage(thumbnailUrl)
                                            : null,
                                    child:
                                        thumbnailUrl.isEmpty
                                            ? const Icon(
                                              Icons.image_not_supported,
                                            )
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap:
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ProductDetails(
                                                productId: product.id,
                                                sellerId: userId,
                                              ),
                                        ),
                                      ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productData['name'] ?? 'No name',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      buildInfoLine(
                                        "Price: ",
                                        "₹${productData['price'] ?? '0'}",
                                        theme,
                                      ),

                                      // Rating aND REVIEW
                                      StreamBuilder<QuerySnapshot>(
                                        stream:
                                            _firestore
                                                .collection('products')
                                                .doc(product.id)
                                                .collection('reviews')
                                                .snapshots(),
                                        builder: (context, reviewSnapshot) {
                                          if (reviewSnapshot.hasData &&
                                              reviewSnapshot
                                                  .data!
                                                  .docs
                                                  .isNotEmpty) {
                                            var reviews =
                                                reviewSnapshot.data!.docs;
                                            double avgRating =
                                                reviews
                                                    .map(
                                                      (doc) =>
                                                          (doc['rating'] ?? 0)
                                                              .toDouble(),
                                                    )
                                                    .reduce((a, b) => a + b) /
                                                reviews.length;

                                            return GestureDetector(
                                              onTap:
                                                  () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) =>
                                                              ViewReviewsPage(
                                                                productId:
                                                                    product.id,
                                                                sellerId:
                                                                    userId,
                                                              ),
                                                    ),
                                                  ),
                                              child: Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star,
                                                        color: Colors.amber,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        avgRating
                                                            .toStringAsFixed(1),
                                                        style:
                                                            theme
                                                                .textTheme
                                                                .bodyMedium,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '(${reviews.length} reviews)',
                                                    style:
                                                        theme
                                                            .textTheme
                                                            .bodySmall,
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            return Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 18,
                                                ),
                                                const Text(' No ratings yet'),
                                              ],
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(width: 15),
                            Row(
                              children: [
                                // Detail Icon
                                IconButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                      vertical: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ProductDetails(
                                              sellerId: userId,
                                              productId: product.id,
                                            ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.remove_red_eye,
                                    // color: colorScheme.onPrimary,
                                    size: 22,
                                  ),
                                ),

                                SizedBox(width: 3,),

                                // Edit Icon
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => EditProductPage(
                                              productId: product.id,
                                              existingData: productData,
                                            ),
                                      ),
                                    );
                                  },
                                ),

                                // Delete Icon
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed:
                                      () => _showDeleteDialog(product.id),
                                ),
                              ],
                            ),
                          ],
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
        backgroundColor: colorScheme.primary,
        elevation: 2,
        foregroundColor: colorScheme.onPrimary,
        // elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildInfoLine(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
