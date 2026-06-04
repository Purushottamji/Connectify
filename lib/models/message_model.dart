class MessageModel {
  final int? id;
  final int senderId;
  final String message;
  final String? messageType;
  final String? createdAt;
  final bool isDelivered;
  final bool isRead;
  final bool isSent;
  bool isSelected;

  MessageModel({
    this.id,
    required this.senderId,
    required this.message,
    this.messageType,
    this.createdAt,
    this.isSelected=false,
    this.isDelivered = false,
    this.isSent=true,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json["id"],
      senderId: json["sender_id"] ?? json["senderId"],
      message: json["message"] ?? "",
      messageType: json["message_type"],
      createdAt: json["created_at"]?.toString(),
      isDelivered:
      json["is_delivered"] == 1,
      isRead:
      json["is_read"] == 1,
    );
  }
}
