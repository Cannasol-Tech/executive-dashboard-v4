import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document_request.dart';
import '../models/generator_status.dart';

/// Service for tracking document generation status in Firestore.
class GeneratorStatusService {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'generator-status';

  GeneratorStatusService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get a stream of status updates for a specific document request
  Stream<GeneratorStatus?> getStatusStream(String requestId) {
    return _firestore
        .collection(_collectionPath)
        .where('requestId', isEqualTo: requestId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return GeneratorStatus.fromFirestore(snapshot.docs.first);
    });
  }

  /// Get the latest status for a specific document request
  Future<GeneratorStatus?> getLatestStatus(String requestId) async {
    final querySnapshot = await _firestore
        .collection(_collectionPath)
        .where('requestId', isEqualTo: requestId)
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return GeneratorStatus.fromFirestore(querySnapshot.docs.first);
  }

  /// Create a new status entry for a document request
  Future<void> createStatus({
    required String requestId,
    required DocumentRequestStatus status,
    required int progressPercentage,
    required String currentStep,
    DateTime? estimatedCompletionTime,
    String message = '',
    Map<String, dynamic>? metadata,
    int? remainingTimeInSeconds,
  }) async {
    final statusRef = _firestore.collection(_collectionPath).doc();

    final statusUpdate = GeneratorStatus(
      id: statusRef.id,
      requestId: requestId,
      status: status,
      progressPercentage: progressPercentage,
      currentStep: currentStep,
      updatedAt: DateTime.now(),
      estimatedCompletionTime: (estimatedCompletionTime ??
              DateTime.now().add(const Duration(minutes: 5)))
          .toUtc()
          .millisecondsSinceEpoch,
      message: message,
      metadata: metadata ?? {},
      remainingTimeInSeconds: remainingTimeInSeconds,
    );

    await statusRef.set(statusUpdate.toMap());
  }

  /// Update the status for a document request
  Future<void> updateStatus({
    required String requestId,
    required DocumentRequestStatus status,
    required int progressPercentage,
    required String currentStep,
    DateTime? estimatedCompletionTime,
    String? message,
    Map<String, dynamic>? metadata,
  }) async {
    // Get the latest status document
    final querySnapshot = await _firestore
        .collection(_collectionPath)
        .where('requestId', isEqualTo: requestId)
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Create a new status if none exists
      await createStatus(
        requestId: requestId,
        status: status,
        progressPercentage: progressPercentage,
        currentStep: currentStep,
        estimatedCompletionTime: estimatedCompletionTime,
        message: message ?? '',
        metadata: metadata,
      );
      return;
    }

    // Update the existing status
    final statusRef = querySnapshot.docs.first.reference;

    final updates = <String, dynamic>{
      'status': status.toString().split('.').last,
      'progressPercentage': progressPercentage,
      'currentStep': currentStep,
      'updatedAt': Timestamp.now(),
    };

    if (estimatedCompletionTime != null) {
      updates['estimatedCompletionTime'] =
          Timestamp.fromDate(estimatedCompletionTime);
    }

    if (message != null) {
      updates['message'] = message;
    }

    if (metadata != null) {
      updates['metadata'] = metadata;
    }

    await statusRef.update(updates);
  }

  /// Delete status entries for a document request
  Future<void> deleteStatusEntries(String requestId) async {
    final querySnapshot = await _firestore
        .collection(_collectionPath)
        .where('requestId', isEqualTo: requestId)
        .get();

    final batch = _firestore.batch();

    for (final doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
