// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserDetailPage extends StatelessWidget {
//   final String userId;

//   const UserDetailPage({required this.userId});

//   Future<DocumentSnapshot> getUserData() async {
//     return FirebaseFirestore.instance.collection('users').doc(userId).get();
//   }

//   Stream<QuerySnapshot> getUserProducts() {
//     return FirebaseFirestore.instance
//         .collection('products')
//         .where('sellerId', isEqualTo: userId)
//         .snapshots();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<DocumentSnapshot>(
//       future: getUserData(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return Scaffold(body: Center(child: CircularProgressIndicator()));

//         final userData = snapshot.data!.data() as Map<String, dynamic>;
//         final isSeller = userData['userType'] == 'Seller';

//         return Scaffold(
//           appBar: AppBar(title: Text(userData['name'] ?? 'User Details')),
//           body: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // 🧑 USER DETAILS SECTION
//                 Container(
//                   padding: EdgeInsets.all(16),
//                   color: Colors.blue.shade50,
//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 50,
//                         backgroundImage: userData['profileImage'] != null
//                             ? NetworkImage(userData['profileImage'])
//                             : null,
//                         child: userData['profileImage'] == null
//                             ? Icon(Icons.person, size: 50)
//                             : null,
//                       ),
//                       SizedBox(height: 16),
//                       Text(userData['name'] ?? '', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//                       SizedBox(height: 8),
//                       _buildDetailRow("Role", userData['userType']),
//                       _buildDetailRow("Email", userData['email']),
//                       _buildDetailRow("Phone", userData['phoneNumber']),
//                       _buildDetailRow("Address", userData['address']),
//                       _buildDetailRow("Portal Code", userData['pincode']),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: 16),

//                 // 🌾 SELLER PRODUCTS SECTION
//                 if (isSeller)
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Divider(thickness: 2),
//                         Text(
//                           "Seeds/Products",
//                           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 10),
//                         StreamBuilder<QuerySnapshot>(
//                           stream: getUserProducts(),
//                           builder: (context, productSnapshot) {
//                             if (productSnapshot.connectionState == ConnectionState.waiting) {
//                               return Center(child: CircularProgressIndicator());
//                             }

//                             final products = productSnapshot.data?.docs ?? [];

//                             if (products.isEmpty) {
//                               return Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Text("No products uploaded."),
//                               );
//                             }

//                             return ListView.builder(
//                               shrinkWrap: true,
//                               physics: NeverScrollableScrollPhysics(),
//                               itemCount: products.length,
//                               itemBuilder: (context, index) {
//                                 final product = products[index].data() as Map<String, dynamic>;

//                                 return Card(
//                                   elevation: 2,
//                                   margin: EdgeInsets.symmetric(vertical: 6),
//                                   child: ListTile(
//                                     leading: product['imageUrls'] != null &&
//                                         product['imageUrls'].isNotEmpty
//                                         ? Image.network(
//                                       product['imageUrls'][0],
//                                       width: 50,
//                                       height: 50,
//                                       fit: BoxFit.cover,
//                                     )
//                                         : Icon(Icons.image, size: 50),
//                                     title: Text(product['name'] ?? 'No Name'),
//                                     subtitle: Text(
//                                       "Price: ₹${product['price']} | Qty: ${product['quantity']}${product['unit']}",
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDetailRow(String title, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text('$title: ', style: TextStyle(fontWeight: FontWeight.bold)),
//           Text(value?.toString() ?? 'N/A'),
//         ],
//       ),
//     );
//   }
// }




import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  const UserDetailPage({required this.userId, Key? key}) : super(key: key);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  // ─── Pagination State ─────────────────────────────────────────────────────
  static const int _pageSize = 5;
  int _currentPage = 0;

  Future<DocumentSnapshot> getUserData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
  }

  Stream<QuerySnapshot> getUserProductsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('sellerId', isEqualTo: widget.userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final userData = snapshot.data!.data()! as Map<String, dynamic>;
        final isSeller = userData['userType'] == 'Seller';

        return Scaffold(
          appBar: AppBar(title: Text(userData['name'] ?? 'User Details')),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── USER DETAILS ────────────────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            userData['profileImage'] != null
                                ? NetworkImage(userData['profileImage'])
                                : null,
                        child:
                            userData['profileImage'] == null
                                ? Icon(Icons.person, size: 50)
                                : null,
                      ),
                      SizedBox(height: 16),
                      Text(
                        userData['name'] ?? '',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildDetailRow("Role", userData['userType']),
                      _buildDetailRow("Email", userData['email']),
                      _buildDetailRow("Phone", userData['phoneNumber']),
                      _buildDetailRow("Address", userData['address']),
                      _buildDetailRow("Pincode", userData['pincode']),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // ─── SELLER PRODUCTS WITH PAGINATION ─────────────────────────────
                if (isSeller)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(thickness: 2),
                        Text(
                          "Seeds/Products",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),

                        StreamBuilder<QuerySnapshot>(
                          stream: getUserProductsStream(),
                          builder: (context, productSnapshot) {
                            if (productSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            final allProducts =
                                productSnapshot.data?.docs ?? [];

                            if (allProducts.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("No products uploaded."),
                              );
                            }

                            // ── pagination calculations ─────────────────────────────────
                            final totalItems = allProducts.length;
                            final totalPages = (totalItems / _pageSize).ceil();
                            final start = _currentPage * _pageSize;
                            final end = min(start + _pageSize, totalItems);
                            final pageProducts = allProducts.sublist(
                              start,
                              end,
                            );

                            return Column(
                              children: [
                                // ── paged ListView ────────────────────────────────
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: pageProducts.length,
                                  itemBuilder: (context, index) {
                                    final productDoc = pageProducts[index];
                                    final product =
                                        productDoc.data()!
                                            as Map<String, dynamic>;

                                    return Card(
                                      elevation: 2,
                                      margin: EdgeInsets.symmetric(vertical: 6),
                                      child: ListTile(
                                        leading:
                                            product['imageUrls'] != null &&
                                                    product['imageUrls']
                                                        .isNotEmpty
                                                ? Image.network(
                                                  product['imageUrls'][0],
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                )
                                                : Icon(Icons.image, size: 50),
                                        title: Text(
                                          product['name'] ?? 'No Name',
                                        ),
                                        subtitle: Text(
                                          "Price: ₹${product['price']} | Qty: ${product['quantity']}${product['unit']}",
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // ── pagination controls ──────────────────────────
                                if (totalPages > 1)
                                  SafeArea(
                                    top: false,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.chevron_left),
                                            onPressed:
                                                _currentPage > 0
                                                    ? () => setState(
                                                      () => _currentPage--,
                                                    )
                                                    : null,
                                          ),
                                          Text(
                                            'Page ${_currentPage + 1} of $totalPages',
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.chevron_right),
                                            onPressed:
                                                _currentPage < totalPages - 1
                                                    ? () => setState(
                                                      () => _currentPage++,
                                                    )
                                                    : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$title: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value?.toString() ?? 'N/A'),
        ],
      ),
    );
  }
}
