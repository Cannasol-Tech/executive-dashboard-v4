import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/email.dart';
import '../../../models/email_task.dart';
import '../../../services/firebase_service.dart';

/// Service for interacting with email data in Firebase
class EmailService {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _emailCollection => _firebaseService.emailCollection;
  CollectionReference get _taskCollection => _firestore.collection('tasks');

  /// Get all emails for the current user with filters and sorting
  Stream<List<Email>> getEmails({
    bool includeArchived = false,
    bool includeSpam = false,
    String? filterByStatus,
    int? filterByPriority,
    String? searchQuery,
  }) {
    Query query = _emailCollection;

    // Apply basic filters
    if (!includeArchived) {
      query = query.where('archived', isEqualTo: false);
    }

    if (!includeSpam) {
      query = query.where('isSpam', isEqualTo: false);
    }

    // Apply additional filters
    if (filterByStatus != null) {
      query = query.where('status', isEqualTo: filterByStatus);
    }

    if (filterByPriority != null) {
      query = query.where('priority', isEqualTo: filterByPriority);
    }

    // By default, sort by received date (newest first)
    query = query.orderBy('receivedAt', descending: true);

    // Convert the query to a stream of Email objects
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Email.fromFirestore(doc))
          .where((email) {
        // Apply text search if provided
        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final search = searchQuery.toLowerCase().trim();
          return email.subject.toLowerCase().contains(search) ||
              email.senderName.toLowerCase().contains(search) ||
              email.senderEmail.toLowerCase().contains(search) ||
              email.body.toLowerCase().contains(search);
        }
        return true;
      }).toList();
    });
  }

  /// Get a single email by ID
  Future<Email?> getEmailById(String emailId) async {
    final doc = await _emailCollection.doc(emailId).get();
    if (doc.exists) {
      return Email.fromFirestore(doc);
    }
    return null;
  }

  /// Get a stream of a single email by ID (for real-time updates)
  Stream<Email?> streamEmailById(String emailId) {
    return _emailCollection.doc(emailId).snapshots().map((doc) {
      if (doc.exists) {
        return Email.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Mark an email as read
  Future<void> markAsRead(String emailId) {
    return _emailCollection.doc(emailId).update({
      'isRead': true,
    });
  }

  /// Mark an email as unread
  Future<void> markAsUnread(String emailId) {
    return _emailCollection.doc(emailId).update({
      'isRead': false,
    });
  }

  /// Mark multiple emails as read or unread
  Future<void> markMultipleReadStatus(
      List<String> emailIds, bool isRead) async {
    final batch = _firestore.batch();

    for (final emailId in emailIds) {
      final docRef = _emailCollection.doc(emailId);
      batch.update(docRef, {'isRead': isRead});
    }

    return batch.commit();
  }

  /// Archive an email
  Future<void> archiveEmail(String emailId) {
    return _emailCollection.doc(emailId).update({
      'archived': true,
    });
  }

  /// Archive multiple emails
  Future<void> archiveMultipleEmails(List<String> emailIds) async {
    final batch = _firestore.batch();

    for (final emailId in emailIds) {
      final docRef = _emailCollection.doc(emailId);
      batch.update(docRef, {'archived': true});
    }

    return batch.commit();
  }

  /// Mark an email as spam
  Future<void> markAsSpam(String emailId) {
    return _emailCollection.doc(emailId).update({
      'isSpam': true,
    });
  }

  /// Update the AI response for an email
  Future<void> updateAiResponse(String emailId, String response) {
    return _emailCollection.doc(emailId).update({
      'aiResponse': response,
      'status': EmailStatus.responded.toString().split('.').last,
    });
  }

  /// Approve the AI response for an email
  Future<void> approveAiResponse(String emailId) {
    return _emailCollection.doc(emailId).update({
      'status': EmailStatus.approved.toString().split('.').last,
    });
  }

  /// Reject the AI response for an email
  Future<void> rejectAiResponse(String emailId) {
    return _emailCollection.doc(emailId).update({
      'status': EmailStatus.rejected.toString().split('.').last,
    });
  }

  /// Get tasks associated with an email
  Stream<List<EmailTask>> getTasksForEmail(String emailId) {
    return _taskCollection
        .where('sourceEmailId', isEqualTo: emailId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => EmailTask.fromFirestore(doc)).toList();
    });
  }

  /// Create a new task for an email
  Future<void> createTask(EmailTask task) {
    return _taskCollection.add(task.toFirestore());
  }

  /// Update a task
  Future<void> updateTask(EmailTask task) {
    return _taskCollection.doc(task.id).update(task.toFirestore());
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) {
    return _taskCollection.doc(taskId).delete();
  }

  /// Sample data generator for development and testing
  Future<void> generateSampleData(int count) async {
    final batch = _firestore.batch();

    final now = DateTime.now();
    final statuses = [
      EmailStatus.pending.toString().split('.').last,
      EmailStatus.responded.toString().split('.').last,
      EmailStatus.approved.toString().split('.').last,
      EmailStatus.rejected.toString().split('.').last
    ];

    for (int i = 0; i < count; i++) {
      final docRef = _emailCollection.doc();

      final sampleEmail = {
        'subject': 'Sample Email Subject ${i + 1}',
        'senderEmail': 'sender${i + 1}@example.com',
        'senderName': 'Sender Name ${i + 1}',
        'recipients': ['recipient@cannasol.com'],
        'body':
            'This is the body of sample email ${i + 1}. It contains some content that the AI agent can analyze and respond to.',
        'receivedAt': Timestamp.fromDate(now.subtract(Duration(hours: i * 3))),
        'status': statuses[i % 4],
        'aiResponse': i % 4 == 0
            ? null
            : 'This is a sample AI-generated response for email ${i + 1}.',
        'priority': (i % 3) + 1, // 1, 2, or 3
        'isRead': i % 2 == 0,
        'hasAttachments': i % 5 == 0,
        'attachmentUrls': i % 5 == 0
            ? [
                'https://example.com/attachment1.pdf',
                'https://example.com/attachment2.jpg'
              ]
            : null,
        'tags': i % 3 == 0
            ? ['important', 'follow-up']
            : (i % 3 == 1 ? ['newsletter'] : null),
        'needsResponse': i % 4 != 3, // Only 3/4 emails need response
        'isSpam': i % 15 == 0, // 1/15 emails are spam
        'archived': i % 10 == 0, // 1/10 emails are archived
      };

      batch.set(docRef, sampleEmail);

      // Add 1-3 tasks for some emails
      if (i % 3 == 0) {
        final taskCount = (i % 3) + 1; // 1, 2, or 3 tasks

        for (int t = 0; t < taskCount; t++) {
          final taskDocRef = _taskCollection.doc();
          final task = {
            'title': 'Task ${t + 1} for Email ${i + 1}',
            'description':
                'This is a sample task extracted from email content.',
            'sourceEmailId': docRef.id,
            'createdDate': Timestamp.fromDate(now),
            'dueDate': Timestamp.fromDate(now.add(Duration(days: t + 1))),
            'status': t % 2 == 0 ? 'todo' : 'inProgress',
            'assignedTo': null,
          };

          batch.set(taskDocRef, task);
        }
      }
    }

    return batch.commit();
  }
}
