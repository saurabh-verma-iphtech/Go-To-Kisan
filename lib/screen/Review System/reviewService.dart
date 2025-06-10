import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signup_login_page/screen/Review%20System/reviewModel.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReview({
    required String productId,
    required Review review,
  }) async {
    final reviewRef =
        _firestore
            .collection('products')
            .doc(productId)
            .collection('reviews')
            .doc();

    await reviewRef.set(review.toMap());
  }

  Stream<List<Review>> getReviews(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Review.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  static Future<double> getAverageRating(String productId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .collection('reviews')
            .get();

    if (snapshot.docs.isEmpty) return 0.0;

    final ratings =
        snapshot.docs.map((doc) => doc['rating'] as double).toList();
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }
}
