import 'dart:ui';

import 'package:flutter/material.dart';

class GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const GlassSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),

        child: Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),

          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              18,
            ),

            color: Colors.white
                .withOpacity(0.05),

            border: Border.all(
              color: Colors.white
                  .withOpacity(0.05),
            ),
          ),

          child: TextField(
            controller: controller,

            style: const TextStyle(
              color: Colors.white,
            ),

            onChanged: onChanged,

            decoration: InputDecoration(
              border: InputBorder.none,

              icon: Icon(
                Icons.search,
                color: Colors.white
                    .withOpacity(0.5),
              ),

              hintText: "Search people...",

              hintStyle: TextStyle(
                color: Colors.white
                    .withOpacity(0.45),
              ),
            ),
          ),
        ),
      ),
    );
  }
}