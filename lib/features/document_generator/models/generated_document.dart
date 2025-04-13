import 'package:cloud_firestore/cloud_firestore.dart';
import 'document_request.dart';

/// Represents a generated document stored in Firestore
class GeneratedDocument {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String templateId;
  final String templateName;
  final String storageUrl;
  final String fileFormat;
  final int sizeInBytes;
  final String? thumbnailUrl;
  final DocumentPrivacy privacy;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
  final bool isArchived;
  final DateTime? archivedAt;

  GeneratedDocument({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.templateId,
    required this.templateName,
    required this.storageUrl,
    required this.fileFormat,
    required this.sizeInBytes,
    this.thumbnailUrl,
    required this.privacy,
    required this.createdAt,
    this.metadata = const {},
    this.isArchived = false,
    this.archivedAt,
  });

  /// Creates a GeneratedDocument from a Firestore DocumentSnapshot
  factory GeneratedDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse privacy from string
    DocumentPrivacy privacy;
    switch (data['privacy']) {
      case 'shared':
        privacy = DocumentPrivacy.shared;
        break;
      case 'oneTime':
        privacy = DocumentPrivacy.oneTime;
        break;
      case 'private':
      default:
        privacy = DocumentPrivacy.private;
        break;
    }

    return GeneratedDocument(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      title: data['title'] ?? '',
      templateId: data['templateId'] ?? '',
      templateName: data['templateName'] ?? '',
      storageUrl: data['storageUrl'] ?? '',
      fileFormat: data['fileFormat'] ?? '',
      sizeInBytes: data['sizeInBytes'] ?? 0,
      thumbnailUrl: data['thumbnailUrl'],
      privacy: privacy,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      metadata: data['metadata'] ?? {},
      isArchived: data['isArchived'] ?? false,
      archivedAt: data['archivedAt'] != null
          ? (data['archivedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Converts GeneratedDocument to a map for Firestore
  Map<String, dynamic> toMap() {
    // Convert enum to string
    String privacyString;
    switch (privacy) {
      case DocumentPrivacy.shared:
        privacyString = 'shared';
        break;
      case DocumentPrivacy.oneTime:
        privacyString = 'oneTime';
        break;
      case DocumentPrivacy.private:
      default:
        privacyString = 'private';
        break;
    }

    final map = <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'title': title,
      'templateId': templateId,
      'templateName': templateName,
      'storageUrl': storageUrl,
      'fileFormat': fileFormat,
      'sizeInBytes': sizeInBytes,
      'privacy': privacyString,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
      'isArchived': isArchived,
    };

    if (thumbnailUrl != null) {
      map['thumbnailUrl'] = thumbnailUrl;
    }

    if (archivedAt != null) {
      map['archivedAt'] = Timestamp.fromDate(archivedAt!);
    }

    return map;
  }

  /// Create a copy with some fields updated
  GeneratedDocument copyWith({
    String? title,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
    bool? isArchived,
    DateTime? archivedAt,
  }) {
    return GeneratedDocument(
      id: this.id,
      userId: this.userId,
      userName: this.userName,
      title: title ?? this.title,
      templateId: this.templateId,
      templateName: this.templateName,
      storageUrl: this.storageUrl,
      fileFormat: this.fileFormat,
      sizeInBytes: this.sizeInBytes,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      privacy: this.privacy,
      createdAt: this.createdAt,
      metadata: metadata ?? this.metadata,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }
}
