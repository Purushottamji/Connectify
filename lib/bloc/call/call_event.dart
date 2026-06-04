import 'package:equatable/equatable.dart';

abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object?> get props => [];
}


class InitializeCallEvent extends CallEvent {}

class StartCallEvent extends CallEvent {
  final int toUserId;
  final String callerName;
  final String callerImage;

  const StartCallEvent({
    required this.toUserId,
    required this.callerName,
    required this.callerImage,
  });

  @override
  List<Object?> get props => [
    toUserId,
    callerName,
    callerImage,
  ];
}


class IncomingCallEvent extends CallEvent {
  final int fromUserId;
  final String callerName;
  final String callerImage;

  const IncomingCallEvent({
    required this.fromUserId,
    required this.callerName,
    required this.callerImage,
  });

  @override
  List<Object?> get props => [
    fromUserId,
    callerName,
    callerImage,
  ];
}


class AcceptCallEvent extends CallEvent {
  final int toUserId;

  const AcceptCallEvent(this.toUserId);

  @override
  List<Object?> get props => [toUserId];
}

class RejectCallEvent extends CallEvent {
  final int toUserId;

  const RejectCallEvent(this.toUserId);

  @override
  List<Object?> get props => [toUserId];
}


class EndCallEvent extends CallEvent {
  final int toUserId;

  const EndCallEvent(this.toUserId);

  @override
  List<Object?> get props => [toUserId];
}

class SendOfferEvent extends CallEvent {
  final int toUserId;
  final dynamic offer;

  const SendOfferEvent({
    required this.toUserId,
    required this.offer,
  });

  @override
  List<Object?> get props => [
    toUserId,
    offer,
  ];
}

class ReceiveOfferEvent extends CallEvent {
  final int fromUserId;
  final dynamic offer;

  const ReceiveOfferEvent({
    required this.fromUserId,
    required this.offer,
  });

  @override
  List<Object?> get props => [
    fromUserId,
    offer,
  ];
}


class SendAnswerEvent extends CallEvent {
  final int toUserId;
  final dynamic answer;

  const SendAnswerEvent({
    required this.toUserId,
    required this.answer,
  });

  @override
  List<Object?> get props => [
    toUserId,
    answer,
  ];
}

class ReceiveAnswerEvent extends CallEvent {
  final dynamic answer;

  const ReceiveAnswerEvent(this.answer);

  @override
  List<Object?> get props => [answer];
}


class SendIceCandidateEvent extends CallEvent {
  final int toUserId;
  final dynamic candidate;

  const SendIceCandidateEvent({
    required this.toUserId,
    required this.candidate,
  });

  @override
  List<Object?> get props => [
    toUserId,
    candidate,
  ];
}

class ReceiveIceCandidateEvent extends CallEvent {
  final dynamic candidate;

  const ReceiveIceCandidateEvent(this.candidate);

  @override
  List<Object?> get props => [candidate];
}

class ToggleMuteEvent extends CallEvent {}

class ToggleCameraEvent extends CallEvent {}

class SwitchCameraEvent extends CallEvent {}


class CallAcceptedEvent extends CallEvent {}

class CallRejectedEvent extends CallEvent {}

class CallEndedEvent extends CallEvent {}


class ResetCallEvent extends CallEvent {}