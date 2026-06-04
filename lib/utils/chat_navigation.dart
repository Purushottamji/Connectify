import 'package:flutter/material.dart';

import '../screens/chat_screen.dart';

import '../services/auth_service.dart';
import '../services/chat_service.dart';

class ChatNavigation {
  static final AuthService _authService = AuthService();

  static final ChatService _chatService = ChatService();

  static Future<void> openChat({
    required BuildContext context,
    required dynamic user,
  }) async {
    try {
      final myId = await _authService.getStoredUserId();

      if (myId == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,

        builder: (_) {
          return Center(
            child: Container(
              height: 85,
              width: 85,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),

                color: const Color(0xff111827),

                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),

              child: const CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.deepPurpleAccent,
              ),
            ),
          );
        },
      );

      final conversationId = await _chatService.createConversation(
        myId,
        user.id,
      );

      if (!context.mounted) return;

      Navigator.pop(context);

      Navigator.push(
        context,

        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),

          reverseTransitionDuration: const Duration(milliseconds: 350),

          pageBuilder: (_, animation, secondaryAnimation) {
            return ChatScreen(
              conversationId: conversationId,
              isOnline: user.isOnline == 1,

              lastSeen: user.lastSeen,
              receiverId: user.id,

              receiverName: user.name,

              receiverImage: user.profilePic,
            );
          },

          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,

              curve: Curves.easeOutExpo,
            );

            final slideAnimation = Tween<Offset>(
              begin: const Offset(1, 0),

              end: Offset.zero,
            ).animate(curvedAnimation);

            final fadeAnimation = Tween<double>(
              begin: 0,
              end: 1,
            ).animate(curvedAnimation);

            final scaleAnimation = Tween<double>(
              begin: 0.94,
              end: 1,
            ).animate(curvedAnimation);

            return FadeTransition(
              opacity: fadeAnimation,

              child: SlideTransition(
                position: slideAnimation,

                child: ScaleTransition(scale: scaleAnimation, child: child),
              ),
            );
          },
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,

            backgroundColor: Colors.redAccent,

            content: Text("Failed to open chat\n$e"),
          ),
        );
      }
    }
  }
}
