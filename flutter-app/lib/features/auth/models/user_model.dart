import 'package:cloud_firestore/cloud_firestore.dart';

/// User Model for Cannasol Executive Dashboard
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? role;
  final List<String> permissions;
  final DateTime? lastLogin;
  final Map<String, dynamic>? preferences;

  /// Creates a new UserModel instance
  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.role = 'user',
    this.permissions = const [],
    this.lastLogin,
    this.preferences,
  });

  /// Creates a new UserModel with default values
  factory UserModel.empty() {
    return UserModel(
      uid: '',
      email: '',
      displayName: 'User',
      photoUrl: null,
      role: 'user',
      permissions: [],
      lastLogin: DateTime.now(),
      preferences: {},
    );
  }

  /// Creates a UserModel from a Firebase User
  factory UserModel.fromFirebaseUser(dynamic user,
      {Map<String, dynamic>? additionalData}) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'User',
      photoUrl: user.photoURL,
      role: additionalData?['role'] ?? 'user',
      permissions: List<String>.from(additionalData?['permissions'] ?? []),
      lastLogin: additionalData?['lastLogin'] != null
          ? (additionalData!['lastLogin'] as Timestamp).toDate()
          : DateTime.now(),
      preferences: additionalData?['preferences'],
    );
  }

  factory UserModel.streamFirebaseUser(dynamic user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'User',
      photoUrl: user.photoURL,
      role: 'user',
      permissions: [],
      lastLogin: DateTime.now(),
      preferences: {},
    );
  }

  /// Creates a UserModel from a Firestore document
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'User',
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'user',
      permissions: List<String>.from(data['permissions'] ?? []),
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
      preferences: data['preferences'],
    );
  }

  /// Converts UserModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'permissions': permissions,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'preferences': preferences,
    };
  }

  /// Copies UserModel with new values
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? role,
    List<String>? permissions,
    DateTime? lastLogin,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
    );
  }
}
