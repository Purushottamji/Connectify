import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;

  MediaStream? _localStream;

  MediaStream? _remoteStream;

  MediaStream? get localStream => _localStream;

  MediaStream? get remoteStream => _remoteStream;

  RTCPeerConnection? get peerConnection => _peerConnection;

  bool _initialized = false;

  bool get isInitialized => _initialized;

  void Function(MediaStream stream)? onRemoteStream;

  void Function(RTCIceConnectionState state)? onIceStateChange;

  void Function()? onForceDisconnect;

  final List<RTCIceCandidate> _pendingCandidates = [];

  final Map<String, dynamic> config = {
    "iceServers": [
      {"urls": "stun:stun.l.google.com:19302"},
    ],
  };

  Future<void> init() async {
    try {
      if (_initialized) {
        print("⚠️ WebRTC already initialized");

        return;
      }

      print("🚀 Initializing WebRTC...");

      _peerConnection = await createPeerConnection(config);

      _localStream = await navigator.mediaDevices.getUserMedia({
        "audio": true,
        "video": {"facingMode": "user"},
      });

      if (_localStream == null) {
        throw Exception("Local stream is null");
      }

      for (final track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }

      _peerConnection!.onTrack = (event) {
        print("📺 Remote track received");

        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];

          onRemoteStream?.call(_remoteStream!);
        }
      };

      _peerConnection!.onIceConnectionState = (state) {
        print("🧊 ICE State: $state");

        onIceStateChange?.call(state);

        if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
            state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
            state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
          onForceDisconnect?.call();
        }
      };

      _peerConnection!.onConnectionState = (state) {
        print("🔗 Connection State: $state");
      };

      _initialized = true;

      print("✅ WebRTC initialized successfully");
    } catch (e, stack) {
      print("🔥 WebRTC INIT ERROR: $e");

      print(stack);

      rethrow;
    }
  }

  Future<RTCSessionDescription?> createOffer() async {
    try {
      if (_peerConnection == null) {
        return null;
      }

      final offer = await _peerConnection!.createOffer({
        "offerToReceiveAudio": true,
        "offerToReceiveVideo": true,
      });

      await _peerConnection!.setLocalDescription(offer);

      print("📤 OFFER CREATED");

      return offer;
    } catch (e) {
      print("❌ OFFER ERROR: $e");

      return null;
    }
  }

  Future<RTCSessionDescription?> createAnswer() async {
    try {
      if (_peerConnection == null) {
        return null;
      }

      final answer = await _peerConnection!.createAnswer({
        "offerToReceiveAudio": true,
        "offerToReceiveVideo": true,
      });

      await _peerConnection!.setLocalDescription(answer);

      print("📤 ANSWER CREATED");

      return answer;
    } catch (e) {
      print("❌ ANSWER ERROR: $e");

      return null;
    }
  }

  Future<void> setRemoteDesc(RTCSessionDescription desc) async {
    try {
      if (_peerConnection == null) return;

      await _peerConnection!.setRemoteDescription(desc);

      print("📥 Remote description set");

      for (final candidate in _pendingCandidates) {
        await _peerConnection!.addCandidate(candidate);
      }

      _pendingCandidates.clear();
    } catch (e) {
      print("❌ RemoteDesc error: $e");
    }
  }

  void onIce(Function(RTCIceCandidate) callback) {
    if (_peerConnection == null) {
      return;
    }

    _peerConnection!.onIceCandidate = (candidate) {
      print("🧊 ICE Candidate generated");

      callback(candidate);
    };
  }

  Future<void> addCandidate(RTCIceCandidate candidate) async {
    try {
      if (_peerConnection == null) return;

      final remoteDesc = await _peerConnection!.getRemoteDescription();

      if (remoteDesc == null) {
        _pendingCandidates.add(candidate);

        print("⏳ Candidate queued");

        return;
      }

      await _peerConnection!.addCandidate(candidate);

      print("✅ ICE candidate added");
    } catch (e) {
      print("❌ Candidate error: $e");
    }
  }

  Future<void> toggleMicrophone() async {
    if (_localStream == null) {
      return;
    }

    final audioTrack = _localStream!.getAudioTracks().firstOrNull;

    if (audioTrack != null) {
      audioTrack.enabled = !audioTrack.enabled;

      print("🎤 Mic: ${audioTrack.enabled}");
    }
  }

  Future<void> toggleCamera() async {
    if (_localStream == null) {
      return;
    }

    final videoTrack = _localStream!.getVideoTracks().firstOrNull;

    if (videoTrack != null) {
      videoTrack.enabled = !videoTrack.enabled;

      print("📷 Camera: ${videoTrack.enabled}");
    }
  }

  Future<void> switchCamera() async {
    try {
      if (_localStream == null) return;

      final videoTrack = _localStream!.getVideoTracks().firstOrNull;

      if (videoTrack != null) {
        await Helper.switchCamera(videoTrack);

        print("🔄 Camera switched");
      }
    } catch (e) {
      print("❌ Switch camera error: $e");
    }
  }

  Future<void> dispose() async {
    try {
      print("🧹 Disposing WebRTC...");

      _localStream?.getTracks().forEach((track) {
        track.stop();
      });

      await _localStream?.dispose();

      await _remoteStream?.dispose();

      await _peerConnection?.close();

      await _peerConnection?.dispose();

      _localStream = null;

      _remoteStream = null;

      _peerConnection = null;

      _pendingCandidates.clear();

      _initialized = false;

      print("✅ WebRTC disposed");
    } catch (e) {
      print("❌ Dispose error: $e");
    }
  }
}
