import 'dart:ui';

import 'package:chat_app/bloc/user/user_bloc.dart';
import 'package:chat_app/bloc/user/user_event.dart';
import 'package:chat_app/bloc/user/user_state.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/screens/setting_screen.dart';
import 'package:chat_app/utils/chat_navigation.dart';
import 'package:chat_app/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/glass_search_bar.dart';
import '../widgets/glow_effect.dart';
import '../widgets/animated_user_card.dart';
import '../widgets/home_header.dart';
import '../services/auth_service.dart';
import '../widgets/user_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;

  final AuthService _authService = AuthService();

  final TextEditingController _searchController = TextEditingController();

  String searchQuery = "";
  int? myId;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
    _loadMyId();
    Future.microtask(() {
      context.read<UserBloc>().add(FetchUsersEvent());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();

    _searchController.dispose();

    super.dispose();
  }

  Future<void> _loadMyId() async {
    myId = await _authService.getStoredUserId();

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String error) {
    return Center(
      child: Text(
        error,
        style: const TextStyle(color: Colors.red, fontSize: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xff8B5CF6), Color(0xff6366F1)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {},
          child: const Icon(Icons.chat, color: Colors.white),
        ),
      ),

      body: AppBackground(
        child: Stack(
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

            const GlowEffect(
              top: -80,
              left: -50,
              size: 220,
              color: Colors.deepPurple,
            ),

            const GlowEffect(
              top: 120,
              left: 280,
              size: 180,
              color: Colors.blue,
            ),

            const GlowEffect(
              top: 580,
              left: -40,
              size: 220,
              color: Colors.pinkAccent,
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    List<dynamic> users = [];

                    bool isLoading = false;

                    String? error;

                    if (state is UserLoading) {
                      isLoading = true;
                    }

                    if (state is UserLoaded) {
                      users = state.users;
                    }

                    if (state is UserError) {
                      error = state.message;
                    }

                    final filteredUsers = users.where((user) {
                      return user.name.toLowerCase().contains(searchQuery);
                    }).toList();

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          child: HomeHeader(
                            onProfile: () async {
                              final myId = await _authService.getStoredUserId();

                              if (myId != null) {
                                context.read<UserBloc>().add(
                                  FetchMeEvent(myId),
                                );
                              }

                              if (!mounted) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                            },

                            onSettings: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18.0,
                            vertical: 5,
                          ),
                          child: GlassSearchBar(
                            controller: _searchController,

                            onChanged: (value) {
                              setState(() {
                                searchQuery = value.toLowerCase();
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Active Chats",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                "${filteredUsers.length} online",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.55),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        Expanded(
                          child: isLoading
                              ? _buildLoading()
                              : error != null
                              ? _buildError(error)
                              : filteredUsers.isEmpty
                              ? Center(
                                  child: Text(
                                    "No users found",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 6,
                                  ),
                                  itemCount: filteredUsers.length,
                                  itemBuilder: (ctx, i) {
                                    final u = filteredUsers[i];

                                    return AnimatedUserCard(
                                      index: i,

                                      child: UserTitle(
                                        user: u,
                                        lastMessage: u.lastMessage,

                                        isDelivered: u.isDelivered,

                                        isRead: u.isRead,

                                        isMe: u.lastSenderId == myId,
                                        onTap: () {
                                          ChatNavigation.openChat(
                                            context: context,
                                            user: u,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
