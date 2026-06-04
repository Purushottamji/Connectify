import 'package:chat_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  IO.Socket? socket;

  bool get isConnected => socket?.connected ?? false;

  Future<void> connect() async {
    try {
      if (socket != null && socket!.connected) {
        print("⚠️ Socket already connected");
        return;
      }
      if (socket != null) {
        print("🔄 Reconnecting existing socket");
        socket!.connect();
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString(AppConstants.tokenKey);

      socket = IO.io(
        AppConstants.socketUrl,

        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(20)
            .setReconnectionDelay(2000)
            .setAuth({"token": token})
            .build(),
      );

      socket!.connect();

      socket!.onConnect((_) {
        print("✅ Socket Connected");
      });

      socket!.onDisconnect((_) {
        print("❌ Socket Disconnected");
      });

      socket!.onConnectError((data) {
        print("🔥 Connect Error: $data");
      });

      socket!.onError((data) {
        print("🔥 Socket Error: $data");
      });

      socket!.onReconnect((_) {
        print("🔄 Socket Reconnected");
      });

      socket!.onAny((event, data) {
        print("📡 EVENT => $event");
      });
    } catch (e) {
      print("❌ Socket Connect Error: $e");
    }
  }

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }

  void removeAllListeners() {
    socket?.clearListeners();
  }

  void joinRoom(int conversationId) {
    socket?.emit("join_room", conversationId);
  }

  void onMessageDelivered(Function(dynamic) callback) {
    socket?.on("message_delivered", callback);
  }

  void sendMessage(Map<String, dynamic> data) {
    socket?.emit("send_message", data);
  }

  void onMessage(Function(dynamic) callback) {
    socket?.off("receive_message");

    socket?.on("receive_message", callback);
  }

  void typing(Map<String, dynamic> data) {
    socket?.emit("typing", data);
  }

  void stopTyping(Map<String, dynamic> data) {
    socket?.emit("stop_typing", data);
  }

  void onTyping(Function(dynamic) callback) {
    socket?.off("typing");

    socket?.on("typing", callback);
  }

  void onStopTyping(Function(dynamic) callback) {
    socket?.off("stop_typing");

    socket?.on("stop_typing", callback);
  }

  void startCall({
    required int toUserId,
    required String callerName,
    required String callerImage,
  }) {
    socket?.emit("call:start", {
      "toUserId": toUserId,
      "callerName": callerName,
      "callerImage": callerImage,
    });
  }

  void acceptCall(int toUserId) {
    socket?.emit("call:accept", {"toUserId": toUserId});
  }

  void rejectCall(int toUserId) {
    socket?.emit("call:reject", {"toUserId": toUserId});
  }

  void endCall(int toUserId) {
    socket?.emit("call:end", {"toUserId": toUserId});
  }

  void sendOffer({required int toUserId, required dynamic offer}) {
    socket?.emit("webrtc:offer", {"toUserId": toUserId, "offer": offer});
  }

  void sendAnswer({required int toUserId, required dynamic answer}) {
    socket?.emit("webrtc:answer", {"toUserId": toUserId, "answer": answer});
  }

  void sendIceCandidate({required int toUserId, required dynamic candidate}) {
    socket?.emit("webrtc:candidate", {
      "toUserId": toUserId,
      "candidate": candidate,
    });
  }

  void onIncomingCall(Function(dynamic) callback) {
    socket?.off("call:incoming");

    socket?.on("call:incoming", callback);
  }

  void onCallAccepted(Function(dynamic) callback) {
    socket?.off("call:accepted");

    socket?.on("call:accepted", callback);
  }

  void onCallRejected(Function(dynamic) callback) {
    socket?.off("call:rejected");

    socket?.on("call:rejected", callback);
  }

  void onCallEnded(Function(dynamic) callback) {
    socket?.off("call:ended");

    socket?.on("call:ended", callback);
  }

  void onOffer(Function(dynamic) callback) {
    socket?.off("webrtc:offer");

    socket?.on("webrtc:offer", callback);
  }

  void onAnswer(Function(dynamic) callback) {
    socket?.off("webrtc:answer");

    socket?.on("webrtc:answer", callback);
  }

  void markDelivered(int messageId) {
    socket?.emit("message_delivered", {"messageId": messageId});
  }

  void markRead(int messageId) {
    socket?.emit("message_read", {"messageId": messageId});
  }

  void onIceCandidate(Function(dynamic) callback) {
    socket?.off("webrtc:candidate");

    socket?.on("webrtc:candidate", callback);
  }
}
