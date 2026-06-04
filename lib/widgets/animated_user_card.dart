import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedUserCard extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedUserCard({super.key, required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 40, end: 0),

      duration: Duration(milliseconds: 250 + (index * 70)),

      builder: (context, value, childWidget) {
        return Transform.translate(
          offset: Offset(0, value),

          child: Opacity(opacity: 1 - (value / 40), child: childWidget),
        );
      },

      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),

        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),

          child: Container(
            margin: const EdgeInsets.only(bottom: 14),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),

              color: Colors.white.withOpacity(0.06),

              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),

            child: child,
          ),
        ),
      ),
    );
  }
}
