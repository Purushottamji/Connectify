import 'package:flutter/material.dart';

class GlowEffect extends StatelessWidget {
  final double top;
  final double left;
  final double size;
  final Color color;

  const GlowEffect({
    super.key,
    required this.top,
    required this.left,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}