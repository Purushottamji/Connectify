import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/call/call_bloc.dart';
import '../../bloc/call/call_event.dart';
import '../../bloc/call/call_state.dart';

class IncomingCallScreen extends StatefulWidget {
  const IncomingCallScreen({super.key});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with TickerProviderStateMixin {
  late AnimationController pulseController;

  late AnimationController rotateController;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    pulseController.dispose();

    rotateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CallBloc, CallState>(
        builder: (context, state) {
          return Stack(
            children: [
              // =====================
              // BACKGROUND
              // =====================
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff0f172a),
                      Color(0xff111827),
                      Color(0xff1e293b),
                    ],
                  ),
                ),
              ),

              // =====================
              // BLUR CIRCLES
              // =====================
              Positioned(
                top: -120,
                left: -80,
                child: _glowCircle(250, Colors.blueAccent),
              ),

              Positioned(
                bottom: -120,
                right: -80,
                child: _glowCircle(250, Colors.purpleAccent),
              ),

              // =====================
              // CONTENT
              // =====================
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    const Text(
                      "Incoming Video Call",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                    ),

                    const Spacer(),

                    // =====================
                    // AVATAR
                    // =====================
                    AnimatedBuilder(
                      animation: pulseController,
                      builder: (_, child) {
                        return Transform.scale(
                          scale: 0.92 + (pulseController.value * 0.08),
                          child: child,
                        );
                      },

                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          RotationTransition(
                            turns: rotateController,
                            child: Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    Colors.blueAccent,
                                    Colors.purpleAccent,
                                    Colors.cyanAccent,
                                    Colors.blueAccent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 3,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey.shade900,
                                backgroundImage: state.callerImage.isNotEmpty
                                    ? NetworkImage(state.callerImage)
                                    : null,
                                child: state.callerImage.isEmpty
                                    ? Text(
                                        state.callerName.isNotEmpty
                                            ? state.callerName[0].toUpperCase()
                                            : "U",
                                        style: const TextStyle(
                                          fontSize: 60,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // =====================
                    // NAME
                    // =====================
                    Text(
                      state.callerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Video Calling...",
                      style: TextStyle(color: Colors.white60, fontSize: 16),
                    ),

                    const Spacer(),

                    // =====================
                    // BUTTONS
                    // =====================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // REJECT
                          _actionButton(
                            icon: Icons.call_end_rounded,
                            color: Colors.redAccent,
                            label: "Decline",
                            onTap: () {
                              if (state.connectedUserId != null) {
                                context.read<CallBloc>().add(
                                  RejectCallEvent(state.connectedUserId!),
                                );
                              }

                              Navigator.pop(context);
                            },
                          ),

                          // ACCEPT
                          _actionButton(
                            icon: Icons.videocam_rounded,
                            color: Colors.greenAccent,
                            label: "Accept",
                            onTap: () {
                              if (state.connectedUserId != null) {
                                context.read<CallBloc>().add(
                                  AcceptCallEvent(state.connectedUserId!),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =========================================
  // BUTTON
  // =========================================

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),

            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

              child: Container(
                width: 80,
                height: 80,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: color.withOpacity(0.18),

                  border: Border.all(color: color.withOpacity(0.4)),
                ),

                child: Icon(icon, color: Colors.white, size: 38),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // =========================================
  // GLOW CIRCLE
  // =========================================

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: color.withOpacity(0.18),
      ),

      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),

        child: const SizedBox(),
      ),
    );
  }
}
