import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/// Interface for authentication services
abstract class AuthServiceInterface {
  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;

  /// Get current user
  User? get currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Initialize authentication from secure storage
  Future<bool> initializeFromStorage();

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password);

  /// Create new user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password);

  /// Update user profile
  Future<void> updateUserProfile({String? displayName, String? photoURL});

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Sign out
  Future<void> signOut();

  /// Get user token
  Future<String> getIdToken();

  /// Refresh user token
  Future<String> refreshToken();

  /// Check if user has required permissions
  Future<bool> hasPermission(String permission);

  /// Get user session information
  Future<Map<String, dynamic>> getUserSessionInfo();
}
