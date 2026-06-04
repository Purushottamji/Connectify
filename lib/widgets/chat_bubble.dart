import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String? time;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final bool isDelivered;
  final bool isRead;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.time,
    this.isSelected = false,
    this.onLongPress,
    this.onTap,
    this.isDelivered = false,
    this.isRead = false,
  });

  bool get isImage => text.startsWith("IMAGE:");

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe
        ? Colors.pinkAccent.withOpacity(0.85)
        : Colors.cyanAccent.withOpacity(0.14);

    final textColor = isMe ? Colors.black : Colors.white;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      onTap: onTap,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              padding: const EdgeInsets.all(10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withOpacity(0.45) : bubbleColor,
                border: isSelected
                    ? Border.all(color: Colors.blueAccent, width: 1.5)
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: isImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        text.replaceFirst("IMAGE:", ""),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [
                        Text(
                          text,

                          style: TextStyle(color: textColor, fontSize: 15),
                        ),

                        if (isMe)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),

                            child: Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                Icon(
                                  Icons.done_all,

                                  size: 16,

                                  color: isRead
                                      ? Colors.blue
                                      : isDelivered
                                      ? Colors.white70
                                      : Colors.white38,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),

            if (time != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  time!,
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
