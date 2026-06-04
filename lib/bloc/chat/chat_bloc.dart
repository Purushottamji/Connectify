import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/socket_service.dart';
import '../../models/message_model.dart';
import '../../services/chat_service.dart';

import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService api;

  final SocketService socket;

  List<MessageModel> messages = [];

  bool initialized = false;
  bool selectionMode = false;
  List<MessageModel> selectedMessages = [];

  ChatBloc({required this.api, required this.socket}) : super(ChatInitial()) {
    on<InitChatEvent>(_initChat);

    on<LoadMessagesEvent>(_loadMessages);

    on<SendMessageEvent>(_sendMessage);

    on<ReceiveMessageEvent>(_receiveMessage);
    on<ToggleSelectMessageEvent>(_toggleSelectMessage);
    on<MessageDeliveredEvent>(_messageDelivered);
    on<DeleteSelectedMessageEvent>(_deleteSelectedMessages);
    on<ClearChatEvent>(_clearChat);
  }

  Future<void> _initChat(InitChatEvent event, Emitter<ChatState> emit) async {
    try {
      if (!initialized) {
        await socket.connect();

        socket.onMessage((data) {
          socket.markDelivered(data["id"]);
        });

        socket.onMessageDelivered((data) {
          add(MessageDeliveredEvent(data["messageId"]));
        });
        initialized = true;
      }

      socket.joinRoom(event.conversationId);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _loadMessages(
    LoadMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());

      final data = await api.getMessages(event.conversationId);

      messages = data
          .map<MessageModel>((e) => MessageModel.fromJson(e))
          .toList();

      emit(ChatLoaded(List.from(messages)));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _sendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final localMessage = MessageModel(
        senderId: event.senderId,
        message: event.message,
        isRead: false,
        isDelivered: false,
        isSent: true,
      );

      messages.add(localMessage);

      emit(ChatLoaded(List.from(messages)));

      final responseMessageId = await api.sendMessage(
        conversationId: event.conversationId,

        message: event.message,
      );

      final index = messages.indexOf(localMessage);

      if (index != -1) {
        messages[index] = MessageModel(
          id: responseMessageId,

          senderId: localMessage.senderId,

          message: localMessage.message,

          messageType: localMessage.messageType,

          createdAt: localMessage.createdAt,
        );

        emit(ChatLoaded(List.from(messages)));
      }

      socket.sendMessage({
        "messageId": responseMessageId,

        "conversationId": event.conversationId,

        "message": event.message,
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _receiveMessage(ReceiveMessageEvent event, Emitter<ChatState> emit) {
    final newMessage = MessageModel.fromJson(event.data);

    final exists = messages.any(
      (m) =>
          m.message == newMessage.message && m.senderId == newMessage.senderId,
    );

    if (!exists) {
      messages.add(newMessage);

      emit(ChatLoaded(List.from(messages)));
    }
  }

  void _toggleSelectMessage(
    ToggleSelectMessageEvent event,
    Emitter<ChatState> emit,
  ) {
    final msg = event.message;

    msg.isSelected = !msg.isSelected;

    if (msg.isSelected) {
      selectedMessages.add(msg);
    } else {
      selectedMessages.remove(msg);
    }

    selectionMode = selectedMessages.isNotEmpty;

    emit(ChatLoaded(List.from(messages)));
  }

  Future<void> _deleteSelectedMessages(
    DeleteSelectedMessageEvent event,

    Emitter<ChatState> emit,
  ) async {
    try {
      final ids = selectedMessages
          .where((e) => e.id != null)
          .map((e) => e.id!)
          .toList();

      messages.removeWhere((msg) => selectedMessages.contains(msg));

      selectedMessages.clear();

      selectionMode = false;

      emit(ChatLoaded(List.from(messages)));
      if (ids.isNotEmpty) {
        await api.deleteMessages(ids);
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _messageDelivered(MessageDeliveredEvent event, Emitter<ChatState> emit) {
    final index = messages.indexWhere((m) => m.id == event.messageId);

    if (index != -1) {
      messages[index] = MessageModel(
        id: messages[index].id,

        senderId: messages[index].senderId,

        message: messages[index].message,

        messageType: messages[index].messageType,

        createdAt: messages[index].createdAt,

        isDelivered: true,

        isRead: messages[index].isRead,
      );

      emit(ChatLoaded(List.from(messages)));
    }
  }

  void _clearChat(ClearChatEvent event, Emitter<ChatState> emit) {
    messages.clear();

    emit(ChatLoaded([]));
  }
}
