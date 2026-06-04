// lib/models/user_model.dart
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? profilePic;
  final int? isOnline;
  final String? lastSeen;
  final String? lastIp;
  final String? lastMessage;
  final bool isDelivered;
  final bool isRead;
  final int? lastSenderId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePic,
    this.isOnline,
    this.lastSeen,
    this.lastIp,
    this.lastMessage,
    this.isDelivered = false,
    this.isRead = false,
    this.lastSenderId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePic: json['profile_pic'],
      isOnline: json['is_online'],
      lastSeen: json['last_seen']?.toString(),
      lastIp: json['last_ip'],
      lastMessage: json["last_message"],
      isDelivered: json["is_delivered"] == 1,
      isRead: json["is_read"] == 1,
      lastSenderId: json["last_sender_id"],
    );
  }
}
