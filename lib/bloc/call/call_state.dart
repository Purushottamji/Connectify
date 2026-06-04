import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

enum CallStatus {
  idle,
  calling,
  ringing,
  connecting,
  connected,
  rejected,
  ended,
  error,
}

class CallState extends Equatable {
  final CallStatus status;

  final bool isMuted;
  final bool isCameraOn;

  final String callerName;
  final String callerImage;

  final int? connectedUserId;

  final RTCVideoRenderer? localRenderer;
  final RTCVideoRenderer? remoteRenderer;

  final String? errorMessage;

  const CallState({
    this.status = CallStatus.idle,
    this.isMuted = false,
    this.isCameraOn = true,
    this.callerName = "",
    this.callerImage = "",
    this.connectedUserId,
    this.localRenderer,
    this.remoteRenderer,
    this.errorMessage,
  });

  CallState copyWith({
    CallStatus? status,
    bool? isMuted,
    bool? isCameraOn,
    String? callerName,
    String? callerImage,
    int? connectedUserId,
    RTCVideoRenderer? localRenderer,
    RTCVideoRenderer? remoteRenderer,
    String? errorMessage,
  }) {
    return CallState(
      status: status ?? this.status,
      isMuted: isMuted ?? this.isMuted,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      callerName: callerName ?? this.callerName,
      callerImage: callerImage ?? this.callerImage,
      connectedUserId:
      connectedUserId ?? this.connectedUserId,
      localRenderer:
      localRenderer ?? this.localRenderer,
      remoteRenderer:
      remoteRenderer ?? this.remoteRenderer,
      errorMessage:
      errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isMuted,
    isCameraOn,
    callerName,
    callerImage,
    connectedUserId,
    localRenderer,
    remoteRenderer,
    errorMessage,
  ];
}