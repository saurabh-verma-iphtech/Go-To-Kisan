import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signup_login_page/screen/login.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> productData;
  final String productId;

  const ProductDetailsPage({
    Key? key,
    required this.productData,
    required this.productId,
  }) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Map<String, dynamic>? sellerData;
  List<Map<String, dynamic>> reviews = [];
  double averageRating = 0.0;
  double selectedRating = 0.0;
  final TextEditingController reviewController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchSellerDetails();
    fetchReviews();
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

  Future<void> fetchReviews() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .collection('reviews')
            .orderBy('timestamp', descending: true)
            .get();

    double total = 0.0;
    List<Map<String, dynamic>> fetchedReviews = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      total += (data['rating'] ?? 0.0);
      fetchedReviews.add(data);
    }

    setState(() {
      reviews = fetchedReviews;
      averageRating = reviews.isNotEmpty ? total / reviews.length : 0.0;
    });
  }

  Future<void> submitReview() async {
    if (selectedRating == 0.0 || FirebaseAuth.instance.currentUser == null)
      return;

    final reviewText = reviewController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    // Fetch user's name from Firestore
    String userName = 'Anonymous';
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();
      if (userDoc.exists && userDoc.data()!['name'] != null) {
        userName = userDoc.data()!['name'];
      }
    } catch (e) {
      debugPrint("Error fetching user name: $e");
    }

    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .collection('reviews')
        .add({
          'rating': selectedRating,
          'review': reviewText,
          'timestamp': DateTime.now(),
          'userId': user!.uid,
          'userName': userName,
        });

    reviewController.clear();
    selectedRating = 0.0;
    fetchReviews();
  }


  @override
  Widget build(BuildContext context) {
    final product = widget.productData;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Grain Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                style: const TextStyle(fontSize: 18, color: Colors.redAccent),
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Stock: ',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '${product['quantity'] ?? '0'} ${product['unit']}',
                      style: const TextStyle(color: Colors.green, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product['description'] ?? 'No Description',
                style: const TextStyle(fontSize: 14),
              ),
              const Divider(height: 30),
              const Text(
                'Seller Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 15),
              sellerData == null
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sellerData!['profileImage'] != null)
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              sellerData!['profileImage'],
                            ),
                          )
                        else
                          const CircleAvatar(
                            radius: 40,
                            child: Icon(Icons.person),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'Name: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${sellerData!['name'] ?? ''}'),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Contact: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${sellerData!['phoneNumber'] ?? ''}'),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Address: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${sellerData!['address'] ?? ''}'),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Pincode: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${sellerData!['pincode'] ?? ''}'),
                          ],
                        ),
                      ],
                    ),
                  ),
              const Divider(height: 30),
              const Text(
                'Ratings & Reviews',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Text(
                    'Average Rating: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.star, color: Colors.amber),
                  Text(averageRating.toStringAsFixed(1)),
                ],
              ),
              const SizedBox(height: 10),

              // 🌟 Show rating and text field only if user is logged in
              if (currentUser != null) ...[
                Row(
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    return IconButton(
                      icon: Icon(
                        selectedRating >= star ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedRating = star.toDouble();
                        });
                      },
                    );
                  }),
                ),
                TextField(
                  controller: reviewController,
                  decoration: const InputDecoration(
                    hintText: 'Write your review',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                  child: const Text('Submit Review',style: TextStyle(color: Colors.white),),
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Login to write a review.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_)=>Login()),
                    ); // 🔁 Update this to your actual login route
                  },
                  icon: const Icon(Icons.login,color: Colors.white,size: 20,),
                  label: const Text('Login',style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],

              // const SizedBox(height: 20),
                            const Divider(height: 20),

              reviews.isEmpty
                  ? const Text("No reviews yet.")
                  : Column(
                    children:
                        reviews.map((review) {
                          return ListTile(
                            title: Text(review['userName'] ?? "Anonymous"),
                            subtitle: Text(review['review'] ?? ""),
                            trailing: Text("⭐ ${review['rating'].toString()}"),
                          );
                        }).toList(),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
