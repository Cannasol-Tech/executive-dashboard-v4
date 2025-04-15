import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../../core/services/secure_storage_service.dart';
import '../models/user_model.dart';
import 'auth_service_interface.dart';

/// Authentication service for the Cannasol Executive Dashboard
class AuthService implements AuthServiceInterface {
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Secure storage service
  final SecureStorageService _secureStorage = SecureStorageService();

  // Stream of authentication state changes
  @override
  Stream<UserModel> get authStateChanges =>
      _auth.authStateChanges().asyncMap((firebaseUser) async {
        // Fetch additional user data from Firestore or other sources
        return UserModel.fromFirebaseUser(firebaseUser);
      });

  // Get current user
  @override
  UserModel get currentUser => UserModel.fromFirebaseUser(_auth.currentUser);

  // Check if user is authenticated
  @override
  bool get isAuthenticated => _auth.currentUser != null;

  // Singleton instance
  static final AuthService _instance = AuthService._internal();

  // Factory constructor
  factory AuthService() => _instance;

  // Private constructor
  AuthService._internal();

  // Check for existing auth and restore session
  @override
  Future<bool> initializeFromStorage() async {
    try {
      final hasStoredAuth = await _secureStorage.hasAuthData();
      if (hasStoredAuth && _auth.currentUser == null) {
        // Try to refresh the token
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken != null) {
          // We can't directly use refresh tokens with Firebase client SDK
          // but we can check for persisted auth state
          return _auth.currentUser != null;
        }
      }
      return _auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  // Sign in with email and password
  @override
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("DEBUG -> user Credential = $userCredential");
      print("DEBUG -> user = ${userCredential.user}");
      if (userCredential.user == null) {
        throw Exception('User is null after sign-in');
      }
      // Store user information securely
      final user = userCredential.user;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          await _secureStorage.storeAuthToken(token);
        }
        await _secureStorage.storeUserId(user.uid);
        if (user.email != null) {
          await _secureStorage.storeUserEmail(user.email!);
        }
        await _secureStorage.storeLastLoginTime();
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Create new user with email and password
  @override
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user information securely
      final user = userCredential.user;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          await _secureStorage.storeAuthToken(token);
        }
        await _secureStorage.storeUserId(user.uid);
        if (user.email != null) {
          await _secureStorage.storeUserEmail(user.email!);
        }
        await _secureStorage.storeLastLoginTime();
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  @override
  Future<void> updateUserProfile(
      {String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Send password reset email
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  @override
  Future<void> signOut() async {
    try {
      // Clear tokens from secure storage
      await _secureStorage.clearAuthData();

      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get user token
  @override
  Future<String> getIdToken() async {
    try {
      // First try to get from secure storage
      final storedToken = await _secureStorage.getAuthToken();
      if (storedToken != null && storedToken.isNotEmpty) {
        return storedToken;
      }

      // If not in storage, get from Firebase
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated');
      }

      // Firebase's getIdToken() returns a String? which needs to be checked for null.
      final String? token = await user.getIdToken();
      if (token == null) {
        throw Exception('Failed to retrieve token');
      }

      // Store the token for future use
      await _secureStorage.storeAuthToken(token);
      return token;
    } catch (e) {
      rethrow;
    }
  }

  // Refresh user token
  @override
  Future<String> refreshToken() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated');
      }

      // Firebase's getIdToken(true) returns a String? which needs to be checked for null.
      final String? token = await user.getIdToken(true);
      if (token == null) {
        throw Exception('Failed to refresh token');
      }

      // Update the token in secure storage
      await _secureStorage.storeAuthToken(token);
      return token;
    } catch (e) {
      rethrow;
    }
  }

  // Check if user has required permissions
  @override
  Future<bool> hasPermission(String permission) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // This would typically involve checking custom claims or Firestore.
      // For now, we'll return true for demonstration purposes.
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user session information
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
}
