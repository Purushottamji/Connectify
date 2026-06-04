import 'dart:ui';

import 'package:chat_app/bloc/user/user_bloc.dart';
import 'package:chat_app/bloc/user/user_event.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;

  late Animation<double> _slideAnimation;

  Future<void> _logout(BuildContext context) async {
    final auth = AuthService();

    await auth.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => const LoginScreen(),

        transitionDuration: const Duration(milliseconds: 500),

        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

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

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();

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

  Widget _buildHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 4),

              const Expanded(
                child: Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 10,
            ),

            leading: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isLogout
                    ? const LinearGradient(
                        colors: [Color(0xffEF4444), Color(0xffDC2626)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xff8B5CF6), Color(0xff6366F1)],
                      ),
              ),
              child: Icon(icon, color: Colors.white),
            ),

            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),

            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 13,
                ),
              ),
            ),

            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.45),
              size: 18,
            ),

            onTap: onTap,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

          buildGlow(top: -70, left: -50, size: 220, color: Colors.deepPurple),

          buildGlow(top: 180, left: 280, size: 180, color: Colors.blue),

          buildGlow(top: 620, left: -40, size: 220, color: Colors.pinkAccent),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 18,
                    left: 18,
                    right: 18,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),

                      const SizedBox(height: 28),

                      Expanded(
                        child: ListView(
                          children: [
                            _buildSettingTile(
                              icon: Icons.person,

                              title: "Account",

                              subtitle: "Manage your profile details",

                              onTap: () async {
                                final auth = AuthService();

                                final myId = await auth.getStoredUserId();

                                if (myId != null) {
                                  context.read<UserBloc>().add(
                                    FetchMeEvent(myId),
                                  );
                                }

                                if (!mounted) {
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileScreen(),
                                  ),
                                );
                              },
                            ),

                            _buildSettingTile(
                              icon: Icons.notifications,

                              title: "Notifications",

                              subtitle: "Control alerts and sounds",

                              onTap: () {},
                            ),

                            _buildSettingTile(
                              icon: Icons.lock,

                              title: "Privacy",

                              subtitle: "Security and privacy settings",

                              onTap: () {},
                            ),

                            _buildSettingTile(
                              icon: Icons.palette,

                              title: "Appearance",

                              subtitle: "Theme and visual preferences",

                              onTap: () {},
                            ),

                            _buildSettingTile(
                              icon: Icons.help_outline,

                              title: "Help & Support",

                              subtitle: "Get help and app support",

                              onTap: () {},
                            ),

                            const SizedBox(height: 6),

                            _buildSettingTile(
                              icon: Icons.logout,

                              title: "Logout",

                              subtitle: "Sign out from your account",

                              isLogout: true,

                              onTap: () => _logout(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
