import 'package:equatable/equatable.dart';

enum CallStatus{
  idle,
  calling,
  ringing,
  connected,
  ended
}

class CallStateModel extends Equatable {
  final CallStatus status;
  final bool isMuted;
  final bool isCameraOn;
  final String callerName;
  final String callerImage;

  const CallStateModel({
    this.status = CallStatus.idle,
    this.isMuted = false,
    this.isCameraOn = true,
    this.callerName = "Unknown",
    this.callerImage = "",
  });

  CallStateModel copyWith({
    CallStatus? status,
    bool? isMuted,
    bool? isCameraOn,
    String? callerName,
    String? callerImage,
  }) {
    return CallStateModel(
      status: status ?? this.status,
      isMuted: isMuted ?? this.isMuted,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      callerName: callerName ?? this.callerName,
      callerImage: callerImage ?? this.callerImage,
    );
  }

  @override
  List<Object?> get props => [status, isMuted, isCameraOn, callerName, callerImage];
}