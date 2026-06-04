import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';

class UserTitle extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final String? lastMessage;
  final bool isDelivered;
  final bool isRead;
  final bool isMe;

  const UserTitle({
    super.key,
    required this.user,
    this.onTap,
    this.lastMessage,
    this.isDelivered = false,
    this.isRead = false,
    this.isMe = false,
  });

  String getSubtitle() {
    if (user.isOnline == 1) {
      return "Online";
    }
    if (user.lastSeen != null) {
      return formatLastSeen(user.lastSeen);
    }
    return user.email;
  }

  String formatLastSeen(String? date) {
    if (date == null) {
      return "Offline";
    }

    final dt = DateTime.parse(date).toLocal();

    final now = DateTime.now();

    final difference = now.difference(dt);

    if (difference.inMinutes < 1) {
      return "Last seen just now";
    }

    if (difference.inMinutes < 60) {
      return "Last seen ${difference.inMinutes} min ago";
    }

    final isToday =
        now.day == dt.day && now.month == dt.month && now.year == dt.year;

    if (isToday) {
      return "Last seen today at ${DateFormat("hh:mm a").format(dt)}";
    }

    final yesterday = now.subtract(const Duration(days: 1));

    final isYesterday =
        yesterday.day == dt.day &&
        yesterday.month == dt.month &&
        yesterday.year == dt.year;

    if (isYesterday) {
      return "Last seen yesterday at ${DateFormat("hh:mm a").format(dt)}";
    }
    return "Last seen ${DateFormat("dd MMM, hh:mm a").format(dt)}";
  }

  @override
  Widget build(BuildContext context) {
    print("LastSeen : $lastMessage");
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.12),
            backgroundImage: user.profilePic != null
                ? NetworkImage(user.profilePic!)
                : null,
            child: user.profilePic == null
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : "U",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  )
                : null,
          ),

          if (user.isOnline == 1)
            Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                height: 14,
                width: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      subtitle: Row(
        children: [
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(right: 4),

              child: Icon(
                Icons.done_all,

                size: 16,

                color: isRead
                    ? Colors.blueAccent
                    : isDelivered
                    ? Colors.white70
                    : Colors.white38,
              ),
            ),

          Expanded(
            child: Text(
              lastMessage ?? getSubtitle(),

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                color: user.isOnline == 1 ? Colors.greenAccent : Colors.white70,

                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
