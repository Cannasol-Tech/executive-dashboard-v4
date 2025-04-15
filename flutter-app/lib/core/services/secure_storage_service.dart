import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service for securely storing sensitive data like tokens
class SecureStorageService {
  // Flutter secure storage instance with secure options
  late final FlutterSecureStorage _storage;

  // Key for storing authentication token
  static const String _authTokenKey = 'auth_token';

  // Key for storing refresh token
  static const String _refreshTokenKey = 'refresh_token';

  // Key for storing user ID
  static const String _userIdKey = 'user_id';

  // Key for storing user email
  static const String _userEmailKey = 'user_email';

  // Key for storing last login time
  static const String _lastLoginTimeKey = 'last_login_time';

  // Singleton instance
  static final SecureStorageService _instance =
      SecureStorageService._internal();

  // Factory constructor
  factory SecureStorageService() => _instance;

  // Private constructor
  SecureStorageService._internal() {
    // Initialize storage differently based on platform
    if (kIsWeb) {
      _storage = const FlutterSecureStorage(
        webOptions: WebOptions(
          dbName: 'cannasol_secure_storage',
          publicKey: 'cannasol_dashboard_pub_key',
        ),
      );
    } else {
      _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
        wOptions: WindowsOptions(),
        mOptions: MacOsOptions(),
        lOptions: LinuxOptions(),
      );
    }
  }

  // Store authentication token
  Future<void> storeAuthToken(String token) async {
    try {
      await _storage.write(key: _authTokenKey, value: token);
    } catch (e) {
      print('Error storing auth token: $e');
      // Don't throw for web, as this might be a limitation of the platform
      if (!kIsWeb) rethrow;
    }
  }

  // Get authentication token
  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _authTokenKey);
    } catch (e) {
      print('Error reading auth token: $e');
      return null;
    }
  }

  // Store refresh token
  Future<void> storeRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      print('Error storing refresh token: $e');
      if (!kIsWeb) rethrow;
    }
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      print('Error reading refresh token: $e');
      return null;
    }
  }

  // Store user ID
  Future<void> storeUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (e) {
      print('Error storing user ID: $e');
      if (!kIsWeb) rethrow;
    }
  }

  // Get user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      print('Error reading user ID: $e');
      return null;
    }
  }

  // Store user email
  Future<void> storeUserEmail(String email) async {
    try {
      await _storage.write(key: _userEmailKey, value: email);
    } catch (e) {
      print('Error storing user email: $e');
      if (!kIsWeb) rethrow;
    }
  }

  // Get user email
  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      print('Error reading user email: $e');
      return null;
    }
  }

  // Store last login time
  Future<void> storeLastLoginTime() async {
    try {
      final now = DateTime.now().toIso8601String();
      await _storage.write(key: _lastLoginTimeKey, value: now);
    } catch (e) {
      print('Error storing last login time: $e');
      if (!kIsWeb) rethrow;
    }
  }

  // Get last login time
  Future<DateTime?> getLastLoginTime() async {
    try {
      final timeString = await _storage.read(key: _lastLoginTimeKey);
      if (timeString != null) {
        return DateTime.parse(timeString);
      }
      return null;
    } catch (e) {
      print('Error reading last login time: $e');
      return null;
    }
  }

  // Clear all secure storage
  Future<void> clearStorage() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error clearing storage: $e');
      if (!kIsWeb) rethrow;
    }
  }

  // Clear authentication data only (for logout)
  Future<void> clearAuthData() async {
    try {
      await _storage.delete(key: _authTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      print('Error clearing auth data: $e');
      if (!kIsWeb) rethrow;
    }
  }

  // Check if user has stored authentication data
  Future<bool> hasAuthData() async {
    try {
      final token = await getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking auth data: $e');
      return false;
    }
  }
}
