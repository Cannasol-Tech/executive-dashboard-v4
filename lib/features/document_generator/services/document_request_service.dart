import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document_request.dart';

/// Service for managing document generation requests in Firestore.
class DocumentRequestService {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'document-requests';

  DocumentRequestService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get a stream of document requests for a specific user
  Stream<List<DocumentRequest>> getUserDocumentRequests(String userId) {
    return _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DocumentRequest.fromFirestore(doc))
          .toList();
    });
  }

  /// Get a stream of recent document requests for a specific user
  Stream<List<DocumentRequest>> getRecentUserDocumentRequests(String userId,
      {int limit = 5}) {
    return _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DocumentRequest.fromFirestore(doc))
          .toList();
    });
  }

  /// Get a stream of document requests for all users (admin only)
  Stream<List<DocumentRequest>> getAllDocumentRequests() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DocumentRequest.fromFirestore(doc))
          .toList();
    });
  }

  /// Get a specific document request by ID
  Future<DocumentRequest?> getDocumentRequestById(String requestId) async {
    final docSnapshot =
        await _firestore.collection(_collectionPath).doc(requestId).get();

    if (docSnapshot.exists) {
      return DocumentRequest.fromFirestore(docSnapshot);
    }

    return null;
  }

  /// Create a new document generation request
  Future<String> createDocumentRequest({
    required String userId,
    required String userName,
    required String templateId,
    required String templateName,
    required Map<String, dynamic> formData,
    required DocumentPrivacy privacy,
  }) async {
    final requestRef = _firestore.collection(_collectionPath).doc();
    final requestId = requestRef.id;

    final request = DocumentRequest(
      id: requestId,
      userId: userId,
      userName: userName,
      templateId: templateId,
      templateName: templateName,
      formData: formData,
      privacy: privacy,
      status: DocumentRequestStatus.pending,
      createdAt: DateTime.now(),
    );

    await requestRef.set(request.toMap());

    return requestId;
  }

  /// Update the status of a document request
  Future<void> updateRequestStatus({
    required String requestId,
    required DocumentRequestStatus status,
    String? errorMessage,
    String? generatedDocumentId,
    DateTime? completedAt,
  }) async {
    final updates = <String, dynamic>{
      'status': status.toString().split('.').last,
    };

    if (errorMessage != null) {
      updates['errorMessage'] = errorMessage;
    }

    if (generatedDocumentId != null) {
      updates['generatedDocumentId'] = generatedDocumentId;
    }

    if (completedAt != null || status == DocumentRequestStatus.completed) {
      updates['completedAt'] = completedAt ?? Timestamp.now();
    }

    await _firestore.collection(_collectionPath).doc(requestId).update(updates);
  }

  /// Delete a document request
  Future<void> deleteDocumentRequest(String requestId) async {
    await _firestore.collection(_collectionPath).doc(requestId).delete();
  }

  /// Get count of requests by status for a specific user
  Future<Map<DocumentRequestStatus, int>> getUserRequestCountsByStatus(
      String userId) async {
    final querySnapshot = await _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .get();

    final counts = <DocumentRequestStatus, int>{
      DocumentRequestStatus.pending: 0,
      DocumentRequestStatus.processing: 0,
      DocumentRequestStatus.completed: 0,
      DocumentRequestStatus.failed: 0,
    };

    for (final doc in querySnapshot.docs) {
      final request = DocumentRequest.fromFirestore(doc);
      counts[request.status] = (counts[request.status] ?? 0) + 1;
    }

    return counts;
  }
}
