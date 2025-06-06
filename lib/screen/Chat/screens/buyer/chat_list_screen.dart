// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:signup_login_page/screen/Chat/screens/buyer/chat_screen.dart'; // Assuming you have this screen for buyer.

// class BuyerChatListScreen extends StatelessWidget {
//   final String buyerId;

//   const BuyerChatListScreen({required this.buyerId, Key? key})
//     : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Seller Messages'),
//         centerTitle: true,
//         // backgroundColor: Colors.green[700], // Customize as per your theme
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream:
//             _firestore
//                 .collection('chats')
//                 .where('buyerId', isEqualTo: buyerId) // Filtering by buyerId
//                 .orderBy(
//                   'lastMessageTime',
//                   descending: true,
//                 ) // Sorting by last message time
//                 .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No chats found.'));
//           }

//           final chats = snapshot.data!.docs
//             .where(
//                     (doc) =>
//                         (doc['lastMessage'] ?? '').toString().trim().isNotEmpty,
//                   )
//                   .toList();

//           if (chats.isEmpty) {
//             return const Center(child: Text('No messages yet.'));
//           }


//           return ListView.builder(
//             itemCount: chats.length,
//             itemBuilder: (context, index) {
//               final chat = chats[index];
//               final sellerId = chat['sellerId'] ?? 'Unknown Seller';
//               final lastMessage = chat['lastMessage'] ?? 'No messages yet';
//               final chatId = chat.id;

//               return FutureBuilder<DocumentSnapshot>(
//                 future: _firestore.collection('users').doc(sellerId).get(),
//                 builder: (context, sellerSnapshot) {
//                   if (sellerSnapshot.connectionState ==
//                       ConnectionState.waiting) {
//                     return const ListTile(
//                       leading: CircleAvatar(child: Icon(Icons.person)),
//                       title: Text('Loading...'),
//                       subtitle: Text('Fetching seller info...'),
//                     );
//                   }

//                   if (!sellerSnapshot.hasData || !sellerSnapshot.data!.exists) {
//                     return ChatTile(
//                       sellerName: 'Unknown Seller',
//                       lastMessage: lastMessage,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (_) => BuyerChatScreen(
//                                   currentUserId: buyerId,
//                                   chatId: chatId,
//                                 ),
//                           ),
//                         );
//                       },
//                     );
//                   }

//                   final sellerData =
//                       sellerSnapshot.data!.data() as Map<String, dynamic>;
//                   final sellerName = sellerData['name'] ?? 'Unknown Seller';
//                   final sellerProfile = sellerData['profileImage'];

//                   return ChatTile(
//                     sellerName: sellerName,
//                     lastMessage: lastMessage,
//                     buyerProfile: sellerProfile,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (_) => BuyerChatScreen(
//                                 currentUserId: buyerId,
//                                 chatId: chatId,
//                               ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class ChatTile extends StatelessWidget {
//   final String sellerName;
//   final String lastMessage;
//   final String? buyerProfile;
//   final VoidCallback onTap;

//   const ChatTile({
//     Key? key,
//     required this.sellerName,
//     required this.lastMessage,
//     this.buyerProfile,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 4,
//       child: ListTile(
//         leading: CircleAvatar(
//           radius: 30,
//           backgroundColor: Colors.white,
//           backgroundImage:
//               buyerProfile != null ? NetworkImage(buyerProfile!) : null,
//           child:
//               buyerProfile == null
//                   ? const Icon(
//                     Icons.account_circle,
//                     size: 50,
//                     color: Colors.grey,
//                   )
//                   : null,
//         ),
//         title: Text(sellerName, style: TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text(lastMessage, style: const TextStyle(color: Colors.grey)),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 18),
//         onTap: onTap,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signup_login_page/screen/Chat/screens/buyer/chat_screen.dart';

class BuyerChatListScreen extends StatelessWidget {
  final String buyerId;

  const BuyerChatListScreen({required this.buyerId, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Seller Messages'), centerTitle: false),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('chats')
                .where('buyerId', isEqualTo: buyerId)
                .orderBy('lastMessageTime', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chats found.'));
          }

          final docs =
              snapshot.data!.docs
                  .where(
                    (doc) =>
                        (doc['lastMessage'] ?? '').toString().trim().isNotEmpty,
                  )
                  .toList();

          if (docs.isEmpty) {
            return const Center(child: Text('No messages yet.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final chat = docs[index];
              final chatId = chat.id;
              final data = chat.data() as Map<String, dynamic>;
              final sellerId = data['sellerId'] as String? ?? 'Unknown';
              final unreadCount =
                  (data['unreadCountForBuyer'] is int)
                      ? data['unreadCountForBuyer'] as int
                      : 0;

              return StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('chats').doc(chatId).snapshots(),
                builder: (context, chatSnapshot) {
                  if (!chatSnapshot.hasData || !chatSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final chatData =
                      chatSnapshot.data!.data() as Map<String, dynamic>;
                  final lastMessage = chatData['lastMessage'] as String? ?? '';

                  return StreamBuilder<DocumentSnapshot>(
                    stream:
                        _firestore
                            .collection('users')
                            .doc(sellerId)
                            .snapshots(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return const ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text('Loading seller...'),
                        );
                      }

                      final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;
                      final sellerName =
                          userData['name'] as String? ?? 'Unknown Seller';
                      final sellerProfile = userData['profileImage'] as String?;

                      return ChatTile(
                        sellerName: sellerName,
                        lastMessage: lastMessage,
                        buyerProfile: sellerProfile,
                        unreadCount: unreadCount,
                        onTap: () async {
                          await _firestore
                              .collection('chats')
                              .doc(chatId)
                              .update({'unreadCountForBuyer': 0});
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BuyerChatScreen(
                                    currentUserId: buyerId,
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
  final String sellerName;
  final String lastMessage;
  final String? buyerProfile;
  final int unreadCount;
  final VoidCallback onTap;

  const ChatTile({
    Key? key,
    required this.sellerName,
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
          sellerName,
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
            if (unreadCount > 0)
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
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
