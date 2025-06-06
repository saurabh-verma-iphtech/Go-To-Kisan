// import 'dart:async';
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:signup_login_page/screen/Chat/model/message_model.dart';
// import 'package:signup_login_page/screen/Chat/services/message_bubble.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../services/chat_service.dart';

// class SellerChatScreen extends StatefulWidget {
//   final String chatId;
//   final String currentUserId;

//   const SellerChatScreen({
//     required this.chatId,
//     required this.currentUserId,
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<SellerChatScreen> createState() => _SellerChatScreenState();
// }

// class _SellerChatScreenState extends State<SellerChatScreen>
//     with WidgetsBindingObserver {
      
//         bool partnerOnline = false;
//   DateTime? partnerLastActive;
//   StreamSubscription<DocumentSnapshot>? _presenceSub;

//   final TextEditingController _controller = TextEditingController();
//   final ChatService _chatService = ChatService();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _focusNode = FocusNode();

//   late final StreamSubscription<QuerySnapshot> _msgSub;
//   late final StreamSubscription<DocumentSnapshot> _typingSub;

//   String buyerName = '';
//   String buyerProfileUrl = '';
//   bool buyerTyping = false;

//   String sellerName = '';
//   bool sellerTyping = false;
//   String sellerProfileUrl = '';

//   bool selectionMode = false;
//   Set<String> selectedMessageIds = {};
//   bool isEmojiPickerVisible = false;
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     fetchBuyerInfo();
//     fetchSellerInfo();
//     // Clear seller's unread count when chat opens
//     _clearUnread();

//     // Listen for incoming messages to update delivered/read receipts
//     _msgSub = FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.chatId)
//         .collection('messages')
//         .orderBy('timestamp')
//         .snapshots()
//         .listen((snap) {
//           for (var dc in snap.docChanges) {
//             final msgId = dc.doc.id;
//             final data = dc.doc.data();

//             if (dc.type == DocumentChangeType.added &&
//                 data?['senderId'] != widget.currentUserId) {
//               // mark delivered & read
//               _chatService.markDelivered(widget.chatId, msgId);
//               // _chatService.markRead(widget.chatId, msgId);
//               _clearUnread();
//             }
//           }
//         });

//     // Listen for typing indicator flag from buyer
//     _typingSub = FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.chatId)
//         .snapshots()
//         .listen((doc) {
//           final data = doc.data();
//           setState(() {
//             buyerTyping = data?['typingBuyer'] == true;
//           });
//         });

//     // Hook up focus node to send typing status (toggle typingSeller flag)
//     _focusNode.addListener(() {
//       if (_focusNode.hasFocus) {
//         _chatService.startTyping(widget.chatId, /* isBuyer= */ false);
//       } else {
//         _chatService.stopTyping(widget.chatId, /* isBuyer= */ false);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _msgSub.cancel();
//     _typingSub.cancel();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   void _clearUnread() {
//     FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
//       'unreadCountForSeller': 0,
//     });
//   }

//   void _exitSelectionMode() {
//     setState(() {
//       selectionMode = false;
//       selectedMessageIds.clear();
//     });
//   }

//   void _handleMessageTap(String messageId) {
//     setState(() {
//       if (selectedMessageIds.contains(messageId)) {
//         selectedMessageIds.remove(messageId);
//         if (selectedMessageIds.isEmpty) selectionMode = false;
//       } else {
//         selectedMessageIds.add(messageId);
//       }
//     });
//   }

//   Future<void> _deleteSelectedMessages() async {
//     await _chatService.deleteMessages(
//       widget.chatId,
//       selectedMessageIds.toList(),
//     );
//     _exitSelectionMode();
//   }

//   Future<void> fetchBuyerInfo() async {
//     final chatDoc =
//         await FirebaseFirestore.instance
//             .collection('chats')
//             .doc(widget.chatId)
//             .get();

//     if (chatDoc.exists) {
//       final buyerId = chatDoc.data()?['buyerId'];
//       if (buyerId != null) {
//         final buyerDoc =
//             await FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(buyerId)
//                 .get();
//         if (buyerDoc.exists) {
//           final data = buyerDoc.data()!;
//           setState(() {
//             buyerName = data['name'] ?? 'Unknown Buyer';
//             buyerProfileUrl = data['profileImage'] ?? '';
//           });
//         }
//       }
//     }
//   }

