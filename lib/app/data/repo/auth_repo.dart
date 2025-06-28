import 'package:qr_buddy/app/core/config/api_config.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        "${AppUrl.login}",
        data: {
          "username": email,
          "password": password,
          "visitorId": "b2d9f7071c784bb4c594972bc34b1e75",
        },
      );

      final data = response.data as Map<String, dynamic>;

      if (data["status"] == 1 && data["token"] != null) {
        final user = data["user"] as Map<String, dynamic>?;
        if (user == null || user["id"] == null || user["hco_id"] == null) {
          throw Exception("Invalid user data in response");
        }
        await _tokenStorage.saveAuthData(
          token: user["token"],
          userId: user["id"].toString(),
          hcoId: user["hco_id"].toString(), 
          userName: user["username"].toString(),
          userType: user["user_type"]?.toString() ?? "unknown",
        );
        return data;
      } else {
        throw Exception(data["message"]?.isNotEmpty == true ? data["message"] : "Login failed: Invalid response");
      }
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

}