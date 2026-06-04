import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/call/call_bloc.dart';
import '../bloc/call/call_event.dart';
import '../bloc/chat/chat_bloc.dart';
import '../bloc/chat/chat_event.dart';
import '../bloc/chat/chat_state.dart';
import '../services/auth_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/input_field.dart';
import 'call/dialing_screen.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final int receiverId;
  final String receiverName;
  final String? receiverImage;
  final bool isOnline;
  final String? lastSeen;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.receiverId,
    required this.receiverName,
    this.receiverImage,
    required this.isOnline,
    this.lastSeen,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  int? userId;
  final ScrollController _scrollController = ScrollController();

  bool get isChatReady => userId != null;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final auth = AuthService();

    userId = await auth.getStoredUserId();

    if (userId == null) return;

    final chatBloc = context.read<ChatBloc>();

    chatBloc.add(ClearChatEvent());

    chatBloc.add(InitChatEvent(widget.conversationId));

    chatBloc.add(LoadMessagesEvent(widget.conversationId));

    if (mounted) {
      setState(() {});
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  void _startVideoCall() {
    final callBloc = context.read<CallBloc>();

    callBloc.add(InitializeCallEvent());

    callBloc.add(
      StartCallEvent(
        toUserId: widget.receiverId,
        callerName: widget.receiverName,
        callerImage: widget.receiverImage ?? "",
      ),
    );

    Navigator.push(
      context,

      MaterialPageRoute(builder: (_) => const DialingScreen()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  Widget buildGlow({
    required double top,
    required double left,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,

      child: Container(
        width: size,
        height: size,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          color: color.withOpacity(0.15),

          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.45),

              blurRadius: 100,
              spreadRadius: 8,
            ),
          ],
        ),
      ),
    );
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

    return "Last seen ${DateFormat("dd MMM, hh:mm a").format(dt)}";
  }

  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),

            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
          ),

          child: SafeArea(
            bottom: false,

            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),

                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,

                    gradient: LinearGradient(
                      colors: [Color(0xff8B5CF6), Color(0xff6366F1)],
                    ),
                  ),

                  child: CircleAvatar(
                    radius: 23,

                    backgroundColor: const Color(0xff111827),

                    backgroundImage: widget.receiverImage != null
                        ? NetworkImage(widget.receiverImage!)
                        : null,

                    child: widget.receiverImage == null
                        ? Text(
                            widget.receiverName.isNotEmpty
                                ? widget.receiverName[0].toUpperCase()
                                : "U",

                            style: const TextStyle(
                              color: Colors.white,

                              fontWeight: FontWeight.bold,

                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      BlocBuilder<ChatBloc, ChatState>(
                        builder: (context, state) {
                          final bloc = context.read<ChatBloc>();

                          return Text(
                            bloc.selectionMode
                                ? "${bloc.selectedMessages.length} selected"
                                : widget.receiverName,

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          if (widget.isOnline)
                            Container(
                              height: 8,
                              width: 8,

                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                            ),

                          if (widget.isOnline) const SizedBox(width: 6),

                          Text(
                            widget.isOnline
                                ? "Online"
                                : formatLastSeen(widget.lastSeen),

                            style: TextStyle(
                              color: widget.isOnline
                                  ? Colors.greenAccent
                                  : Colors.white.withOpacity(0.6),

                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    final bloc = context.read<ChatBloc>();

                    if (!bloc.selectionMode) {
                      return const SizedBox();
                    }

                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        color: Colors.red.withOpacity(0.15),
                      ),

                      child: IconButton(
                        onPressed: () {
                          context.read<ChatBloc>().add(
                            DeleteSelectedMessageEvent(),
                          );
                        },

                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: Colors.white.withOpacity(0.08),
                  ),

                  child: IconButton(
                    onPressed: _startVideoCall,

                    icon: const Icon(
                      Icons.videocam_rounded,

                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: Colors.white.withOpacity(0.08),
                  ),

                  child: IconButton(
                    onPressed: () {},

                    icon: const Icon(
                      Icons.more_vert_rounded,

                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: Colors.white.withOpacity(0.06),

              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),

            child: const Icon(
              Icons.chat_bubble_outline,
              size: 42,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Start your conversation 👋",

            style: TextStyle(
              color: Colors.white.withOpacity(0.7),

              fontSize: 17,

              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isChatReady) {
      return const Scaffold(
        backgroundColor: Color(0xff0F172A),

        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,

                end: Alignment.bottomRight,

                colors: [
                  Color(0xff0F172A),
                  Color(0xff111827),
                  Color(0xff1E1B4B),
                ],
              ),
            ),
          ),

          buildGlow(top: 80, left: -50, size: 220, color: Colors.deepPurple),

          buildGlow(top: 500, left: 260, size: 180, color: Colors.blue),

          buildGlow(top: 250, left: 280, size: 150, color: Colors.pinkAccent),

          Column(
            children: [
              _buildHeader(),

              Expanded(
                child: BlocConsumer<ChatBloc, ChatState>(
                  listener: (context, state) {
                    if (state is ChatLoaded) {
                      Future.delayed(
                        const Duration(milliseconds: 100),
                        _scrollToBottom,
                      );

                      for (final msg in state.messages) {
                        if (msg.senderId != userId &&
                            msg.id != null &&
                            !msg.isRead) {
                          context.read<ChatBloc>().socket.markRead(msg.id!);
                        }
                      }
                    }
                  },

                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ChatLoaded) {
                      final messages = state.messages;

                      if (messages.isEmpty) {
                        return _buildEmptyChat();
                      }

                      return FadeTransition(
                        opacity: _fadeAnimation,

                        child: ListView.builder(
                          controller: _scrollController,

                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 18,
                          ),

                          itemCount: messages.length,

                          itemBuilder: (_, index) {
                            final msg = messages[index];

                            return TweenAnimationBuilder(
                              tween: Tween<double>(begin: 18, end: 0),

                              duration: Duration(
                                milliseconds: 180 + (index * 35),
                              ),

                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    msg.senderId == userId ? value : -value,

                                    value,
                                  ),

                                  child: Opacity(
                                    opacity: 1 - (value / 18),

                                    child: child,
                                  ),
                                );
                              },

                              child: MessageBubble(
                                text: msg.message,
                                isMe: msg.senderId == userId,
                                isSelected: msg.isSelected,
                                isDelivered: msg.isDelivered,
                                isRead: msg.isRead,
                                onLongPress: () {
                                  context.read<ChatBloc>().add(
                                    ToggleSelectMessageEvent(msg),
                                  );
                                },
                                onTap: () {
                                  final bloc = context.read<ChatBloc>();
                                  if (bloc.selectionMode) {
                                    bloc.add(ToggleSelectMessageEvent(msg));
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      );
                    }

                    if (state is ChatError) {
                      return Center(
                        child: Text(
                          state.message,

                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    return _buildEmptyChat();
                  },
                ),
              ),

              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),

                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.05)),
                      ),
                    ),

                    child: SafeArea(
                      top: false,

                      child: ChatInput(
                        onSend: (text) {
                          context.read<ChatBloc>().add(
                            SendMessageEvent(
                              conversationId: widget.conversationId,
                              senderId: userId!,
                              message: text,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
