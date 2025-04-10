import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String review;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.review,
    required this.timestamp,
  });

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id,
      userId: map['userId'],
      userName: map['userName'],
      rating: map['rating'],
      review: map['review'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'review': review,
      'timestamp': timestamp,
    };
  }
}
