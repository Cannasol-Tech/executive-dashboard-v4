import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../lib/core/services/services.dart';
import '../../lib/features/auth/models/user_model.dart';

// Mock Firebase Auth User
class MockUser implements UserModel {
  final String _uid;
  final String? _email;
  final String? _displayName;

  MockUser({
    String uid = 'test-uid',
    String? email = 'test@example.com',
    String? displayName = 'Test User',
  })  : _uid = uid,
        _email = email,
        _displayName = displayName;

  @override
  String get uid => _uid;

  @override
  String get email => _email ?? '';

  @override
  String get displayName => _displayName ?? '';

  @override
  String? get photoURL => null;

  @override
  bool get emailVerified => true;

  @override
  bool get isAnonymous => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock UserCredential
class MockUserCredential implements UserCredential {
  final MockUser _user;

  MockUserCredential({MockUser? user}) : _user = user ?? MockUser();

  @override
  UserModel? get user => _user;

  @override
  AdditionalUserInfo? get additionalUserInfo => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock implementation of SecureStorageService
class MockSecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<void> storeAuthToken(String token) async {
    _storage['auth_token'] = token;
  }

  @override
  Future<String?> getAuthToken() async {
    return _storage['auth_token'];
  }

  @override
  Future<void> storeRefreshToken(String token) async {
    _storage['refresh_token'] = token;
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage['refresh_token'];
  }

  @override
  Future<void> storeUserId(String userId) async {
    _storage['user_id'] = userId;
  }

  @override
  Future<String?> getUserId() async {
    return _storage['user_id'];
  }

  @override
  Future<void> storeUserEmail(String email) async {
    _storage['user_email'] = email;
  }

  @override
  Future<String?> getUserEmail() async {
    return _storage['user_email'];
  }

  @override
  Future<void> storeLastLoginTime() async {
    _storage['last_login_time'] = DateTime.now().toIso8601String();
  }

  @override
  Future<DateTime?> getLastLoginTime() async {
    final timeString = _storage['last_login_time'];
    if (timeString != null) {
      return DateTime.parse(timeString);
    }
    return null;
  }

  @override
  Future<void> clearStorage() async {
    _storage.clear();
  }

  @override
  Future<void> clearAuthData() async {
    _storage.remove('auth_token');
    _storage.remove('refresh_token');
  }

  @override
  Future<bool> hasAuthData() async {
    return _storage.containsKey('auth_token') &&
        _storage['auth_token'] != null &&
        _storage['auth_token']!.isNotEmpty;
  }
}

// Test implementation of AuthService for testing
class TestAuthService implements AuthServiceInterface {
  final _authStateController = StreamController<UserModel?>.broadcast();
  UserModel? _mockCurrentUser;
  final MockSecureStorageService _secureStorage;

  TestAuthService({
    MockSecureStorageService? secureStorage,
    UserModel? initialUser,
  })  : _secureStorage = secureStorage ?? MockSecureStorageService(),
        _mockCurrentUser = initialUser;

  @override
  Stream<UserModel> get authStateChanges => _authStateController.stream
      .where((user) => user != null)
      .cast<UserModel>();

  @override
  UserModel get currentUser {
    if (_mockCurrentUser == null) {
      throw Exception('No current user');
    }
    return _mockCurrentUser as UserModel;
  }

  @override
  bool get isAuthenticated => _mockCurrentUser != null;

  void emitAuthState(UserModel? user) {
    _mockCurrentUser = user;
    _authStateController.add(user);
  }

  @override
  Future<bool> initializeFromStorage() async {
    // Simulate fetching from secure storage
    final hasAuthData = await _secureStorage.hasAuthData();
    return hasAuthData;
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    // Simulate successful sign-in
    final mockUser =
        MockUser(uid: 'google-user-123', email: 'google-user@example.com');

    final credential = MockUserCredential(user: mockUser);

    _mockCurrentUser = mockUser;
    _authStateController.add(mockUser);

    await _secureStorage.storeAuthToken('google-token-123');
    await _secureStorage.storeUserId(mockUser.uid);
    if (mockUser.email != null) {
      await _secureStorage.storeUserEmail(mockUser.email!);
    }
    await _secureStorage.storeLastLoginTime();

    return credential;
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    if (email == 'test@example.com' && password == 'password123') {
      final mockUser = MockUser(uid: 'email-user-123', email: email);

      final credential = MockUserCredential(user: mockUser);

      _mockCurrentUser = mockUser;
      _authStateController.add(mockUser);

      await _secureStorage.storeAuthToken('email-token-123');
      await _secureStorage.storeUserId(mockUser.uid);
      if (mockUser.email != null) {
        await _secureStorage.storeUserEmail(mockUser.email!);
      }
      await _secureStorage.storeLastLoginTime();

      return credential;
    } else {
      throw FirebaseAuthException(
        code: 'wrong-password',
        message:
            'The password is invalid or the user does not have a password.',
      );
    }
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    final mockUser = MockUser(uid: 'new-user-123', email: email);

    final credential = MockUserCredential(user: mockUser);

    _mockCurrentUser = mockUser;
    _authStateController.add(mockUser);

    await _secureStorage.storeAuthToken('new-user-token-123');
    await _secureStorage.storeUserId(mockUser.uid);
    if (mockUser.email != null) {
      await _secureStorage.storeUserEmail(mockUser.email!);
    }
    await _secureStorage.storeLastLoginTime();

    return credential;
  }

  @override
  Future<void> updateUserProfile(
      {String? displayName, String? photoURL}) async {
    // This is just a mock implementation
    return;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // This is just a mock implementation
    return;
  }

  @override
  Future<void> signOut() async {
    _mockCurrentUser = null;
    _authStateController.add(null);
    await _secureStorage.clearAuthData();
  }

  @override
  Future<String> getIdToken() async {
    if (_mockCurrentUser == null) {
      throw Exception('User is not authenticated');
    }

    final storedToken = await _secureStorage.getAuthToken();
    if (storedToken != null) {
      return storedToken;
    }

    return 'mock-id-token-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<String> refreshToken() async {
    if (_mockCurrentUser == null) {
      throw Exception('User is not authenticated');
    }

    final newToken = 'refreshed-token-${DateTime.now().millisecondsSinceEpoch}';
    await _secureStorage.storeAuthToken(newToken);
    return newToken;
  }

  @override
  Future<Map<String, dynamic>> getUserSessionInfo() async {
    final userId = await _secureStorage.getUserId();
    final userEmail = await _secureStorage.getUserEmail();
    final lastLoginTime = await _secureStorage.getLastLoginTime();

    return {
      'userId': userId,
      'userEmail': userEmail,
      'lastLoginTime': lastLoginTime?.toIso8601String(),
      'isAuthenticated': await _secureStorage.hasAuthData(),
    };
  }

  @override
  Future<bool> hasPermission(String permission) async {
    // Mock permission check - always return true
    return true;
  }

  void dispose() {
    _authStateController.close();
  }
}

// Mock Firebase User Model
class MockUserModel extends UserModel {
  MockUserModel({
    required String uid,
    required String email,
    String displayName = 'Test User',
    String? photoUrl,
    String role = 'user',
    List<String> permissions = const ['read'],
    Map<String, dynamic>? preferences,
  }) : super(
          uid: uid,
          email: email,
          displayName: displayName,
          photoUrl: photoUrl,
          role: role,
          permissions: permissions,
          preferences: preferences,
        );
}
