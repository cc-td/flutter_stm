import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String tokenKey = 'token';
  static const String refreshTokenKey = 'refresh_token';

  // 保存token
  static Future<void> saveToken({
    required String token,
    required String refreshToken,
  }) async {
    await _storage.write(key: tokenKey, value: token);
    await _storage.write(key: refreshTokenKey, value: refreshToken);
  }
  // 读取token
  static Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }
  
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: refreshTokenKey);
  }
  // 清空token
  static Future<void> clearToken() async {
    await _storage.delete(key: tokenKey);
    await _storage.delete(key: refreshTokenKey);
  }
}
