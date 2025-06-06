// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:signup_login_page/screen/Seller/SproductDetail.dart';

// class ProductManagementPage extends StatelessWidget {
//   void updateApprovalStatus(String productId, bool isApproved) {
//     FirebaseFirestore.instance.collection('products').doc(productId).update({
//       'approved': isApproved,
//     });
//   }

//   Future<void> deleteProduct(BuildContext context, String productId) async {
//     bool? confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text("Confirm Deletion"),
//             content: Text("Are you sure you want to delete this product?"),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: Text("Cancel"),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 onPressed: () => Navigator.of(context).pop(true),
//                 child: Text("Delete"),
//               ),
//             ],
//           ),
//     );

//     if (confirm == true) {
//       await FirebaseFirestore.instance
//           .collection('products')
//           .doc(productId)
//           .delete();
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Product deleted")));
//     }
//   }

//   Future<Map<String, dynamic>?> getUserInfo(String userId) async {
//     final doc =
//         await FirebaseFirestore.instance.collection('users').doc(userId).get();
//     return doc.exists ? doc.data() : null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('products').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData)
//           return Center(child: CircularProgressIndicator());

//         final products = snapshot.data!.docs;

//         return ListView.builder(
//           itemCount: products.length,
//           itemBuilder: (context, index) {
//             final product = products[index];
//             final productData = product.data() as Map<String, dynamic>;
//             final bool isApproved = productData['approved'] is bool
//               ? productData['approved']
//               : true;
//             final String sellerId = productData['sellerId'] ?? '';

//             return Card(
//               margin: EdgeInsets.all(8),
//               child: FutureBuilder<Map<String, dynamic>?>(
//                 future: getUserInfo(sellerId),
//                 builder: (context, userSnapshot) {
//                   final userData = userSnapshot.data;

//                   final String sellerName = userData?['name'] ?? 'Unknown';
//                   return ListTile(
//                     title: GestureDetector(
//                       onTap:
//                           () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder:
//                                   (_) => ProductDetails(
//                                     productId: product.id,
//                                     sellerId: sellerId,
//                                   ),
//                             ),
//                           ),
//                       child: Text(productData['name'] ?? ''),
//                     ),
//                     subtitle: GestureDetector(
//                       onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>ProductDetails(productId: product.id, sellerId: sellerId))),
//                       child:Text((sellerName ?? '')),
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Switch(
//                           value: isApproved,
//                           onChanged: (value) async {
//                             updateApprovalStatus(product.id, value);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   value ? 'Product approved' : 'Product hidden',
//                                 ),
//                               ),
//                             );
//                           },

//                         ),
//                         IconButton(
//                           icon: Icon(Icons.delete, color: Colors.red),
//                           onPressed: () => deleteProduct(context, product.id),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }


import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signup_login_page/screen/Seller/SproductDetail.dart';

class ProductManagementPage extends StatefulWidget {
  @override
  _ProductManagementPageState createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  // ─── Pagination State ─────────────────────────────────────────────────────
  static const int _pageSize = 10;
  int _currentPage = 0;

  void updateApprovalStatus(String productId, bool isApproved) {
    FirebaseFirestore.instance.collection('products').doc(productId).update({
      'approved': isApproved,
    });
  }

  Future<void> deleteProduct(BuildContext context, String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Confirm Deletion"),
            content: Text("Are you sure you want to delete this product?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Delete"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Product deleted")));
    }
  }

  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        // 1) grab all docs
        final allProducts = snapshot.data!.docs;

        if (allProducts.isEmpty) {
          return Center(child: Text("No products found."));
        }

        // 2) calculate pagination
        final totalItems = allProducts.length;
        final totalPages = (totalItems / _pageSize).ceil();
        final start = _currentPage * _pageSize;
        final end = min(start + _pageSize, totalItems);
        final pageProducts = allProducts.sublist(start, end);

        return Column(
          children: [
            // 3) paged list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: pageProducts.length,
                itemBuilder: (context, index) {
                  final product = pageProducts[index];
                  final productData = product.data() as Map<String, dynamic>;
                  final bool isApproved =
                      productData['approved'] is bool
                          ? productData['approved']
                          : true;
                  final sellerId = productData['sellerId'] ?? '';

                  return Card(
                    margin: EdgeInsets.all(8),
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: getUserInfo(sellerId),
                      builder: (context, userSnapshot) {
                        final userData = userSnapshot.data;
                        final sellerName = userData?['name'] ?? 'Unknown';

                        return ListTile(
                          title: GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ProductDetails(
                                          productId: product.id,
                                          sellerId: sellerId,
                                        ),
                                  ),
                                ),
                            child: Text(productData['name'] ?? ''),
                          ),
                          subtitle: GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ProductDetails(
                                          productId: product.id,
                                          sellerId: sellerId,
                                        ),
                                  ),
                                ),
                            child: Text(sellerName),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: isApproved,
                                onChanged: (value) async {
                                  updateApprovalStatus(product.id, value);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        value
                                            ? 'Product approved'
                                            : 'Product hidden',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed:
                                    () => deleteProduct(context, product.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // 4) pagination controls at bottom, outside cards
            if (totalPages > 1)
              SafeArea(
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
                      Text('Page ${_currentPage + 1} of $totalPages'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed:
                            _currentPage < totalPages - 1
                                ? () => setState(() => _currentPage++)
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
