

import 'package:qr_buddy/app/services/api_services.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.post("/login.html", {
        "username": email,
        "password": password,
        "visitorId": "8f993a890c7354a5b1e799a6054c43e2", 
      });

      return response;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }
}
