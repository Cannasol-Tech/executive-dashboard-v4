import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../../core/services/firebase_service.dart';
import '../services/auth_service.dart';


/// Provider for handling authentication state
class AuthProvider with ChangeNotifier {
  final Object _authService;
  final FirebaseService _firebaseService;

  String? _errorMessage;
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool get isLoading => _isLoading;
  String? get userId => _currentUser?.uid;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _currentUser?.email;

  /// Expose the auth state changes stream
  Stream<UserModel?> get authStateChanges {
    if (_authService is AuthService) {
      return (_authService as AuthService).authStateChanges;
    }
    // For tests
    return (_authService as dynamic).authStateChanges;
  }

  /// Initialize the auth provider and listen for auth changes
  AuthProvider()
      : _authService = AuthService(),
        _firebaseService = FirebaseService() {
    _initializeAuth();
  }

  /// Constructor for testing with mocked dependencies
  @visibleForTesting
  AuthProvider.withServices(this._authService, this._firebaseService) {
    _initializeAuth();
  }

  /// Constructor for testing with just a mock AuthService
  @visibleForTesting
  AuthProvider.withAuthService(Object authService)
      : _authService = authService,
        _firebaseService = FirebaseService() {
    _initializeAuth();
  }

  /// Initialize authentication state from secure storage if available
  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Attempt to restore session from secure storage
      final hasSession =
          await (_authService as dynamic).initializeFromStorage();

      // If we have a stored session, and Firebase auth already has the user
      // (Firebase has its own persistence), we'll receive user data via the auth state changes
      if (hasSession) {
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }

      // Set up listener for auth state changes
      authStateChanges.listen((user) {
        if (user != null) {
          _isAuthenticated = true;
          _loadUserData(user);
        } else {
          _isAuthenticated = false;
          _currentUser = null;
          notifyListeners();
        }
      });
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load additional user data from Firestore
  Future<void> _loadUserData(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final doc = await _firebaseService.getDocument(
          _firebaseService.userCollection, user.uid);

      if (doc.exists) {
        _currentUser = UserModel.fromDocument(doc);
      } else {
        // Create new user document if it doesn't exist
        final newUser = UserModel.fromFirebaseUser(user);
        await _firebaseService.userCollection
            .doc(user.uid)
            .set(newUser.toJson());
        _currentUser = newUser;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = UserModel.fromFirebaseUser(user);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if session is active
  Future<bool> checkSession() async {
    try {
      final sessionInfo = await (_authService as dynamic).getUserSessionInfo();
      return sessionInfo['isAuthenticated'] == true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  /// Sign in with email and password
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Log the beginning of email login attempt (without showing the password)
      print('Starting email login for: $email');

      await (_authService as dynamic)
          .signInWithEmailAndPassword(email, password);
      _isAuthenticated = true;

      // Log successful authentication
      print('Email login successful for: $email');

      // User data will be loaded by the auth state listener
    } catch (e) {
      print('Email login error: $e');
      _errorMessage = _getReadableAuthError(e);
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      rethrow; // Rethrow to handle navigation in the UI layer
    }
  }

  /// Create new user with email and password
  Future<void> createUserWithEmailAndPassword(
      String email, String password, String displayName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await (_authService as dynamic)
          .createUserWithEmailAndPassword(email, password);

      // Update the user's display name
      await (_authService as dynamic)
          .updateUserProfile(displayName: displayName);

      _isAuthenticated = true;
      // User data will be loaded by the auth state listener
    } catch (e) {
      _errorMessage = _getReadableAuthError(e);
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await (_authService as dynamic).sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = _getReadableAuthError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await (_authService as dynamic).signOut();
      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mock logout functionality
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _isAuthenticated = false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Update user preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Merge the existing preferences with the new ones
      final updatedPreferences = {
        ..._currentUser!.preferences ?? {},
        ...preferences,
      };

      await _firebaseService.updateDocument(_firebaseService.userCollection,
          _currentUser!.uid, {'preferences': updatedPreferences});

      _currentUser = _currentUser!.copyWith(preferences: updatedPreferences);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if the current user has a specific permission
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;

    // Admin role has all permissions
    if (_currentUser!.role == 'admin') return true;

    return _currentUser!.permissions.contains(permission);
  }

  /// Get ID token for API requests
  Future<String?> getIdToken() async {
    try {
      return await (_authService as dynamic).getIdToken();
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  /// Refresh authentication token
  Future<String?> refreshAuthToken() async {
    try {
      return await (_authService as dynamic).refreshToken();
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  /// Convert Firebase auth exceptions to readable error messages
  String _getReadableAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'The password is too weak. Please use a stronger password.';
        case 'operation-not-allowed':
          return 'This sign-in method is not allowed. Please contact support.';
        case 'user-disabled':
          return 'This user account has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many unsuccessful login attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return error.message ?? 'An unknown error occurred.';
      }
    }
    return error.toString();
  }
}
