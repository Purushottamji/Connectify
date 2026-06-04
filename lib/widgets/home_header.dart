import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onProfile;
  final VoidCallback onSettings;

  const HomeHeader({
    super.key,
    required this.onProfile,
    required this.onSettings,
  });

  Widget buildTopIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(10),

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          color: Colors.white.withOpacity(0.05),

          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),

        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),

      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),

            color: Colors.white.withOpacity(0.06),

            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),

          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),

                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,

                      gradient: LinearGradient(
                        colors: [Color(0xff8B5CF6), Color(0xff6366F1)],
                      ),
                    ),

                    child: const Icon(
                      Icons.chat_bubble,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Connectify",

                          style: GoogleFonts.lobster(
                            fontWeight: FontWeight.normal,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),

                        Text(
                          "Stay connected beautifully",

                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),

                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  buildTopIcon(icon: Icons.person, onTap: onProfile),

                  const SizedBox(width: 8),

                  buildTopIcon(icon: Icons.settings, onTap: onSettings),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
