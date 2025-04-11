// // Add this new file for viewing reviews: view_reviews_page.dart
// // -------------------- view_reviews_page.dart --------------------
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class ViewReviewsPage extends StatelessWidget {
//   final String productId;
//   const ViewReviewsPage({super.key, required this.productId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Product Reviews'),
//         backgroundColor: const Color(0xFF2F8A2F),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream:
//             FirebaseFirestore.instance
//                 .collection('reviews')
//                 .where('productId', isEqualTo: productId)
//                 .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No reviews yet.'));
//           }

//           final reviews = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: reviews.length,
//             itemBuilder: (context, index) {
//               final review = reviews[index].data() as Map<String, dynamic>;
//               return ListTile(
//                 title: Text(review['userName'] ?? 'Anonymous'),
//                 subtitle: Text(review['review'] ?? ''),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.star, color: Colors.amber, size: 18),
//                     Text('${review['rating'] ?? '0'}'),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewReviewsPage extends StatelessWidget {
  final String productId;
  final String sellerId;
  const ViewReviewsPage({
    super.key,
    required this.productId,
    required this.sellerId,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Reviews'),
        backgroundColor: const Color(0xFF2F8A2F),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('products')
                .doc(productId)
                .collection('reviews') // ✅ Correct subcollection path
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reviews yet.'));
          }

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index].data() as Map<String, dynamic>;
              final reviewDocId = reviews[index].id;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Text(review['userName'] ?? 'Anonymous'),
                  title: Text(review['review'] ?? ''),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      Text('${(review['rating'] ?? '0'.toString())}'),
                    ],
                  ),
                  trailing:
                      currentUser?.uid == sellerId
                          ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmation(
                                context,
                                productId,
                                reviewDocId,
                              );
                            },
                          )
                          : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String productId,
    String reviewId,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Review"),
            content: const Text("Are you sure you want to delete this review?"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(productId)
                      .collection('reviews')
                      .doc(reviewId)
                      .delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Review deleted")),
                  );
                },
              ),
            ],
          ),
    );
  }
}
