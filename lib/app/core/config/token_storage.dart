import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _hcoIdKey = 'hco_id';
  static const String _userNameKey = 'user_name';
  static const String _userTypeKey = 'user_type';
  static const String _themeKey = 'is_dark_mode'; 

  Future<void> saveAuthData({
    required String token,
    required String userId,
    required String hcoId,
    required String userName,
    required String userType,
  }) async {
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _hcoIdKey, value: hcoId),
      _storage.write(key: _userNameKey, value: userName),
      _storage.write(key: _userTypeKey, value: userType),
    ]);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<String?> getHcoId() async {
    return await _storage.read(key: _hcoIdKey);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  Future<String?> getUserType() async {
    return await _storage.read(key: _userTypeKey);
  }

  Future<void> saveTheme(bool isDarkMode) async {
    await _storage.write(key: _themeKey, value: isDarkMode.toString());
  }

  Future<bool?> getTheme() async {
    final value = await _storage.read(key: _themeKey);
    return value != null ? value.toLowerCase() == 'true' : null;
  }

  Future<void> clearToken() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _hcoIdKey),
      _storage.delete(key: _userNameKey),
      _storage.delete(key: _userTypeKey),
      _storage.delete(key: _themeKey), 
    ]);
  }
}