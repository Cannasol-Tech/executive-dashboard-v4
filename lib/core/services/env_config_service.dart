import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfigService {
  static final EnvConfigService _instance = EnvConfigService._internal();

  /// Singleton instance
  factory EnvConfigService() => _instance;

  EnvConfigService._internal();

  bool _isInitialized = false;
  String _currentEnv = 'development';

  /// Initialize the environment configuration
  Future<void> initialize({String env = 'development'}) async {
    if (_isInitialized) return;

    _currentEnv = env;
    String fileName = '.env.$env';

    // In release mode, always use production unless explicitly specified
    if (kReleaseMode && env == 'development') {
      _currentEnv = 'production';
      fileName = '.env.production';
    }

    try {
      await dotenv.load(fileName: 'env/$fileName');
      _isInitialized = true;
      debugPrint('Environment config loaded: $_currentEnv');
    } catch (e) {
      debugPrint('Failed to load environment config: $e');
      // Fallback to development if cannot load the specified env
      if (env != 'development') {
        await initialize(env: 'development');
      }
    }
  }
  
  /// Get a string value from environment configuration
  String getString(String key, {String defaultValue = ''}) {
    _ensureInitialized();
    return dotenv.env[key] ?? defaultValue;
  }

  /// Get a boolean value from environment configuration
  bool getBool(String key, {bool defaultValue = false}) {
    _ensureInitialized();
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// Get an integer value from environment configuration
  int getInt(String key, {int defaultValue = 0}) {
    _ensureInitialized();
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Get a double value from environment configuration
  double getDouble(String key, {double defaultValue = 0.0}) {
    _ensureInitialized();
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  /// Get the current environment name
  String get currentEnvironment => _currentEnv;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if we're running in development mode
  bool get isDevelopment => _currentEnv == 'development';

  /// Check if we're running in staging mode
  bool get isStaging => _currentEnv == 'staging';

  /// Check if we're running in production mode
  bool get isProduction => _currentEnv == 'production';

  /// Check if debug mode is enabled
  bool get isDebugModeEnabled =>
      getBool('ENABLE_DEBUG_MODE', defaultValue: false);

  /// Check if analytics logging is enabled
  bool get isAnalyticsLoggingEnabled =>
      getBool('ENABLE_ANALYTICS_LOGGING', defaultValue: true);

  /// Check if mock data should be used
  bool get useMockData => getBool('ENABLE_MOCK_DATA', defaultValue: false);

  /// Get the API URL
  String get apiUrl => getString('API_URL');

  /// Get the chatbot API URL
  String get chatbotApiUrl => getString('CHATBOT_API_URL');

  /// Get the Firebase project ID
  String get firebaseProjectId => getString('FIREBASE_PROJECT_ID');

  /// Get the Firebase hosting URL
  String get firebaseHostingUrl => getString('FIREBASE_HOSTING_URL');

  /// Get the cache duration in minutes
  int get cacheDurationMinutes =>
      getInt('CACHE_DURATION_MINUTES', defaultValue: 5);

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
          'EnvConfigService is not initialized. Call initialize() first.');
    }
  }
}
