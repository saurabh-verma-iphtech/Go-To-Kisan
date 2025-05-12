import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signup_login_page/Theme/theme_provider.dart';
import 'package:signup_login_page/screen/Chat/screens/seller/chat_list.dart';
import 'package:signup_login_page/screen/Review%20System/viewReviewPage.dart';
import 'package:signup_login_page/screen/Seller/EditProductPage.dart';
import 'package:signup_login_page/screen/Seller/addProductPage.dart';
import 'package:signup_login_page/screen/Seller/SproductDetail.dart';
import 'package:signup_login_page/screen/Seller/sellerProfile.dart';
import 'package:signup_login_page/screen/home.dart';
import 'package:badges/badges.dart' as badges;


class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String userId;

  // 1) pagination state
  static const int _pageSize = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser!.uid;
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
          (_) => AlertDialog(
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Panel'),
        actions: [
          Consumer(
            builder: (c, ref, _) {
              final themeMode = ref.watch(themeProvider);
              final d = themeMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(d ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
              );
            },
          ),
          FirebaseAuth.instance.currentUser != null
              ? StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('chats')
                        .where('sellerId', isEqualTo: userId)
                        .snapshots(),
                builder: (context, snap) {
                  // 1️⃣ compute total unread for seller
                  int totalUnread = 0;
                  if (snap.hasData) {
                    totalUnread = snap.data!.docs.fold(0, (sum, doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return sum + (data['unreadCountForSeller'] as int? ?? 0);
                    });
                  }

                  // 2️⃣ build the Badge
                  return badges.Badge(
                    showBadge: totalUnread > 0,
                    position: badges.BadgePosition.topEnd(top: -4, end: 1),
                    badgeAnimation: badges.BadgeAnimation.fade(),
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: Colors.red, // you can tweak color
                      padding: EdgeInsets.all(6),
                      elevation: 0,
                    ),
                    badgeContent: Text(
                      totalUnread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => SellerChatListScreen(sellerId: userId),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.send_and_archive,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  );
                },
              )
              : const SizedBox.shrink(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              child: FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(userId).get(),
                builder: (c, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snap.data!.data() as Map<String, dynamic>? ?? {};
                  final img = data['profileImage'] as String?;
                  final name = data['name'] ?? 'Seller';
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: img != null ? NetworkImage(img) : null,
                        child:
                            img == null
                                ? const Icon(Icons.account_circle, size: 50)
                                : null,
                      ),
                      const SizedBox(height: 10),
                      Text(name, style: theme.textTheme.titleMedium),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SellerProfile()),
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                );
              },
            ),
          ],
        ),
      ),

      // 2) use Column so pager can live below the list
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('products')
                      .where('sellerId', isEqualTo: userId)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No products listed.'));
                }

                // 3) slice out only pageSize docs
                final totalItems = docs.length;
                final start = _currentPage * _pageSize;
                final end = min(start + _pageSize, totalItems);
                final pageDocs = docs.sublist(start, end);

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: pageDocs.length,
                    itemBuilder: (c, i) {
                      final doc = pageDocs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      final thumb =
                          (data['imageUrls'] as List<dynamic>?)
                              ?.cast<String>()
                              .firstOrNull ??
                          '';
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: _buildProductRow(data, doc.id, thumb, theme),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // 4) pagination controls, only if > one page
          StreamBuilder<QuerySnapshot>(
            stream:
                _firestore
                    .collection('products')
                    .where('sellerId', isEqualTo: userId)
                    .snapshots(),
            builder: (_, s) {
              final total = s.data?.docs.length ?? 0;
              final pages = (total / _pageSize).ceil();
              if (pages <= 1) return const SizedBox.shrink();
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed:
                            _currentPage > 0
                                ? () => setState(() => _currentPage--)
                                : null,
                      ),
                      Text('Page ${_currentPage + 1} of $pages'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed:
                            _currentPage < pages - 1
                                ? () => setState(() => _currentPage++)
                                : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductPage()),
            ),
      ),
    );
  }

  Widget _buildProductRow(
    Map<String, dynamic> data,
    String id,
    String thumb,
    ThemeData theme,
  ) {
    return Row(
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
                          (_) =>
                              ProductDetails(productId: id, sellerId: userId),
                    ),
                  ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                backgroundImage: thumb.isNotEmpty ? NetworkImage(thumb) : null,
                child:
                    thumb.isEmpty
                        ? const Icon(Icons.image_not_supported)
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
                          (_) =>
                              ProductDetails(productId: id, sellerId: userId),
                    ),
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'No name',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  buildInfoLine("Price: ", "₹${data['price'] ?? '0'}", theme),
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        _firestore
                            .collection('products')
                            .doc(id)
                            .collection('reviews')
                            .snapshots(),
                    builder: (c, rs) {
                      if (!rs.hasData || rs.data!.docs.isEmpty) {
                        return const Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            Text(' No ratings yet'),
                          ],
                        );
                      }
                      final revs = rs.data!.docs;
                      final avg =
                          revs
                              .map((d) => (d['rating'] ?? 0).toDouble())
                              .reduce((a, b) => a + b) /
                          revs.length;
                      return GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ViewReviewsPage(
                                      productId: id,
                                      sellerId: userId,
                                    ),
                              ),
                            ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            Text(
                              avg.toStringAsFixed(1),
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${revs.length} reviews)',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              ProductDetails(productId: id, sellerId: userId),
                    ),
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => EditProductPage(
                            productId: id,
                            existingData: data,
                          ),
                    ),
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(id),
            ),
          ],
        ),
      ],
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
