import 'package:cloud_firestore/cloud_firestore.dart';

/// Privacy level for a document
enum DocumentPrivacy {
  private,
  shared,
  oneTime,
}

/// Status of a document generation request
enum DocumentRequestStatus {
  pending,
  processing,
  completed,
  failed,
}

/// Represents a document generation request in Firestore
class DocumentRequest {
  final String id;
  final String userId;
  final String userName;
  final String templateId;
  final String templateName;
  final Map<String, dynamic> formData;
  final DocumentPrivacy privacy;
  final DocumentRequestStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final String? generatedDocumentId;

  DocumentRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.templateId,
    required this.templateName,
    required this.formData,
    required this.privacy,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
    this.generatedDocumentId,
  });

  /// Creates a DocumentRequest from a Firestore DocumentSnapshot
  factory DocumentRequest.fromFirestore(DocumentSnapshot doc) {
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

    // Parse status from string
    DocumentRequestStatus status;
    switch (data['status']) {
      case 'processing':
        status = DocumentRequestStatus.processing;
        break;
      case 'completed':
        status = DocumentRequestStatus.completed;
        break;
      case 'failed':
        status = DocumentRequestStatus.failed;
        break;
      case 'pending':
      default:
        status = DocumentRequestStatus.pending;
        break;
    }

    return DocumentRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      templateId: data['templateId'] ?? '',
      templateName: data['templateName'] ?? '',
      formData: data['formData'] ?? {},
      privacy: privacy,
      status: status,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      errorMessage: data['errorMessage'],
      generatedDocumentId: data['generatedDocumentId'],
    );
  }

  /// Converts DocumentRequest to a map for Firestore
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

    // Convert enum to string
    String statusString;
    switch (status) {
      case DocumentRequestStatus.processing:
        statusString = 'processing';
        break;
      case DocumentRequestStatus.completed:
        statusString = 'completed';
        break;
      case DocumentRequestStatus.failed:
        statusString = 'failed';
        break;
      case DocumentRequestStatus.pending:
      default:
        statusString = 'pending';
        break;
    }

    final map = <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'templateId': templateId,
      'templateName': templateName,
      'formData': formData,
      'privacy': privacyString,
      'status': statusString,
      'createdAt': Timestamp.fromDate(createdAt),
    };

    if (completedAt != null) {
      map['completedAt'] = Timestamp.fromDate(completedAt!);
    }

    if (errorMessage != null) {
      map['errorMessage'] = errorMessage;
    }

    if (generatedDocumentId != null) {
      map['generatedDocumentId'] = generatedDocumentId;
    }

    return map;
  }

  /// Create a copy with some fields updated
  DocumentRequest copyWith({
    DocumentRequestStatus? status,
    DateTime? completedAt,
    String? errorMessage,
    String? generatedDocumentId,
  }) {
    return DocumentRequest(
      id: this.id,
      userId: this.userId,
      userName: this.userName,
      templateId: this.templateId,
      templateName: this.templateName,
      formData: this.formData,
      privacy: this.privacy,
      status: status ?? this.status,
      createdAt: this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      generatedDocumentId: generatedDocumentId ?? this.generatedDocumentId,
    );
  }
}
