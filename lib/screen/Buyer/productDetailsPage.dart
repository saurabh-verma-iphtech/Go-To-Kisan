import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
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

  // Track editing mode
  bool isEditing = false;

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
      data['id'] = doc.id; // Add review ID
      total += (data['rating'] ?? 0.0);
      fetchedReviews.add(data);
    }

    setState(() {
      reviews = fetchedReviews;
      averageRating = reviews.isNotEmpty ? total / reviews.length : 0.0;
    });
  }

  Future<void> submitReview() async {
    if (selectedRating == null || selectedRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'rating'.tr(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final reviewText = reviewController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

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

    final existingReview =
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .collection('reviews')
            .doc(user!.uid)
            .get();

    if (existingReview.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("review".tr()),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .collection('reviews')
        .doc(user.uid)
        .set({
          'rating': selectedRating,
          'review': reviewText,
          'timestamp': DateTime.now(),
          'userId': user.uid,
          'userName': userName,
        });

    reviewController.clear();
    selectedRating = 0.0;
    fetchReviews();
  }

  Future<void> updateReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .collection('reviews')
        .doc(user.uid)
        .update({
          'rating': selectedRating,
          'review': reviewController.text.trim(),
          'timestamp': DateTime.now(),
        });




ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('reviewUpdate'.tr()),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );



    setState(() {
      isEditing = false;
      selectedRating = 0.0;
      reviewController.clear();
    });

    fetchReviews();

  }

  Future<void> deleteReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .collection('reviews')
        .doc(user.uid)
        .delete();


      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Text('reviewDelete'.tr()),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      selectedRating = 0.0;
      reviewController.clear();
    });

    fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.productData;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'grainDetail'.tr(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                  TextSpan(
                    text: 'stock'.tr(),
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
              '',
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
                          Text(
                            'name'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${sellerData!['name'] ?? ''}'),
                        ],
                      ),
                      Row(
                        children: [
                           Text(
                            'contact'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${sellerData!['phoneNumber'] ?? ''}'),
                        ],
                      ),
                      Row(
                        children: [
                           Text(
                            'address'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${sellerData!['address'] ?? ''}'),
                        ],
                      ),
                      Row(
                        children: [
                           Text(
                            'pincode'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${sellerData!['pincode'] ?? ''}'),
                        ],
                      ),
                    ],
                  ),
                ),
            const Divider(height: 30),
            Text(
              'rr'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                 Text(
                  'avgRating'.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.star, color: Colors.amber),
                Text(averageRating.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 10),

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
                decoration: InputDecoration(
                  hintText: 'writeReview'.tr(),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isEditing ? updateReview : submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                child: Text(
                  isEditing ? 'upReview'.tr() : 'subReview'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ] else ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'logForReview'.tr(),
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
                    MaterialPageRoute(builder: (_) => Login()),
                  );
                },
                icon: const Icon(Icons.login, color: Colors.white, size: 20),
                label:  Text(
                  'login'.tr(),
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],

            const Divider(height: 20),

            reviews.isEmpty
                ? Text("noReviews".tr())
                : Column(
                  children:
                      reviews.map((review) {
                        final isOwnReview =
                            review['userId'] == currentUser?.uid;

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Username and rating + menu row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// Username
                                    Text(
                                      review['userName'] ?? "Anonymous",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    /// Rating and menu
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          review['rating'].toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (isOwnReview) ...[
                                          const SizedBox(width: 8),
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert),
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                setState(() {
                                                  selectedRating =
                                                      review['rating']
                                                          .toDouble();
                                                  reviewController.text =
                                                      review['review'] ?? '';
                                                  isEditing = true;
                                                });
                                              } else if (value == 'delete') {
                                                deleteReview();
                                              }
                                            },
                                            itemBuilder:
                                                (context) => [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.edit,
                                                          color: Colors.blue,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text('Edit'),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text('Delete'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                /// Review text
                                Text(
                                  review['review'] ?? "",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),

                        );
                      }).toList(),

                ),
          ],
        ),
      ),
    );
  }
}
