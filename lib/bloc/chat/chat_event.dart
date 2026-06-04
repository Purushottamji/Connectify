import 'package:chat_app/models/message_model.dart';

abstract class ChatEvent {}

class InitChatEvent extends ChatEvent {
  final int conversationId;

  InitChatEvent(this.conversationId);
}

class LoadMessagesEvent extends ChatEvent {
  final int conversationId;

  LoadMessagesEvent(this.conversationId);
}

class SendMessageEvent extends ChatEvent {
  final int conversationId;
  final int senderId;
  final String message;

  SendMessageEvent({
    required this.conversationId,
    required this.senderId,
    required this.message,
  });
}

class ReceiveMessageEvent extends ChatEvent {
  final dynamic data;

  ReceiveMessageEvent(this.data);
}

class ClearChatEvent extends ChatEvent {}

class ToggleSelectMessageEvent extends ChatEvent {
  final MessageModel message;

  ToggleSelectMessageEvent(this.message);
}

class MessageDeliveredEvent extends ChatEvent {
  final int messageId;

  MessageDeliveredEvent(this.messageId);
}

class DeleteSelectedMessageEvent extends ChatEvent {}
