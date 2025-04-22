import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signup_login_page/screen/Seller/SproductDetail.dart';

class ProductManagementPage extends StatelessWidget {
  void updateApprovalStatus(String productId, bool isApproved) {
    FirebaseFirestore.instance.collection('products').doc(productId).update({
      'approved': isApproved,
    });
  }

  Future<void> deleteProduct(BuildContext context, String productId) async {
    bool? confirm = await showDialog<bool>(
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

        final products = snapshot.data!.docs;

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final productData = product.data() as Map<String, dynamic>;
            final bool isApproved = productData['approved'] is bool
              ? productData['approved']
              : true;
            final String sellerId = productData['sellerId'] ?? '';

            return Card(
              margin: EdgeInsets.all(8),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: getUserInfo(sellerId),
                builder: (context, userSnapshot) {
                  final userData = userSnapshot.data;

                  final String sellerName = userData?['name'] ?? 'Unknown';
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
                      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>ProductDetails(productId: product.id, sellerId: sellerId))),
                      child:Text((sellerName ?? '')),
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
                                  value ? 'Product approved' : 'Product hidden',
                                ),
                              ),
                            );
                          },

                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteProduct(context, product.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
