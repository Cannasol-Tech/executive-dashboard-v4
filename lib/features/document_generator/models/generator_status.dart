import 'package:cloud_firestore/cloud_firestore.dart';
import 'document_request.dart';

/// Represents the real-time status of a document generation process
class GeneratorStatus {
  final String id; // Unique ID of the status entry
  final String requestId; // ID of the associated document request
  final DocumentRequestStatus status; // Status of the generation process
  final int progressPercentage; // Progress percentage (0-100)
  final String currentStep; // Current step in the generation process
  final int? remainingTimeInSeconds; // Remaining time in seconds
  final int? estimatedCompletionTime; // Estimated completion time in seconds
  final DateTime updatedAt; // Last updated time
  final String message; // Optional message for the status
  final Map<String, dynamic> metadata; // Additional metadata for the status

  GeneratorStatus({
    required this.id,
    required this.requestId,
    required this.status,
    required this.progressPercentage,
    required this.currentStep,
    required this.updatedAt,
    this.remainingTimeInSeconds = null,
    this.estimatedCompletionTime = null,
    this.message = '',
    this.metadata = const {},
  });

  /// Creates a GeneratorStatus from a Firestore DocumentSnapshot
  factory GeneratorStatus.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

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

    return GeneratorStatus(
      id: doc.id,
      requestId: data['requestId'] ?? '',
      status: status,
      progressPercentage: data['progressPercentage'] ?? 0,
      currentStep: data['currentStep'] ?? 'Initializing...',
      remainingTimeInSeconds: data['remainingTimeInSeconds'] ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      message: data['message'],
    );
  }

  /// Converts GeneratorStatus to a map for Firestore
  Map<String, dynamic> toMap() {
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
      'requestId': requestId,
      'status': statusString,
      'progressPercentage': progressPercentage,
      'currentStep': currentStep,
      'remainingTimeInSeconds': remainingTimeInSeconds,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };

    if (message != '') {
      map['message'] = message;
    }

    return map;
  }

  /// Create a copy with some fields updated
  GeneratorStatus copyWith({
    DocumentRequestStatus? status,
    int? progressPercentage,
    String? currentStep,
    int? remainingTimeInSeconds,
    DateTime? updatedAt,
    String? message,
  }) {
    return GeneratorStatus(
      id: this.id,
      requestId: this.requestId,
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      currentStep: currentStep ?? this.currentStep,
      remainingTimeInSeconds:
          remainingTimeInSeconds ?? this.remainingTimeInSeconds,
      updatedAt: updatedAt ?? this.updatedAt,
      message: message ?? this.message,
    );
  }

  /// Returns a human-readable string representing remaining time
  String get remainingTimeString {
    if (remainingTimeInSeconds == null || remainingTimeInSeconds! <= 0) {
      return 'Less than a minute';
    }

    if (remainingTimeInSeconds! < 60) {
      return '$remainingTimeInSeconds seconds';
    }

    final minutes = remainingTimeInSeconds! ~/ 60;
    final seconds = remainingTimeInSeconds! % 60;

    if (minutes < 60) {
      return seconds > 0 ? '$minutes min $seconds sec' : '$minutes min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    return remainingMinutes > 0
        ? '$hours hr $remainingMinutes min'
        : '$hours hr';
  }
}
