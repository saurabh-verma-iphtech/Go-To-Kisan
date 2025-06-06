import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signup_login_page/screen/Chat/screens/seller/chat_screen.dart';

class SellerChatListScreen extends StatelessWidget {
  final String sellerId;

  const SellerChatListScreen({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: false,
        title: const Text('Buyer Messages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('chats')
                .where('sellerId', isEqualTo: sellerId)
                .orderBy('lastMessageTime', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No messages from Buyers.'));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final data = chat.data() as Map<String, dynamic>;
              final chatId = chat.id;
              final unreadCount =
                  (data['unreadCountForSeller'] is int)
                      ? data['unreadCountForSeller'] as int
                      : 0;

              return StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('chats')
                        .doc(chatId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                builder: (context, messageSnapshot) {
                  if (messageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  String lastMessage = 'No messages yet';
                  if (messageSnapshot.hasData &&
                      messageSnapshot.data!.docs.isNotEmpty) {
                    final messageData =
                        messageSnapshot.data!.docs.first.data()
                            as Map<String, dynamic>;
                    lastMessage = messageData['text'] ?? lastMessage;
                  }

                  // ✅ SKIP if no messages in chat
                  if (!messageSnapshot.hasData ||
                      messageSnapshot.data!.docs.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final buyerId = data['buyerId'] as String? ?? 'Unknown Buyer';

                  return FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('users').doc(buyerId).get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Loading...'),
                          subtitle: Text('Fetching buyer info...'),
                        );
                      }

                      String buyerName = 'Unknown Buyer';
                      String? buyerProfile;
                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        final buyerData =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        buyerName = buyerData['name'] ?? buyerName;
                        buyerProfile = buyerData['profileImage'];
                      }

                      return ChatTile(
                        buyerName: buyerName,
                        lastMessage: lastMessage,
                        buyerProfile: buyerProfile,
                        unreadCount: unreadCount,
                        onTap: () async {
                          // reset seller's unread counter
                          await _firestore
                              .collection('chats')
                              .doc(chatId)
                              .update({'unreadCountForSeller': 0});

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => SellerChatScreen(
                                    currentUserId: sellerId,
                                    chatId: chatId,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final String buyerName;
  final String lastMessage;
  final String? buyerProfile;
  final int unreadCount;
  final VoidCallback onTap;

  const ChatTile({
    Key? key,
    required this.buyerName,
    required this.lastMessage,
    this.buyerProfile,
    required this.unreadCount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          backgroundImage:
              buyerProfile != null ? NetworkImage(buyerProfile!) : null,
          child:
              buyerProfile == null
                  ? const Icon(
                    Icons.account_circle,
                    size: 50,
                    color: Colors.grey,
                  )
                  : null,
        ),
        title: Text(
          buyerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          lastMessage,
          style: const TextStyle(color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (unreadCount > 0) ...[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
