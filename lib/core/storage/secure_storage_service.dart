/// Secure Storage Service for Authentication Tokens and User Sessions
/// Uses flutter_secure_storage with in-memory fallback.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage;
  final Map<String, String> _memoryFallback = {};

  SecureStorageService({FlutterSecureStorage? storage})
      : _secureStorage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const String keyAccessToken = 'fs_access_token';
  static const String keyRefreshToken = 'fs_refresh_token';
  static const String keyUserId = 'fs_user_id';
  static const String keyUserEmail = 'fs_user_email';

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      await _secureStorage.write(key: keyAccessToken, value: accessToken);
      if (refreshToken != null) {
        await _secureStorage.write(key: keyRefreshToken, value: refreshToken);
      }
    } catch (_) {
      _memoryFallback[keyAccessToken] = accessToken;
      if (refreshToken != null) {
        _memoryFallback[keyRefreshToken] = refreshToken;
      }
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: keyAccessToken) ?? _memoryFallback[keyAccessToken];
    } catch (_) {
      return _memoryFallback[keyAccessToken];
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: keyRefreshToken) ?? _memoryFallback[keyRefreshToken];
    } catch (_) {
      return _memoryFallback[keyRefreshToken];
    }
  }

  Future<void> saveUserSession({
    required String userId,
    required String email,
  }) async {
    try {
      await _secureStorage.write(key: keyUserId, value: userId);
      await _secureStorage.write(key: keyUserEmail, value: email);
    } catch (_) {
      _memoryFallback[keyUserId] = userId;
      _memoryFallback[keyUserEmail] = email;
    }
  }

  Future<void> clearSession() async {
    try {
      await _secureStorage.deleteAll();
    } catch (_) {
      // ignore
    }
    _memoryFallback.clear();
  }
}
