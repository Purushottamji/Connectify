import 'api_service.dart';

class ChatService {
  final ApiService _api = ApiService();

  Future<int> createConversation(int user1, int user2) async {
    final res = await _api.post(
      "/conversations/create",
      data: {"user1": user1, "user2": user2},
    );

    return res.data["conversationId"];
  }

  Future<int> sendMessage({
    required int conversationId,
    required String message,
  }) async {
    final res = await _api.post(
      "/messages/send",

      data: {"conversationId": conversationId, "message": message},
    );
    return res.data["messageId"];
  }

  Future<List<dynamic>> getMessages(int conversationId) async {
    final res = await _api.get("/messages/$conversationId");
    return res.data;
  }

  Future<void> deleteMessages(List<int> ids) async {
    await _api.delete("/messages/delete", data: {"messageIds": ids});
  }
}
