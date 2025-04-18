import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signup_login_page/screen/Review%20System/viewReviewPage.dart';

class ProductDetails extends StatelessWidget {
  final String productId;
  final String sellerId;

  const ProductDetails({
    super.key,
    required this.productId,
    required this.sellerId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: TextStyle(color: color.onPrimary),
        ),
        backgroundColor: color.primary,
        iconTheme: IconThemeData(color: color.onPrimary),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('products')
                .doc(productId)
                .snapshots(),
        builder: (context, productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!productSnapshot.hasData || !productSnapshot.data!.exists) {
            return const Center(child: Text('Product not found.'));
          }

          var productData =
              productSnapshot.data!.data() as Map<String, dynamic>;
          List<String> imageUrls = List<String>.from(
            productData['imageUrls'] ?? [],
          );

          // Date & Time
          Timestamp? createdAtTime = productData['createdAt'];
          String formattedDate = '';
          if (createdAtTime != null) {
            DateTime createdAt = createdAtTime.toDate();
            formattedDate = DateFormat(
              'dd MMM yyyy, hh:mm a',
            ).format(createdAt);
          }

          return SingleChildScrollView(
            child: DefaultTextStyle(
              style: theme.textTheme.bodyMedium!.copyWith(
                color: color.onSurface,
              ),
              child: Column(
                children: [
                  // Image Carousel
                  StatefulBuilder(
                    builder: (context, setState) {
                      final PageController pageController = PageController();
                      int currentPage = 0;

                      return Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          SizedBox(
                            height: 300,
                            child: PageView.builder(
                              controller: pageController,
                              itemCount: imageUrls.length,
                              onPageChanged: (index) {
                                setState(() => currentPage = index);
                              },
                              itemBuilder:
                                  (context, index) => Image.network(
                                    imageUrls[index],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.error),
                                  ),
                            ),
                          ),
                          if (imageUrls.length >
                              1) // Only show indicators for multiple images
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List<Widget>.generate(
                                  imageUrls.length,
                                  (index) => Container(
                                    width: 8.0,
                                    height: 8.0,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          currentPage == index
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  // Product Details
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  productData['name'] ?? 'No Name',
                                  style: theme.textTheme.headlineSmall!
                                      .copyWith(color: color.onSurface),
                                ),
                                const SizedBox(height: 8),

                                RichText(
                                  text: TextSpan(
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      color: color.onSurface,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Price: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '₹${productData['price'] ?? '0'}',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                RichText(
                                  text: TextSpan(
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      color: color.onSurface,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Quantity: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "${productData['quantity']} ${productData['unit']}",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Uploaded At: ",
                                  style: TextStyle(fontWeight: FontWeight.bold,fontStyle: FontStyle.italic ),
                                ),
                                Text(
                                  formattedDate.isNotEmpty
                                      ? formattedDate
                                      : 'Unknown',
                                      style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Description:',
                          style: theme.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color.onSurface,
                          ),
                        ),
                        Text(
                          productData['description'] ?? 'No Description',
                          style: theme.textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 16),
                        Divider(),
                        const SizedBox(height: 10),
                        // Ratings & Reviews Section
                        StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('products')
                                  .doc(productId)
                                  .collection('reviews')
                                  .snapshots(),
                          builder: (context, reviewSnapshot) {
                            if (reviewSnapshot.hasError) {
                              return Text('Error: ${reviewSnapshot.error}');
                            }

                            if (reviewSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            final reviews = reviewSnapshot.data!.docs;
                            final avgRating =
                                reviews.isEmpty
                                    ? 0.0
                                    : reviews
                                            .map(
                                              (doc) =>
                                                  (doc['rating'] ?? 0)
                                                      .toDouble(),
                                            )
                                            .reduce((a, b) => a + b) /
                                        reviews.length;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      avgRating.toStringAsFixed(1),
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${reviews.length} reviews)',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color.primary,
                                    elevation: 2,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
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
                                            (_) => ViewReviewsPage(
                                              productId: productId,
                                              sellerId: sellerId,
                                            ),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.reviews,
                                    color: color.onPrimary,
                                  ),
                                  label: Text(
                                    'View Reviews',
                                    style: TextStyle(color: color.onPrimary),
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
      ),
    );
  }
}
