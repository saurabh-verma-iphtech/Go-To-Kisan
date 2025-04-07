import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailsPage({Key? key, required this.productData})
    : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Map<String, dynamic>? sellerData;

  @override
  void initState() {
    super.initState();
    fetchSellerDetails();
  }

  Future<void> fetchSellerDetails() async {
    final sellerId = widget.productData['sellerId'];
    if (sellerId != null) {
      final sellerDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(sellerId)
              .get();
      if (sellerDoc.exists) {
        setState(() {
          sellerData = sellerDoc.data();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.productData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grain Details'),
        backgroundColor: const Color.fromARGB(255, 47, 138, 47),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              if ((product['imageUrls'] ?? []).isNotEmpty)
                SizedBox(
                  height: 250,
                  child: PageView(
                    children:
                        (product['imageUrls'] as List<dynamic>).map((url) {
                          return Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        }).toList(),
                  ),
                )
              else if (product['imageUrl'] != null)
                Image.network(
                  product['imageUrl'],
                  height: 250,
                  fit: BoxFit.cover,
                ),

              const SizedBox(height: 12),
              Text(
                product['name'] ?? 'No Name',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${product['price']}',
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
              const SizedBox(height: 10),
              Text(
                product['description'] ?? 'No Description',
                style: const TextStyle(fontSize: 14),
              ),
              const Divider(height: 30),

              // Seller Details
              const Text(
                'Seller Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              SizedBox(height: 15),
              sellerData == null
                  ? const CircularProgressIndicator()
                  : Padding(
                    padding: const EdgeInsets.only(left:38.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Name: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${sellerData!['name'] ?? ''}'),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Contact: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${sellerData!['phoneNumber'] ?? ''}'),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Address: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${sellerData!['address'] ?? ''}'),
                          ],
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
