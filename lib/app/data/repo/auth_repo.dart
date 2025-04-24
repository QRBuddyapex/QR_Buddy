
import 'package:qr_buddy/app/core/config/api_config.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';


class AuthRepository {
  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        "${AppUrl.login}/login.html",
        data: {
          "username": email,
          "password": password,
          "visitorId": "272ff5db735849c733e1641eb8e15d94",
        },
      );

      final data = response as Map<String, dynamic>;
      if (data["success"] == true && data["token"] != null) {

        await _tokenStorage.saveToken(data["token"]);
      }
      return data;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

  Future<String?> getToken() async {
    return await _tokenStorage.getToken();
  }
}