//   Future<void> fetchSellerInfo() async {
//     final chatDoc =
//         await FirebaseFirestore.instance
//             .collection('chats')
//             .doc(widget.chatId)
//             .get();
//     if (chatDoc.exists) {
//       final sellerId = chatDoc.data()?['sellerId'];
//       if (sellerId != null) {
//         final sellerDoc =
//             await FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(sellerId)
//                 .get();
//         if (sellerDoc.exists) {
//           final data = sellerDoc.data()!;
//           setState(() {
//             sellerName = data['name'] ?? 'Unknown Seller';
//             sellerProfileUrl = data['profileImage'] ?? '';
//           });
//         }
//       }
//     }
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   void _toggleEmojiPicker() {
//     setState(() {
//       isEmojiPickerVisible = !isEmojiPickerVisible;
//     });
//   }

//   void _sendMessage() {
//     final message = _controller.text.trim();
//     if (message.isNotEmpty) {
//       _chatService.sendMessage(widget.chatId, widget.currentUserId, message);
//       _controller.clear();
//       _scrollToBottom();
//     }
//   }

//   Future<String?> uploadChatImageToSupabase(
//     XFile imageFile,
//     String senderId,
//   ) async {
//     try {
//       final supabase = Supabase.instance.client;
//       final bytes = await imageFile.readAsBytes();
//       final fileName =
//           'chat_images/$senderId/${DateTime.now().millisecondsSinceEpoch}.jpg';

//       await supabase.storage
//           .from('user-images')
//           .uploadBinary(
//             fileName,
//             bytes,
//             fileOptions: const FileOptions(contentType: 'image/jpeg'),
//           );

//       return supabase.storage.from('user-images').getPublicUrl(fileName);
//     } catch (e) {
//       print("Upload error: \$e");
//       return null;
//     }
//   }

//   Future<void> sendImageMessage({required ImageSource source}) async {
//     final pickedFile = await _picker.pickImage(source: source);
//     if (pickedFile == null) return;

//     final imageFile = File(pickedFile.path);
//     final shouldSend = await showDialog<bool>(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: const Text("Preview Image"),
//             content: Image.file(imageFile),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text("Cancel"),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text("Send"),
//               ),
//             ],
//           ),
//     );
//     if (shouldSend != true) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const Center(child: CircularProgressIndicator()),
//     );

//     final imageUrl = await uploadChatImageToSupabase(
//       pickedFile,
//       widget.currentUserId,
//     );

//     Navigator.pop(context);

//     if (imageUrl != null) {
//       await FirebaseFirestore.instance
//           .collection('chats')
//           .doc(widget.chatId)
//           .collection('messages')
//           .add({
//             'senderId': widget.currentUserId,
//             'text': '',
//             'imageUrl': imageUrl,
//             'timestamp': FieldValue.serverTimestamp(),
//           });
//       _scrollToBottom();
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Image upload failed")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         titleSpacing: -4,
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage:
//                   buyerProfileUrl.isNotEmpty
//                       ? NetworkImage(buyerProfileUrl)
//                       : null,
//               child: buyerProfileUrl.isEmpty ? const Icon(Icons.person) : null,
//             ),
//             const SizedBox(width: 8),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   buyerName.isNotEmpty ? buyerName : 'Loading...',
//                   style: const TextStyle(fontSize: 18),
//                 ),

//                 // const Spacer(),

//                 // ← only show while the other side is typing
//                 if (buyerTyping) ...[
//                   Text(
//                     'Typing...',
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontStyle: FontStyle.italic,
//                       // color: Colors.blue,
//                     ),
//                   ),
//                 ],
//               ],
//             )
//           ],
//         ),
//         actions:
//             selectionMode
//                 ? [
//                   IconButton(
//                     icon: const Icon(Icons.delete, color: Colors.red),
//                     onPressed: _deleteSelectedMessages,
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.blue),
//                     onPressed: _exitSelectionMode,
//                   ),
//                 ]
//                 : null,
//       ),
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: Column(
//           children: [
//             Expanded(
//               child: StreamBuilder<List<ChatMessage>>(
//                 stream: _chatService.getMessages(widget.chatId),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   final messages = snapshot.data!;
//                   for (var msg in messages) {
//                     if (msg.senderId != widget.currentUserId &&
//                         msg.readAt == null) {
//                       _chatService.markRead(widget.chatId, msg.id);
//                     }
//                   }
//                   WidgetsBinding.instance.addPostFrameCallback(
//                     (_) => _scrollToBottom(),
//                   );
//                   return ListView.builder(
//                     controller: _scrollController,
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                       final message = messages[index];
//                       final isMe = message.senderId == widget.currentUserId;
//                       final isSelected = selectedMessageIds.contains(
//                         message.id,
//                       );
//                       return GestureDetector(
//                         onLongPress:
//                             isMe
//                                 ? () {
//                                   setState(() {
//                                     selectionMode = true;
//                                     selectedMessageIds.add(message.id);
//                                   });
//                                 }
//                                 : null,
//                         onTap:
//                             selectionMode && isMe
//                                 ? () => _handleMessageTap(message.id)
//                                 : null,
//                         child: Container(
//                           color:
//                               isSelected
//                                   ? Colors.blue.shade100
//                                   : Colors.transparent,
//                           child: ChatMessageBubble(
//                             text: message.text,
//                             isMe: isMe,
//                             // <-- pass the DateTime? itself, not a bool
//                             timestamp: message.timestamp,
//                             imageUrl: message.imageUrl,
//                             deliveredAt: message.deliveredAt,
//                             readAt: message.readAt,
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//             if (isEmojiPickerVisible)
//               EmojiPicker(
//                 onEmojiSelected:
//                     (cat, emoji) =>
//                         setState(() => _controller.text += emoji.emoji),
//               ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 35),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.emoji_emotions),
//                     onPressed: _toggleEmojiPicker,
//                   ),
//                   Expanded(
//                     child: TextField(
//                       focusNode: _focusNode,
//                       controller: _controller,
//                       decoration: InputDecoration(
//                         hintText: 'Type a message...',
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical: 12,
//                           horizontal: 16,
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey[200],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(30),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.camera_alt),
//                     onPressed:
//                         () => sendImageMessage(source: ImageSource.camera),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.photo),
//                     onPressed:
//                         () => sendImageMessage(source: ImageSource.gallery),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.send, color: Colors.blue),
//                     onPressed: _sendMessage,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signup_login_page/screen/Chat/model/message_model.dart';
import 'package:signup_login_page/screen/Chat/services/message_bubble.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/chat_service.dart';

class SellerChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const SellerChatScreen({
    required this.chatId,
    required this.currentUserId,
    Key? key,
  }) : super(key: key);

  @override
  State<SellerChatScreen> createState() => _SellerChatScreenState();
}

class _SellerChatScreenState extends State<SellerChatScreen>
    with WidgetsBindingObserver {
  // Presence & typing flags
  bool partnerOnline = false;
  DateTime? partnerLastActive;
  StreamSubscription<DocumentSnapshot>? _presenceSub;

  // Controllers and services
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Subscriptions for real-time updates
  late final StreamSubscription<QuerySnapshot> _msgSub;
  late final StreamSubscription<DocumentSnapshot> _typingSub;

  // Chat participant info
  String buyerName = '';
  String buyerProfileUrl = '';
  bool buyerTyping = false;

  String sellerName = '';
  String sellerProfileUrl = '';
  bool sellerTyping = false;

  // Selection mode for message deletion
  bool selectionMode = false;
  Set<String> selectedMessageIds = {};

  // Emoji picker toggle
  bool isEmojiPickerVisible = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Register to observe app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Fetch participant details
    fetchBuyerInfo();
    fetchSellerInfo();
    // Clear unread count on open
    _clearUnread();

    // Listen for incoming messages to update delivery/read
    _msgSub = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snap) {
          for (var dc in snap.docChanges) {
            final msgId = dc.doc.id;
            final data = dc.doc.data();
            // On new message from other side, mark delivered
            if (dc.type == DocumentChangeType.added &&
                data?['senderId'] != widget.currentUserId) {
              _chatService.markDelivered(widget.chatId, msgId);
              _clearUnread();
            }
          }
        });

    // Listen for typing indicator flag from buyer
    _typingSub = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen((doc) {
          final data = doc.data();
          setState(() {
            buyerTyping = data?['typingBuyer'] == true;
          });
        });

    // Send typing status when this side has focus
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _chatService.startTyping(widget.chatId, /* isBuyer= */ false);
      } else {
        _chatService.stopTyping(widget.chatId, /* isBuyer= */ false);
      }
    });
  }

  @override
  void dispose() {
    // Ensure typing flag is cleared on dispose
    _chatService.stopTyping(widget.chatId, /* isBuyer= */ false);
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    // Cancel subscriptions and controllers
    _msgSub.cancel();
    _typingSub.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  // Listen for app lifecycle changes to clear typing on background/close
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _chatService.stopTyping(widget.chatId, /* isBuyer= */ false);
    }
  }

  void _clearUnread() {
    FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
      'unreadCountForSeller': 0,
    });
  }

  void _exitSelectionMode() {
    setState(() {
      selectionMode = false;
      selectedMessageIds.clear();
    });
  }

  void _handleMessageTap(String messageId) {
    setState(() {
      if (selectedMessageIds.contains(messageId)) {
        selectedMessageIds.remove(messageId);
        if (selectedMessageIds.isEmpty) selectionMode = false;
      } else {
        selectedMessageIds.add(messageId);
      }
    });
  }

  Future<void> _deleteSelectedMessages() async {
    await _chatService.deleteMessages(
      widget.chatId,
      selectedMessageIds.toList(),
    );
    _exitSelectionMode();
  }

  Future<void> fetchBuyerInfo() async {
    final chatDoc =
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .get();
    if (chatDoc.exists) {
      final buyerId = chatDoc.data()?['buyerId'];
      if (buyerId != null) {
        final buyerDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(buyerId)
                .get();
        if (buyerDoc.exists) {
          final data = buyerDoc.data()!;
          setState(() {
            buyerName = data['name'] ?? 'Unknown Buyer';
            buyerProfileUrl = data['profileImage'] ?? '';
          });
        }
      }
    }
  }

  Future<void> fetchSellerInfo() async {
    final chatDoc =
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .get();
    if (chatDoc.exists) {
      final sellerId = chatDoc.data()?['sellerId'];
      if (sellerId != null) {
        final sellerDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(sellerId)
                .get();
        if (sellerDoc.exists) {
          final data = sellerDoc.data()!;
          setState(() {
            sellerName = data['name'] ?? 'Unknown Seller';
            sellerProfileUrl = data['profileImage'] ?? '';
          });
        }
      }
    }
  }

  void _toggleEmojiPicker() {
    setState(() => isEmojiPickerVisible = !isEmojiPickerVisible);
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      _chatService.sendMessage(widget.chatId, widget.currentUserId, message);
      _controller.clear();
      // Optionally scroll or rely on reversed list
    }
  }

  Future<void> sendImageMessage({required ImageSource source}) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    final shouldSend = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Preview Image"),
            content: Image.file(imageFile),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Send"),
              ),
            ],
          ),
    );
    if (shouldSend != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final bytes = await pickedFile.readAsBytes();
    final fileName =
        'chat_images/${widget.currentUserId}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await Supabase.instance.client.storage
        .from('user-images')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    Navigator.pop(context); // remove loading

    final publicUrl = Supabase.instance.client.storage
        .from('user-images')
        .getPublicUrl(fileName);

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
          'senderId': widget.currentUserId,
          'text': '',
          'imageUrl': publicUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: -4,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  buyerProfileUrl.isNotEmpty
                      ? NetworkImage(buyerProfileUrl)
                      : null,
              child: buyerProfileUrl.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buyerName.isNotEmpty ? buyerName : 'Loading...',
                  style: const TextStyle(fontSize: 18),
                ),
                if (buyerTyping) ...[
                  Text(
                    'Typing...',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions:
            selectionMode
                ? [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteSelectedMessages,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.blue),
                    onPressed: _exitSelectionMode,
                  ),
                ]
                : null,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _chatService.getMessages(widget.chatId),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = snap.data!;
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // start at bottom now
                    itemCount: messages.length,
                    itemBuilder: (c, i) {
                      final message = messages[i];
                      final isMe = message.senderId == widget.currentUserId;
                      final isSelected = selectedMessageIds.contains(
                        message.id,
                      );
                      return GestureDetector(
                        onLongPress:
                            isMe
                                ? () {
                                  setState(() {
                                    selectionMode = true;
                                    selectedMessageIds.add(message.id);
                                  });
                                }
                                : null,
                        onTap:
                            selectionMode && isMe
                                ? () => _handleMessageTap(message.id)
                                : null,
                        child: Container(
                          color: isSelected ? Colors.blue.shade100 : null,
                          child: ChatMessageBubble(
                            text: message.text,
                            isMe: isMe,
                            timestamp: message.timestamp,
                            imageUrl: message.imageUrl,
                            deliveredAt: message.deliveredAt,
                            readAt: message.readAt,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (isEmojiPickerVisible)
              EmojiPicker(
                onEmojiSelected: (cat, emoji) {
                  setState(() => _controller.text += emoji.emoji);
                },
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 35),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions),
                    onPressed: _toggleEmojiPicker,
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed:
                        () => sendImageMessage(source: ImageSource.camera),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed:
                        () => sendImageMessage(source: ImageSource.gallery),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
