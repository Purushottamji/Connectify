import 'dart:ui';

import 'package:chat_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';

class AnimatedChatSplashScreen extends StatefulWidget {
  const AnimatedChatSplashScreen({super.key});

  @override
  State<AnimatedChatSplashScreen> createState() =>
      _AnimatedChatSplashScreenState();
}

class _AnimatedChatSplashScreenState extends State<AnimatedChatSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _textController;

  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<double> _rotationAnimation;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.linear));

    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _textController.forward();
      }
    });

    Future.delayed(const Duration(seconds: 3), () async {
      final loggedIn = await _authService.isLoggedIn();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) =>
              loggedIn ? const HomeScreen() : const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 700),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Widget glowingCircle({
    required double top,
    required double left,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 80,
                spreadRadius: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGlassCard() {
    return FadeTransition(
      opacity: _textFade,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 35),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: .min,
              children: [
                ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xff6C63FF), Color(0xff8B5CF6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.45),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/launcher/Connectify.png",
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "Connectify",
                  style: GoogleFonts.lobster(
                    fontWeight: FontWeight.normal,
                    fontSize: 34,
                    color: Colors.white.withOpacity(0.95),
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Connect instantly with secure messaging",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.5,
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 38),

                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(
                      Colors.deepPurple.shade200,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  "Preparing your chats...",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          glowingCircle(
            top: -60,
            left: -40,
            size: 220,
            color: Colors.deepPurple,
          ),

          glowingCircle(top: 500, left: 250, size: 180, color: Colors.blue),

          glowingCircle(
            top: 220,
            left: 280,
            size: 140,
            color: Colors.pinkAccent,
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(child: buildGlassCard()),
            ),
          ),
        ],
      ),
    );
  }
}
