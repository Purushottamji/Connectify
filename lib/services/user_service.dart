
import 'api_service.dart';

class UserService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getUsers() async {
    final res = await _api.get("/users");
    return res.data;
  }

  Future<Map<String, dynamic>> getUserById(int id) async {
    final res = await _api.get("/users/$id");
    return res.data;
  }
}