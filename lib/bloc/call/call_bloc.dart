import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../core/socket_service.dart';
import '../../services/ringtone_service.dart';
import '../../services/webrtc_service.dart';

import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final SocketService socketService = SocketService();

  final WebRTCService webrtcService = WebRTCService();

  final RingtoneService ringtoneService = RingtoneService();

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();

  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  bool _initialized = false;

  CallBloc() : super(const CallState()) {
    on<InitializeCallEvent>(_onInitialize);

    on<StartCallEvent>(_onStartCall);

    on<IncomingCallEvent>(_onIncomingCall);

    on<AcceptCallEvent>(_onAcceptCall);

    on<RejectCallEvent>(_onRejectCall);

    on<EndCallEvent>(_onEndCall);

    on<SendOfferEvent>(_onSendOffer);

    on<ReceiveOfferEvent>(_onReceiveOffer);

    on<SendAnswerEvent>(_onSendAnswer);

    on<ReceiveAnswerEvent>(_onReceiveAnswer);

    on<SendIceCandidateEvent>(_onSendIceCandidate);

    on<ReceiveIceCandidateEvent>(_onReceiveIceCandidate);

    on<ToggleMuteEvent>(_onToggleMute);

    on<ToggleCameraEvent>(_onToggleCamera);

    on<SwitchCameraEvent>(_onSwitchCamera);

    on<CallAcceptedEvent>(_onCallAccepted);

    on<CallRejectedEvent>(_onCallRejected);

    on<CallEndedEvent>(_onCallEnded);

    on<ResetCallEvent>(_onResetCall);
  }

  Future<void> _onInitialize(
    InitializeCallEvent event,
    Emitter<CallState> emit,
  ) async {
    try {
      if (_initialized) return;

      await localRenderer.initialize();

      await remoteRenderer.initialize();

      await webrtcService.init();

      localRenderer.srcObject = webrtcService.localStream;

      // REMOTE STREAM

      webrtcService.onRemoteStream = (stream) {
        remoteRenderer.srcObject = stream;

        emit(state.copyWith(remoteRenderer: remoteRenderer));
      };

      webrtcService.onForceDisconnect = () async {
        add(ResetCallEvent());
      };

      socketService.onIncomingCall((data) {
        add(
          IncomingCallEvent(
            fromUserId: data["fromUserId"],
            callerName: data["callerName"],
            callerImage: data["callerImage"],
          ),
        );
      });

      socketService.onOffer((data) {
        add(
          ReceiveOfferEvent(
            fromUserId: data["fromUserId"],
            offer: data["offer"],
          ),
        );
      });

      socketService.onAnswer((data) {
        add(ReceiveAnswerEvent(data["answer"]));
      });

      socketService.onIceCandidate((data) {
        add(ReceiveIceCandidateEvent(data["candidate"]));
      });

      socketService.onCallAccepted((_) {
        add(CallAcceptedEvent());
      });

      socketService.onCallRejected((_) {
        add(CallRejectedEvent());
      });

      socketService.onCallEnded((_) {
        add(CallEndedEvent());
      });

      webrtcService.onIce((candidate) {
        if (state.connectedUserId != null) {
          add(
            SendIceCandidateEvent(
              toUserId: state.connectedUserId!,
              candidate: candidate.toMap(),
            ),
          );
        }
      });

      _initialized = true;

      print("✅ CallBloc initialized");
    } catch (e) {
      print("❌ Initialize Error: $e");
    }
  }

  Future<void> _onStartCall(
    StartCallEvent event,
    Emitter<CallState> emit,
  ) async {
    socketService.startCall(
      toUserId: event.toUserId,
      callerName: event.callerName,
      callerImage: event.callerImage,
    );

    emit(
      state.copyWith(
        status: CallStatus.calling,
        connectedUserId: event.toUserId,
        callerName: event.callerName,
        callerImage: event.callerImage,
        localRenderer: localRenderer,
      ),
    );
  }

  Future<void> _onIncomingCall(
    IncomingCallEvent event,
    Emitter<CallState> emit,
  ) async {
    if (!webrtcService.isInitialized) {
      await webrtcService.init();
    }

    await ringtoneService.playRingtone();

    emit(
      state.copyWith(
        status: CallStatus.ringing,
        connectedUserId: event.fromUserId,
        callerName: event.callerName,
        callerImage: event.callerImage,
        localRenderer: localRenderer,
      ),
    );
  }

  Future<void> _onAcceptCall(
    AcceptCallEvent event,
    Emitter<CallState> emit,
  ) async {
    await ringtoneService.stopRingtone();

    socketService.acceptCall(event.toUserId);

    emit(state.copyWith(status: CallStatus.connecting));
  }

  Future<void> _onRejectCall(
    RejectCallEvent event,
    Emitter<CallState> emit,
  ) async {
    await ringtoneService.stopRingtone();

    socketService.rejectCall(event.toUserId);

    emit(state.copyWith(status: CallStatus.rejected));
  }

  Future<void> _onEndCall(EndCallEvent event, Emitter<CallState> emit) async {
    await ringtoneService.stopRingtone();

    socketService.endCall(event.toUserId);

    await webrtcService.dispose();

    emit(const CallState(status: CallStatus.ended));
  }

  Future<void> _onSendOffer(
    SendOfferEvent event,
    Emitter<CallState> emit,
  ) async {
    socketService.sendOffer(toUserId: event.toUserId, offer: event.offer);
  }

  Future<void> _onReceiveOffer(
    ReceiveOfferEvent event,
    Emitter<CallState> emit,
  ) async {
    await webrtcService.setRemoteDesc(
      RTCSessionDescription(event.offer["sdp"], event.offer["type"]),
    );

    final answer = await webrtcService.createAnswer();

    if (answer != null) {
      add(SendAnswerEvent(toUserId: event.fromUserId, answer: answer.toMap()));
    }
  }

  Future<void> _onSendAnswer(
    SendAnswerEvent event,
    Emitter<CallState> emit,
  ) async {
    socketService.sendAnswer(toUserId: event.toUserId, answer: event.answer);

    emit(state.copyWith(status: CallStatus.connected));
  }

  Future<void> _onReceiveAnswer(
    ReceiveAnswerEvent event,
    Emitter<CallState> emit,
  ) async {
    await webrtcService.setRemoteDesc(
      RTCSessionDescription(event.answer["sdp"], event.answer["type"]),
    );

    emit(state.copyWith(status: CallStatus.connected));
  }

  Future<void> _onSendIceCandidate(
    SendIceCandidateEvent event,
    Emitter<CallState> emit,
  ) async {
    socketService.sendIceCandidate(
      toUserId: event.toUserId,
      candidate: event.candidate,
    );
  }

  Future<void> _onReceiveIceCandidate(
    ReceiveIceCandidateEvent event,
    Emitter<CallState> emit,
  ) async {
    await webrtcService.addCandidate(
      RTCIceCandidate(
        event.candidate["candidate"],
        event.candidate["sdpMid"],
        event.candidate["sdpMLineIndex"],
      ),
    );
  }

  Future<void> _onToggleMute(
    ToggleMuteEvent event,
    Emitter<CallState> emit,
  ) async {
    await webrtcService.toggleMicrophone();

    emit(state.copyWith(isMuted: !state.isMuted));
  }

  Future<void> _onToggleCamera(
    ToggleCameraEvent event,
    Emitter<CallState> emit,
  ) async {
    await webrtcService.toggleCamera();

    emit(state.copyWith(isCameraOn: !state.isCameraOn));
  }

  Future<void> _onSwitchCamera(
    SwitchCameraEvent event,
    Emitter<CallState> emit,
  ) async {
    await webrtcService.switchCamera();
  }

  Future<void> _onCallAccepted(
    CallAcceptedEvent event,
    Emitter<CallState> emit,
  ) async {
    if (!webrtcService.isInitialized) {
      await webrtcService.init();
    }
    final offer = await webrtcService.createOffer();

    if (offer != null && state.connectedUserId != null) {
      add(
        SendOfferEvent(toUserId: state.connectedUserId!, offer: offer.toMap()),
      );
    }
  }

  Future<void> _onCallRejected(
    CallRejectedEvent event,
    Emitter<CallState> emit,
  ) async {
    await ringtoneService.stopRingtone();

    await webrtcService.dispose();

    emit(state.copyWith(status: CallStatus.rejected));
  }

  Future<void> _onCallEnded(
    CallEndedEvent event,
    Emitter<CallState> emit,
  ) async {
    await ringtoneService.stopRingtone();

    await webrtcService.dispose();

    emit(const CallState(status: CallStatus.ended));
  }

  Future<void> _onResetCall(
    ResetCallEvent event,
    Emitter<CallState> emit,
  ) async {
    await ringtoneService.stopRingtone();

    await webrtcService.dispose();
    await webrtcService.init();

    localRenderer.srcObject = webrtcService.localStream;

    emit(const CallState());
  }

  @override
  Future<void> close() async {
    await localRenderer.dispose();

    await remoteRenderer.dispose();

    return super.close();
  }
}
