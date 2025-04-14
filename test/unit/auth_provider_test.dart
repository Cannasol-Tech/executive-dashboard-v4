import 'package:flutter_test/flutter_test.dart';
import 'package:executive_dashboard/features/auth/providers/auth_provider.dart';
import '../mocks/auth_mocks.dart';

void main() {
  group('AuthProvider Tests', () {
    late TestAuthService testAuthService;
    late MockSecureStorageService mockSecureStorage;
    late AuthProvider authProvider;

    setUp(() {
      mockSecureStorage = MockSecureStorageService();
      testAuthService = TestAuthService(secureStorage: mockSecureStorage);

      // Create AuthProvider with mock service
      authProvider = AuthProvider.withAuthService(testAuthService);
    });

    tearDown(() {
      testAuthService.dispose();
    });

    test('Initial state should be unauthenticated', () {
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.userId, isNull);
      expect(authProvider.errorMessage, isNull);
      expect(authProvider.isLoading, isFalse);
    });

    test('Login with email and password should update authentication state',
        () async {
      // Act
      await authProvider.loginWithEmailAndPassword(
          'test@example.com', 'password123');

      // Assert
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.errorMessage, isNull);
      expect(authProvider.isLoading, isFalse);

      // Verify token was stored securely
      final hasToken = await mockSecureStorage.hasAuthData();
      expect(hasToken, isTrue);

      final storedToken = await mockSecureStorage.getAuthToken();
      expect(storedToken, isNotNull);
      expect(storedToken, 'email-token-123');

      // Verify user ID was stored
      final userId = await mockSecureStorage.getUserId();
      expect(userId, 'email-user-123');

      // Verify email was stored
      final email = await mockSecureStorage.getUserEmail();
      expect(email, 'test@example.com');
    });

    test('Login with invalid credentials should set error message', () async {
      // Act
      await authProvider.loginWithEmailAndPassword(
          'wrong@example.com', 'wrong-password');

      // Assert
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, isNotNull);
      expect(authProvider.isLoading, isFalse);

      // Verify no token was stored
      final hasToken = await mockSecureStorage.hasAuthData();
      expect(hasToken, isFalse);
    });

    test('Sign out should clear authentication state and secure storage',
        () async {
      // Arrange - login first
      await authProvider.loginWithEmailAndPassword(
          'test@example.com', 'password123');
      expect(authProvider.isAuthenticated, isTrue);

      // Act
      await authProvider.signOut();

      // Assert
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.userId, isNull);

      // Verify token was removed from secure storage
      final hasToken = await mockSecureStorage.hasAuthData();
      expect(hasToken, isFalse);

      final storedToken = await mockSecureStorage.getAuthToken();
      expect(storedToken, isNull);
    });

    test('Session can be restored from secure storage', () async {
      // Arrange - store auth data directly
      await mockSecureStorage.storeAuthToken('stored-token-123');
      await mockSecureStorage.storeUserId('stored-user-123');
      await mockSecureStorage.storeUserEmail('stored@example.com');

      // Set up the mock to return a user when initializing from storage
      final mockUser =
          MockUser(uid: 'stored-user-123', email: 'stored@example.com');
      testAuthService.emitAuthState(mockUser);

      // Act - create a new provider that will attempt to initialize from storage
      final newProvider = AuthProvider.withAuthService(testAuthService);
      await Future.delayed(
          Duration.zero); // Wait for initialization to complete

      // Assert
      expect(newProvider.isAuthenticated, isTrue);

      // Check if token can be retrieved
      final token = await newProvider.getIdToken();
      expect(token, 'stored-token-123');
    });

    test('Get ID token should return secure storage token', () async {
      // Arrange - login first
      await authProvider.loginWithEmailAndPassword(
          'test@example.com', 'password123');

      // Act
      final token = await authProvider.getIdToken();

      // Assert
      expect(token, isNotNull);
      expect(token, 'email-token-123');
    });

    test('Refresh token should update secure storage', () async {
      // Arrange - login first
      await authProvider.loginWithEmailAndPassword(
          'test@example.com', 'password123');

      // Act
      final token = await authProvider.refreshAuthToken();

      // Assert
      expect(token, isNotNull);
      expect(token, startsWith('refreshed-token-'));

      // Verify token was updated in secure storage
      final storedToken = await mockSecureStorage.getAuthToken();
      expect(storedToken, token);
    });
  });
}
