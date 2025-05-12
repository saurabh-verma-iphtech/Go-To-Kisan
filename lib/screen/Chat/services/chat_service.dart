import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:signup_login_page/screen/Chat/model/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Starts or retrieves a chat between buyer and seller.
  Future<String> startChat(String buyerId, String sellerId) async {
    final existing =
        await _firestore
            .collection('chats')
            .where('buyerId', isEqualTo: buyerId)
            .where('sellerId', isEqualTo: sellerId)
            .limit(1)
            .get();

    if (existing.docs.isNotEmpty) return existing.docs.first.id;

    final ref = await _firestore.collection('chats').add({
      'buyerId': buyerId,
      'sellerId': sellerId,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': null,
      'unreadCountForBuyer': 0,
      'unreadCountForSeller': 0,
      'typingBuyer': false,
      'typingSeller': false,
    });
    return ref.id;
  }

  /// Sends a text message.
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    await _createMessage(
      chatId: chatId,
      senderId: senderId,
      content: {'text': text},
    );
  }

  /// Sends an image message (uses Firebase Storage).
  Future<void> sendImageMessage(
    String chatId,
    String senderId,
    File imageFile,
  ) async {
    final upload = await _storage
        .ref('chat_images/${DateTime.now().millisecondsSinceEpoch}')
        .putFile(imageFile);
    final url = await upload.ref.getDownloadURL();

    await _createMessage(
      chatId: chatId,
      senderId: senderId,
      content: {'text': '', 'imageUrl': url},
    );
  }

  /// Internal: creates a message and atomically updates chat header.
  Future<void> _createMessage({
    required String chatId,
    required String senderId,
    required Map<String, dynamic> content,
  }) async {
    final headerRef = _firestore.collection('chats').doc(chatId);
    final headerSnap = await headerRef.get();
    if (!headerSnap.exists) return;
    final data = headerSnap.data()!;

    // Determine who to increment
    final buyerId = data['buyerId'] as String;
    final sellerId = data['sellerId'] as String;
    final isSeller = senderId == sellerId;
    final incrementField =
        isSeller ? 'unreadCountForBuyer' : 'unreadCountForSeller';

    // Compose message payload
    final msgData = {
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
      'deliveredAt': null,
      'readAt': null,
      ...content,
    };

    // Add message
    await headerRef.collection('messages').add(msgData);

    // Update header
    await headerRef.update({
      'lastMessage': content['text'] ?? '[Image]',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': senderId,
      incrementField: FieldValue.increment(1),
    });
  }

  /// Marks a single message as delivered, only if not already set.
  Future<void> markDelivered(String chatId, String messageId) async {
    final msgRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(msgRef);
      if (!snap.exists) return;
      final data = snap.data()!;
      if (data['deliveredAt'] == null) {
        tx.update(msgRef, {'deliveredAt': FieldValue.serverTimestamp()});
      }
    });
  }

  /// Marks a single message as read, only if not already set.
  Future<void> markRead(String chatId, String messageId) async {
    final msgRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(msgRef);
      if (!snap.exists) return;
      final data = snap.data()!;
      if (data['readAt'] == null) {
        tx.update(msgRef, {'readAt': FieldValue.serverTimestamp()});
      }
    });
  }

  /// Typing indicator.
  Future<void> startTyping(String chatId, bool isBuyer) {
    return _firestore.collection('chats').doc(chatId).update({
      isBuyer ? 'typingBuyer' : 'typingSeller': true,
    });
  }

  Future<void> stopTyping(String chatId, bool isBuyer) {
    return _firestore.collection('chats').doc(chatId).update({
      isBuyer ? 'typingBuyer' : 'typingSeller': false,
    });
  }

  /// Deletes messages and adjusts unread counts in a transaction.
  Future<void> deleteMessages(String chatId, List<String> messageIds) async {
    final headerRef = _firestore.collection('chats').doc(chatId);
    final headerSnap = await headerRef.get();
    if (!headerSnap.exists) return;
    final data = headerSnap.data()!;
    final buyerId = data['buyerId'] as String;
    final sellerId = data['sellerId'] as String;

    int decBuyer = 0, decSeller = 0;
    for (var id in messageIds) {
      final msgRef = headerRef.collection('messages').doc(id);
      final msgSnap = await msgRef.get();
      if (!msgSnap.exists) continue;
      final senderId = msgSnap.data()!['senderId'] as String;
      if (senderId == sellerId) decBuyer++;
      if (senderId == buyerId) decSeller++;
      await msgRef.delete();
    }

    await _firestore.runTransaction((tx) async {
      final fresh = (await tx.get(headerRef)).data()!;
      int curB = (fresh['unreadCountForBuyer'] ?? 0) as int;
      int curS = (fresh['unreadCountForSeller'] ?? 0) as int;
      tx.update(headerRef, {
        'unreadCountForBuyer': (curB - decBuyer).clamp(0, curB),
        'unreadCountForSeller': (curS - decSeller).clamp(0, curS),
      });
    });
  }

  /// Streams chat messages oldest→newest.
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => ChatMessage.fromDocument(doc)).toList(),
        );
  }

  /// Streams buyer or seller chat headers.
  Stream<QuerySnapshot> getBuyerChats(String buyerId) {
    return _firestore
        .collection('chats')
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getSellerChats(String sellerId) {
    return _firestore
        .collection('chats')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}
