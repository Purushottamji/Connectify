import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/call/call_bloc.dart';
import '../../bloc/call/call_event.dart';
import '../../bloc/call/call_state.dart';

class DialingScreen extends StatefulWidget {
  const DialingScreen({super.key});

  @override
  State<DialingScreen> createState() => _DialingScreenState();
}

class _DialingScreenState extends State<DialingScreen>
    with TickerProviderStateMixin {
  late AnimationController pulseController;

  late AnimationController rotateController;

  late Animation<double> pulseAnimation;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    pulseAnimation = Tween<double>(begin: 0.85, end: 1.1).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    pulseController.dispose();

    rotateController.dispose();

    super.dispose();
  }

  String getStatus(CallStatus status) {
    switch (status) {
      case CallStatus.calling:
        return "Calling...";

      case CallStatus.ringing:
        return "Ringing...";

      case CallStatus.connecting:
        return "Connecting...";

      case CallStatus.connected:
        return "Connected";

      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CallBloc, CallState>(
        builder: (context, state) {
          return Stack(
            children: [
              // =================================
              // BACKGROUND
              // =================================
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff020617),
                      Color(0xff0f172a),
                      Color(0xff111827),
                    ],
                  ),
                ),
              ),

              // =================================
              // GLOW EFFECTS
              // =================================
              Positioned(
                top: -100,
                left: -100,
                child: _glowCircle(250, Colors.greenAccent),
              ),

              Positioned(
                bottom: -120,
                right: -120,
                child: _glowCircle(280, Colors.blueAccent),
              ),

              // =================================
              // CONTENT
              // =================================
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // =================================
                    // STATUS
                    // =================================
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),

                        color: Colors.white.withOpacity(0.06),

                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),

                      child: Text(
                        getStatus(state.status),

                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // =================================
                    // PROFILE
                    // =================================
                    AnimatedBuilder(
                      animation: pulseAnimation,

                      builder: (_, child) {
                        return Transform.scale(
                          scale: pulseAnimation.value,

                          child: child,
                        );
                      },

                      child: Stack(
                        alignment: Alignment.center,

                        children: [
                          RotationTransition(
                            turns: rotateController,

                            child: Container(
                              width: 250,
                              height: 250,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                gradient: SweepGradient(
                                  colors: [
                                    Colors.greenAccent,
                                    Colors.cyanAccent,
                                    Colors.blueAccent,
                                    Colors.greenAccent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Container(
                            width: 225,
                            height: 225,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),

                                width: 3,
                              ),
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(5),

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
                                          color: Colors.white,

                                          fontSize: 60,

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

                    const SizedBox(height: 45),

                    // =================================
                    // NAME
                    // =================================
                    Text(
                      state.callerName,

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 34,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =================================
                    // SUBTITLE
                    // =================================
                    Text(
                      getStatus(state.status),

                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),

                        fontSize: 18,
                      ),
                    ),

                    const Spacer(),

                    // =================================
                    // CALL CONTROLS
                    // =================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        _controlButton(
                          icon: Icons.mic_off_rounded,

                          color: Colors.white.withOpacity(0.15),

                          onTap: () {
                            context.read<CallBloc>().add(ToggleMuteEvent());
                          },
                        ),

                        const SizedBox(width: 30),

                        _controlButton(
                          icon: Icons.call_end_rounded,

                          color: Colors.redAccent,

                          onTap: () {
                            if (state.connectedUserId != null) {
                              context.read<CallBloc>().add(
                                EndCallEvent(state.connectedUserId!),
                              );
                            }

                            Navigator.pop(context);
                          },
                        ),

                        const SizedBox(width: 30),

                        _controlButton(
                          icon: Icons.cameraswitch_rounded,

                          color: Colors.white.withOpacity(0.15),

                          onTap: () {
                            context.read<CallBloc>().add(SwitchCameraEvent());
                          },
                        ),
                      ],
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
  // CONTROL BUTTON
  // =========================================

  Widget _controlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),

        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),

          child: Container(
            width: 78,
            height: 78,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: color,

              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),

            child: Icon(icon, color: Colors.white, size: 34),
          ),
        ),
      ),
    );
  }

  // =========================================
  // GLOW
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
        filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),

        child: const SizedBox(),
      ),
    );
  }
}
