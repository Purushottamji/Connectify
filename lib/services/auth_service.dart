import 'package:shared_preferences/shared_preferences.dart';
import '../core/socket_service.dart';
import '../utils/constants.dart';
import 'package:dio/dio.dart';

import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final Response response = await _api.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print("Response: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        final token = data['token'];
        final user = data['user'];

        if (token != null && user != null) {
          final prefs = await SharedPreferences.getInstance();

          await prefs.setString(AppConstants.tokenKey, token);
          await prefs.setInt(AppConstants.userIdKey, user['id']);
        }

        return {
          'success': true,
          'data': data,
        };
      }

      return {
        'success': false,
        'message': "Login failed",
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password, {
        String? profilePic,
      }) async {
    try {
      final Response response = await _api.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'user_pic': profilePic,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
        };
      }

      return {
        'success': false,
        'message': "Registration failed",
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ??
            e.message ??
            "Server error",
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<String?> uploadProfileImage(String imagePath) async {
    try {
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(imagePath),
      });

      final response = await _api.post(
        "/messages/upload",
        data: formData,
      );

      return response.data["url"];
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(AppConstants.tokenKey);
    final userId = prefs.getInt(AppConstants.userIdKey);

    return token != null && userId != null;
  }

  Future<void> logout() async {
    SocketService().disconnect();

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userIdKey);
  }

  Future<int?> getStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.userIdKey);
  }
}