import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime? timestamp;
  final String? imageUrl;
  final DateTime? deliveredAt; // delivered timestamp
  final DateTime? readAt; // read timestamp

  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.imageUrl,
    this.deliveredAt,
    this.readAt,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMe ? Colors.green[200] : Colors.grey[300];
    final radius =
        isMe
            ? const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            )
            : const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          // Message container (text or image)
          Container(
            constraints: const BoxConstraints(maxWidth: 250),
            decoration: BoxDecoration(color: color, borderRadius: radius),
            padding:
                imageUrl != null
                    ? const EdgeInsets.all(4)
                    : const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            child:
                imageUrl != null
                    ? _buildImageBubble(context)
                    : Text(text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),

          // Timestamp and delivery/read icons
          if (timestamp != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTimestamp(timestamp!),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(width: 4),

                  // Show double-check (seen) if readAt is non-null
                  if (readAt != null) ...[
                    const Icon(Icons.done_all, size: 12, color: Colors.blue),
                  ]
                  // Otherwise, show single-check (delivered) if deliveredAt is non-null
                  else if (deliveredAt != null) ...[
                    const Icon(Icons.done, size: 12, color: Colors.grey),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageBubble(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullImage(context, imageUrl!),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          height: 150,
          width: 150,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              height: 150,
              width: 150,
              child: Center(
                child: CircularProgressIndicator(
                  value:
                      progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              (progress.expectedTotalBytes ?? 1)
                          : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stack) {
            return const Icon(Icons.broken_image, size: 100, color: Colors.red);
          },
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final time = TimeOfDay.fromDateTime(timestamp);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
