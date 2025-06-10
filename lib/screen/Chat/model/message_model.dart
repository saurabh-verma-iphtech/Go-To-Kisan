import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final String? imageUrl;
    final DateTime? deliveredAt; // new
  final DateTime? readAt;

  ChatMessage({
    required this.imageUrl,
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
        this.deliveredAt,
    this.readAt,

  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;

    return ChatMessage(
      imageUrl: map['imageUrl'],
      id: doc.id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
       deliveredAt:
          map['deliveredAt'] != null
              ? (map['deliveredAt'] as Timestamp).toDate()
              : null,
      readAt:
          map['readAt'] != null
              ? (map['readAt'] as Timestamp).toDate()
              : null,
    );
  }
}
