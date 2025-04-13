import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/email.dart';
import '../models/email_task.dart';
import 'dart:math';

/// Service class for handling email operations with Firebase
class EmailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _emailsCollection => _firestore.collection('emails');
  CollectionReference get _tasksCollection =>
      _firestore.collection('email_tasks');

  /// Fetch emails with optional filtering
  Future<List<Email>> getEmails({
    String? statusFilter,
    int? priorityFilter,
    bool includeArchived = false,
    bool includeSpam = false,
    String? searchQuery,
  }) async {
    try {
      Query query = _emailsCollection;

      // Apply filters
      if (!includeArchived) {
        query = query.where('archived', isEqualTo: false);
      }

      if (!includeSpam) {
        query = query.where('isSpam', isEqualTo: false);
      }

      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter);
      }

      if (priorityFilter != null) {
        query = query.where('priority', isEqualTo: priorityFilter);
      }

      // Sort by received date (newest first)
      query = query.orderBy('receivedAt', descending: true);

      final snapshot = await query.get();
      final emails =
          snapshot.docs.map((doc) => Email.fromFirestore(doc)).toList();

      // If search query is provided, filter the results client-side
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return emails
            .where((email) =>
                email.subject.toLowerCase().contains(searchLower) ||
                email.senderName.toLowerCase().contains(searchLower) ||
                email.senderEmail.toLowerCase().contains(searchLower) ||
                email.body.toLowerCase().contains(searchLower))
            .toList();
      }

      return emails;
    } catch (e) {
      throw Exception('Failed to fetch emails: $e');
    }
  }

  /// Get a single email by ID
  Future<Email?> getEmailById(String emailId) async {
    try {
      final doc = await _emailsCollection.doc(emailId).get();
      if (doc.exists) {
        return Email.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch email: $e');
    }
  }

  /// Update an email in Firestore
  Future<void> updateEmail(Email email) async {
    try {
      await _emailsCollection.doc(email.id).update(email.toFirestore());
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  /// Mark an email as read/unread
  Future<void> markEmailReadStatus(String emailId, bool isRead) async {
    try {
      await _emailsCollection.doc(emailId).update({'isRead': isRead});
    } catch (e) {
      throw Exception('Failed to update email read status: $e');
    }
  }

  /// Mark an email as archived
  Future<void> archiveEmail(String emailId) async {
    try {
      await _emailsCollection.doc(emailId).update({'archived': true});
    } catch (e) {
      throw Exception('Failed to archive email: $e');
    }
  }

  /// Mark an email as spam
  Future<void> markAsSpam(String emailId) async {
    try {
      await _emailsCollection.doc(emailId).update({'isSpam': true});
    } catch (e) {
      throw Exception('Failed to mark email as spam: $e');
    }
  }

  /// Update the AI response for an email
  Future<void> updateAiResponse(String emailId, String response) async {
    try {
      await _emailsCollection.doc(emailId).update({
        'aiResponse': response,
        'status': EmailStatus.responded.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to update AI response: $e');
    }
  }

  /// Approve the AI response for an email
  Future<void> approveAiResponse(String emailId) async {
    try {
      await _emailsCollection.doc(emailId).update({
        'status': EmailStatus.approved.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to approve AI response: $e');
    }
  }

  /// Reject the AI response for an email
  Future<void> rejectAiResponse(String emailId) async {
    try {
      await _emailsCollection.doc(emailId).update({
        'status': EmailStatus.rejected.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to reject AI response: $e');
    }
  }

  /// Get tasks associated with an email
  Future<List<EmailTask>> getTasksForEmail(String emailId) async {
    try {
      final snapshot = await _tasksCollection
          .where('sourceEmailId', isEqualTo: emailId)
          .orderBy('createdDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => EmailTask.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  /// Add a new task
  Future<EmailTask> addTask(EmailTask task) async {
    try {
      final docRef = await _tasksCollection.add(task.toFirestore());
      // Return the task with the new ID
      return EmailTask(
        id: docRef.id,
        title: task.title,
        description: task.description,
        sourceEmailId: task.sourceEmailId,
        createdDate: task.createdDate,
        dueDate: task.dueDate,
        status: task.status,
        assignedTo: task.assignedTo,
      );
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  /// Update a task
  Future<void> updateTask(EmailTask task) async {
    try {
      await _tasksCollection.doc(task.id).update(task.toFirestore());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  /// Generate sample data for testing
  Future<List<Email>> generateSampleEmails(int count) async {
    final List<Email> generatedEmails = [];
    final random = Random();

    // Sample data for randomization
    final senders = [
      {'name': 'John Smith', 'email': 'john.smith@example.com'},
      {'name': 'Jane Doe', 'email': 'jane.doe@example.com'},
      {'name': 'Alex Johnson', 'email': 'alex@techinnovators.com'},
      {'name': 'Sarah Williams', 'email': 'sarah@growthpartners.com'},
      {'name': 'Michael Brown', 'email': 'michael@cannabisindustry.org'},
    ];

    final subjects = [
      'Partnership Opportunity for Cannasol',
      'Following up on our recent discussion',
      'New product line proposal',
      'Quarterly business review - Action required',
      'Industry conference invitation',
      'Contract renewal discussion',
      'Schedule a demo of our platform',
      'Important regulatory update',
      'Feedback on recent product samples',
      'Investor relations inquiry',
    ];

    final bodies = [
      'I hope this email finds you well. I wanted to reach out regarding a potential partnership opportunity between our companies...',
      'Thank you for taking the time to meet with us last week. As discussed, I am sending over the information about our services...',
      'Based on our market research, we believe there is a significant opportunity to expand your product line into the following areas...',
      'It\'s time for our quarterly business review. We need to discuss the following items: 1. Sales performance, 2. Market trends, 3. Product development...',
      'We would like to invite you to speak at our upcoming industry conference on sustainable practices in the cannabis industry...',
      'Your current contract with us is set to expire in 30 days. We would like to discuss renewal terms and potential upgrades to your service package...',
      'Our team has developed a new analytics platform specifically designed for companies in your industry. We\'d like to offer you an exclusive demo...',
      'There has been a significant regulatory change that affects operations in the following states where your company operates...',
      'We received the product samples you sent last month. Our team has completed the testing and would like to share our feedback...',
      'As an investor relations representative for XYZ Fund, I\'m reaching out to discuss potential investment opportunities in Cannasol Technologies...',
    ];

    // Generate emails
    for (int i = 0; i < count; i++) {
      final senderIndex = random.nextInt(senders.length);
      final subjectIndex = random.nextInt(subjects.length);
      final bodyIndex = random.nextInt(bodies.length);

      final emailStatus = random.nextDouble() < 0.6
          ? EmailStatus.pending
          : random.nextDouble() < 0.7
              ? EmailStatus.responded
              : random.nextDouble() < 0.5
                  ? EmailStatus.approved
                  : EmailStatus.rejected;

      final priority = random.nextDouble() < 0.2
          ? 1
          : random.nextDouble() < 0.6
              ? 2
              : 3;
      final isRead = random.nextBool();
      final hasAttachments = random.nextDouble() < 0.3;

      // Create a random received date within the last 14 days
      final receivedDate = DateTime.now().subtract(
        Duration(
          days: random.nextInt(14),
          hours: random.nextInt(24),
          minutes: random.nextInt(60),
        ),
      );

      // Create the email document in Firestore
      final emailData = {
        'subject': subjects[subjectIndex],
        'senderEmail': senders[senderIndex]['email'],
        'senderName': senders[senderIndex]['name'],
        'recipients': ['exec@cannasol.com'],
        'body': bodies[bodyIndex],
        'receivedAt': Timestamp.fromDate(receivedDate),
        'status': emailStatus.toString().split('.').last,
        'aiResponse': emailStatus == EmailStatus.pending
            ? null
            : 'Thank you for your email. We appreciate your interest in Cannasol Technologies. I have reviewed your request and would like to discuss this further. Are you available for a call next week?',
        'priority': priority,
        'isRead': isRead,
        'hasAttachments': hasAttachments,
        'attachmentUrls': hasAttachments
            ? List.generate(
                random.nextInt(3) + 1,
                (index) =>
                    'https://storage.example.com/attachments/file${random.nextInt(1000)}.${[
                  'pdf',
                  'docx',
                  'xlsx',
                  'jpg'
                ][random.nextInt(4)]}',
              )
            : null,
        'tags': random.nextDouble() < 0.4
            ? List.generate(
                random.nextInt(3) + 1,
                (index) => [
                  'urgent',
                  'sales',
                  'partnership',
                  'contract',
                  'legal',
                  'marketing'
                ][random.nextInt(6)],
              )
            : null,
        'needsResponse': emailStatus != EmailStatus.approved,
        'isSpam': false,
        'archived': false,
      };

      final docRef = await _emailsCollection.add(emailData);

      // Create the Email object
      final email = Email(
        id: docRef.id,
        subject: emailData['subject'] as String,
        senderEmail: emailData['senderEmail'] as String,
        senderName: emailData['senderName'] as String,
        recipients: List<String>.from(emailData['recipients'] as List),
        body: emailData['body'] as String,
        receivedAt: receivedDate,
        status: emailStatus,
        aiResponse: emailData['aiResponse'] as String?,
        priority: priority,
        isRead: isRead,
        hasAttachments: hasAttachments,
        attachmentUrls: emailData['attachmentUrls'] != null
            ? List<String>.from(emailData['attachmentUrls'] as List)
            : null,
        tags: emailData['tags'] != null
            ? List<String>.from(emailData['tags'] as List)
            : null,
        needsResponse: emailData['needsResponse'] as bool,
        isSpam: false,
        archived: false,
      );

      generatedEmails.add(email);

      // Generate some tasks for this email
      if (random.nextDouble() < 0.4) {
        final taskCount = random.nextInt(3) + 1;
        for (int t = 0; t < taskCount; t++) {
          final taskData = {
            'title': 'Follow up on ${subjects[subjectIndex]}',
            'description':
                'Need to review and respond to this email from ${senders[senderIndex]['name']}',
            'sourceEmailId': docRef.id,
            'createdDate': Timestamp.fromDate(DateTime.now()),
            'dueDate': random.nextBool()
                ? Timestamp.fromDate(
                    DateTime.now().add(Duration(days: random.nextInt(14) + 1)),
                  )
                : null,
            'status': ['todo', 'inProgress', 'completed'][random.nextInt(3)],
            'assignedTo': random.nextBool() ? 'Stephen Fisher' : null,
          };

          await _tasksCollection.add(taskData);
        }
      }
    }

    return generatedEmails;
  }
}
