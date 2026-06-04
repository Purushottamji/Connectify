import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../bloc/call/call_bloc.dart';
import '../../bloc/call/call_event.dart';
import '../../bloc/call/call_state.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController pulseController;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulseController.dispose();

    super.dispose();
  }

  String getStatus(CallStatus status) {
    switch (status) {
      case CallStatus.calling:
        return "Calling...";

      case CallStatus.connecting:
        return "Connecting...";

      case CallStatus.connected:
        return "Connected";

      case CallStatus.ringing:
        return "Ringing...";

      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallBloc, CallState>(
      builder: (context, state) {
        final bloc = context.read<CallBloc>();

        return Scaffold(
          backgroundColor: Colors.black,

          body: Stack(
            children: [
              // =====================================
              // REMOTE VIDEO
              // =====================================
              Positioned.fill(
                child:
                    state.remoteRenderer != null &&
                        state.remoteRenderer!.srcObject != null
                    ? RTCVideoView(
                        state.remoteRenderer!,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : Container(
                        color: Colors.black,

                        child: Center(
                          child: AnimatedBuilder(
                            animation: pulseController,

                            builder: (_, child) {
                              return Transform.scale(
                                scale: 0.95 + (pulseController.value * 0.05),

                                child: child,
                              );
                            },

                            child: CircleAvatar(
                              radius: 80,

                              backgroundColor: Colors.white10,

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

                                        fontSize: 55,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
              ),

              // =====================================
              // DARK OVERLAY
              // =====================================
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),

              // =====================================
              // TOP INFO
              // =====================================
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),

                  child: Column(
                    children: [
                      Column(
                        children: [
                          Text(
                            state.callerName,

                            style: const TextStyle(
                              color: Colors.white,

                              fontSize: 30,

                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),

                              color: Colors.white.withOpacity(0.08),
                            ),

                            child: Text(
                              getStatus(state.status),

                              style: const TextStyle(
                                color: Colors.greenAccent,

                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),

              // =====================================
              // LOCAL VIDEO
              // =====================================
              Positioned(
                top: 110,
                right: 20,

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),

                  child: Container(
                    height: 190,
                    width: 130,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),

                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),

                    child: state.localRenderer != null
                        ? RTCVideoView(
                            state.localRenderer!,
                            mirror: true,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                          )
                        : Container(color: Colors.black54),
                  ),
                ),
              ),

              // =====================================
              // CONTROLS
              // =====================================
              Align(
                alignment: Alignment.bottomCenter,

                child: Padding(
                  padding: const EdgeInsets.only(bottom: 45),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),

                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 18,
                        ),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),

                          color: Colors.white.withOpacity(0.08),

                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            // MUTE
                            _controlButton(
                              icon: state.isMuted
                                  ? Icons.mic_off_rounded
                                  : Icons.mic_rounded,

                              color: state.isMuted
                                  ? Colors.redAccent
                                  : Colors.white.withOpacity(0.12),

                              onTap: () {
                                bloc.add(ToggleMuteEvent());
                              },
                            ),

                            const SizedBox(width: 18),

                            // END
                            _controlButton(
                              icon: Icons.call_end_rounded,

                              color: Colors.redAccent,

                              isBig: true,

                              onTap: () {
                                if (state.connectedUserId != null) {
                                  bloc.add(
                                    EndCallEvent(state.connectedUserId!),
                                  );
                                }

                                Navigator.pop(context);
                              },
                            ),

                            const SizedBox(width: 18),

                            // CAMERA
                            _controlButton(
                              icon: state.isCameraOn
                                  ? Icons.videocam_rounded
                                  : Icons.videocam_off_rounded,

                              color: state.isCameraOn
                                  ? Colors.white.withOpacity(0.12)
                                  : Colors.redAccent,

                              onTap: () {
                                bloc.add(ToggleCameraEvent());
                              },
                            ),

                            const SizedBox(width: 18),

                            // SWITCH CAMERA
                            _controlButton(
                              icon: Icons.flip_camera_android_rounded,

                              color: Colors.white.withOpacity(0.12),

                              onTap: () {
                                bloc.add(SwitchCameraEvent());
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _controlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isBig = false,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        width: isBig ? 72 : 58,
        height: isBig ? 72 : 58,

        decoration: BoxDecoration(shape: BoxShape.circle, color: color),

        child: Icon(icon, color: Colors.white, size: isBig ? 34 : 28),
      ),
    );
  }
}
