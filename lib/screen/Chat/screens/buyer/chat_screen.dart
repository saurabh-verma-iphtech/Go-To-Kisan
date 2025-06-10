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

class BuyerChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const BuyerChatScreen({
    required this.chatId,
    required this.currentUserId,
    Key? key,
  }) : super(key: key);

  @override
  State<BuyerChatScreen> createState() => _BuyerChatScreenState();
}

class _BuyerChatScreenState extends State<BuyerChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final FocusNode _focusNode = FocusNode();

  late final StreamSubscription<QuerySnapshot> _msgSub;
  late final StreamSubscription<DocumentSnapshot> _typingSub;

  String sellerName = '';
  bool sellerTyping = false;
  String sellerProfileUrl = '';

  String buyerName = '';
  String buyerProfileUrl = '';
  bool buyerTyping = false;

  bool selectionMode = false;
  Set<String> selectedMessageIds = {};
  bool isEmojiPickerVisible = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchSellerInfo();
    fetchBuyerInfo();

    // Clear unread count
    _clearUnread();

    // Listen for new messages and mark delivered/read
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
            if (dc.type == DocumentChangeType.added &&
                data?['senderId'] != widget.currentUserId) {
              _chatService.markDelivered(widget.chatId, msgId);
              // _chatService.markRead(widget.chatId, msgId);
              _clearUnread();
            }
          }
        });

    // Listen for typing indicator from seller
    _typingSub = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .snapshots()
        .listen((doc) {
          final data = doc.data();
          setState(() {
            sellerTyping = data?['typingSeller'] == true;
          });
        });

    // Hook up focus node to send typing status as buyer
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _chatService.startTyping(widget.chatId, /*isBuyer=*/ true);
      } else {
        _chatService.stopTyping(widget.chatId, /*isBuyer=*/ true);
      }
    });
  }

  @override
  void dispose() {
    _msgSub.cancel();
    _typingSub.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearUnread() {
    FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
      'unreadCountForBuyer': 0,
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleEmojiPicker() {
    setState(() {
      isEmojiPickerVisible = !isEmojiPickerVisible;
    });
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      _chatService.sendMessage(widget.chatId, widget.currentUserId, message);
      _controller.clear();
      _scrollToBottom();
    }
  }

  Future<String?> uploadChatImageToSupabase(
    XFile imageFile,
    String senderId,
  ) async {
    try {
      final supabase = Supabase.instance.client;
      final bytes = await imageFile.readAsBytes();
      final fileName =
          'chat_images/$senderId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage
          .from('user-images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      return supabase.storage.from('user-images').getPublicUrl(fileName);
    } catch (_) {
      return null;
    }
  }

  Future<void> sendImageMessage({required ImageSource source}) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return;
    final preview = File(picked.path);
    final shouldSend = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Preview Image'),
            content: Image.file(preview),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Send'),
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
    final url = await uploadChatImageToSupabase(picked, widget.currentUserId);
    Navigator.pop(context);
    if (url != null) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
            'senderId': widget.currentUserId,
            'text': '',
            'imageUrl': url,
            'timestamp': FieldValue.serverTimestamp(),
            'deliveredAt': null,
            'readAt': null,
          });
      _scrollToBottom();
    }
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
                  sellerProfileUrl.isNotEmpty
                      ? NetworkImage(sellerProfileUrl)
                      : null,
              child: sellerProfileUrl.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sellerName.isNotEmpty ? sellerName : 'Loading...',
                  style: const TextStyle(fontSize: 18),
                ),

                // ← only show while the other side is typing
                if (sellerTyping) ...[
                  Text(
                    'Typing...',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      // color: Colors.blue,
                    ),
                  ),
                ],
              ],
            )
          ],
        ),

        // hide normal actions when in selectionMode, otherwise nothing
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
            // // Typing indicator
            // if (sellerTyping)
            //   Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Align(
            //       alignment: Alignment.centerLeft,
            //       child: Text(
            //         '$buyerName is typing...',
            //         style: const TextStyle(
            //           fontStyle: FontStyle.italic,
            //           color: Colors.grey,
            //         ),
            //       ),
            //     ),
            //   ),
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _chatService.getMessages(widget.chatId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data!;

                  for (var msg in messages) {
                    if (msg.senderId != widget.currentUserId &&
                        msg.readAt == null) {
                      _chatService.markRead(widget.chatId, msg.id);
                    }
                  }
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _scrollToBottom(),
                  );
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
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
                          color:
                              isSelected
                                  ? Colors.blue.shade100
                                  : Colors.transparent,
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
                onEmojiSelected:
                    (cat, emoji) =>
                        setState(() => _controller.text += emoji.emoji),
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
