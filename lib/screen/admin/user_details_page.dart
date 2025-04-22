import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailPage extends StatelessWidget {
  final String userId;

  const UserDetailPage({required this.userId});

  Future<DocumentSnapshot> getUserData() async {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  Stream<QuerySnapshot> getUserProducts() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('sellerId', isEqualTo: userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Scaffold(body: Center(child: CircularProgressIndicator()));

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final isSeller = userData['userType'] == 'Seller';

        return Scaffold(
          appBar: AppBar(title: Text(userData['name'] ?? 'User Details')),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🧑 USER DETAILS SECTION
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: userData['profileImage'] != null
                            ? NetworkImage(userData['profileImage'])
                            : null,
                        child: userData['profileImage'] == null
                            ? Icon(Icons.person, size: 50)
                            : null,
                      ),
                      SizedBox(height: 16),
                      Text(userData['name'] ?? '', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      _buildDetailRow("Role", userData['userType']),
                      _buildDetailRow("Email", userData['email']),
                      _buildDetailRow("Phone", userData['phoneNumber']),
                      _buildDetailRow("Address", userData['address']),
                      _buildDetailRow("Portal Code", userData['pincode']),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // 🌾 SELLER PRODUCTS SECTION
                if (isSeller)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(thickness: 2),
                        Text(
                          "Seeds/Products",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        StreamBuilder<QuerySnapshot>(
                          stream: getUserProducts(),
                          builder: (context, productSnapshot) {
                            if (productSnapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            final products = productSnapshot.data?.docs ?? [];

                            if (products.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("No products uploaded."),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index].data() as Map<String, dynamic>;

                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    leading: product['imageUrls'] != null &&
                                        product['imageUrls'].isNotEmpty
                                        ? Image.network(
                                      product['imageUrls'][0],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                        : Icon(Icons.image, size: 50),
                                    title: Text(product['name'] ?? 'No Name'),
                                    subtitle: Text(
                                      "Price: ₹${product['price']} | Qty: ${product['quantity']}${product['unit']}",
                                    ),
                                  ),
                                );
                              },
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



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class UserDetailPage extends StatefulWidget {
//   final String userId;
//
//   const UserDetailPage({required this.userId});
//
//   @override
//   State<UserDetailPage> createState() => _UserDetailPageState();
// }
//
// class _UserDetailPageState extends State<UserDetailPage> with SingleTickerProviderStateMixin {
//   late Future<DocumentSnapshot> userFuture;
//   bool isSeller = false;
//
//   @override
//   void initState() {
//     super.initState();
//     userFuture = getUserData();
//   }
//
//   Future<DocumentSnapshot> getUserData() async {
//     final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
//     final data = doc.data() as Map<String, dynamic>;
//     isSeller = data['userType'] == 'Seller';
//     return doc;
//   }
//
//   Stream<QuerySnapshot> getUserProducts() {
//     return FirebaseFirestore.instance
//         .collection('products')
//         .where('sellerId', isEqualTo: widget.userId)
//         .snapshots();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<DocumentSnapshot>(
//       future: userFuture,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return Scaffold(body: Center(child: CircularProgressIndicator()));
//
//         final userData = snapshot.data!.data() as Map<String, dynamic>;
//
//         return DefaultTabController(
//           length: isSeller ? 2 : 1,
//           child: Scaffold(
//             appBar: AppBar(
//               title: Text(userData['name'] ?? 'User Details'),
//               bottom: TabBar(
//                 tabs: [
//                   Tab(text: "Details", icon: Icon(Icons.person)),
//                   if (isSeller) Tab(text: "Products", icon: Icon(Icons.shopping_bag)),
//                 ],
//               ),
//             ),
//             body: TabBarView(
//               children: [
//                 // 🧑 USER DETAILS TAB
//                 SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       SizedBox(height: 24),
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
//                       _buildDetailRow("Portal No", userData['pincode']),
//                       SizedBox(height: 24),
//                     ],
//                   ),
//                 ),
//
//                 // 🌾 SELLER PRODUCTS TAB (Grid View)
//                 if (isSeller)
//                   StreamBuilder<QuerySnapshot>(
//                     stream: getUserProducts(),
//                     builder: (context, productSnapshot) {
//                       if (productSnapshot.connectionState == ConnectionState.waiting) {
//                         return Center(child: CircularProgressIndicator());
//                       }
//
//                       final products = productSnapshot.data?.docs ?? [];
//
//                       if (products.isEmpty) {
//                         return Center(child: Text("No products uploaded."));
//                       }
//
//                       return Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: GridView.builder(
//                           itemCount: products.length,
//                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
//                             crossAxisSpacing: 8,
//                             mainAxisSpacing: 8,
//                             childAspectRatio: 3 / 4,
//                           ),
//                           itemBuilder: (context, index) {
//                             final product = products[index].data() as Map<String, dynamic>;
//
//                             return Card(
//                               elevation: 3,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                                 children: [
//                                   Expanded(
//                                     flex: 2,
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//                                       child: product['imageUrls'] != null &&
//                                           product['imageUrls'].isNotEmpty
//                                           ? Image.network(
//                                         product['imageUrls'][0],
//                                         fit: BoxFit.cover,
//                                       )
//                                           : Container(
//                                         color: Colors.grey[300],
//                                         child: Icon(Icons.image, size: 40),
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 1,
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             product['name'] ?? 'No Name',
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 16,
//                                             ),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                           SizedBox(height: 4),
//                                           Text(
//                                             "₹${product['price']} • ${product['quantity']}${product['unit']}",
//                                             style: TextStyle(color: Colors.grey[700]),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     },
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
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
