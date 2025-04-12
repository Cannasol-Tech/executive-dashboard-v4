import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Status of an email in the system
enum EmailStatus {
  pending, // Awaiting AI response generation
  responded, // AI has generated a response
  approved, // Response has been approved by the user
  rejected, // Response has been rejected by the user
}

extension EmailStatusExtension on EmailStatus {
  String get displayName {
    switch (this) {
      case EmailStatus.pending:
        return 'Pending';
      case EmailStatus.responded:
        return 'Response Ready';
      case EmailStatus.approved:
        return 'Approved';
      case EmailStatus.rejected:
        return 'Rejected';
    }
  }
}

/// Model representing an email in the system
class Email {
  final String id;
  final String subject;
  final String senderEmail;
  final String senderName;
  final List<String> recipients;
  final String body;
  final DateTime receivedAt;
  final EmailStatus status;
  final String? aiResponse;
  final int priority; // 1 = High, 2 = Medium, 3 = Low
  final bool isRead;
  final bool hasAttachments;
  final List<String>? attachmentUrls;
  final List<String>? tags;
  final bool needsResponse;
  final bool isSpam;
  final bool archived;

  Email({
    required this.id,
    required this.subject,
    required this.senderEmail,
    required this.senderName,
    required this.recipients,
    required this.body,
    required this.receivedAt,
    required this.status,
    this.aiResponse,
    required this.priority,
    required this.isRead,
    required this.hasAttachments,
    this.attachmentUrls,
    this.tags,
    required this.needsResponse,
    required this.isSpam,
    required this.archived,
  });

  /// Create an Email from a Firestore document
  factory Email.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse the status string into the enum
    EmailStatus emailStatus;
    try {
      emailStatus = EmailStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => EmailStatus.pending,
      );
    } catch (_) {
      emailStatus = EmailStatus.pending;
    }

    return Email(
      id: doc.id,
      subject: data['subject'] ?? 'No Subject',
      senderEmail: data['senderEmail'] ?? '',
      senderName: data['senderName'] ?? '',
      recipients: List<String>.from(data['recipients'] ?? []),
      body: data['body'] ?? '',
      receivedAt: (data['receivedAt'] as Timestamp).toDate(),
      status: emailStatus,
      aiResponse: data['aiResponse'],
      priority: data['priority'] ?? 2,
      isRead: data['isRead'] ?? false,
      hasAttachments: data['hasAttachments'] ?? false,
      attachmentUrls: data['attachmentUrls'] != null
          ? List<String>.from(data['attachmentUrls'])
          : null,
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      needsResponse: data['needsResponse'] ?? true,
      isSpam: data['isSpam'] ?? false,
      archived: data['archived'] ?? false,
    );
  }

  /// Convert the Email to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'subject': subject,
      'senderEmail': senderEmail,
      'senderName': senderName,
      'recipients': recipients,
      'body': body,
      'receivedAt': Timestamp.fromDate(receivedAt),
      'status': status.toString().split('.').last,
      'aiResponse': aiResponse,
      'priority': priority,
      'isRead': isRead,
      'hasAttachments': hasAttachments,
      'attachmentUrls': attachmentUrls,
      'tags': tags,
      'needsResponse': needsResponse,
      'isSpam': isSpam,
      'archived': archived,
    };
  }

  /// Get a formatted date string for display
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final date = DateTime(receivedAt.year, receivedAt.month, receivedAt.day);

    if (date == today) {
      return DateFormat.jm()
          .format(receivedAt); // Today's emails show time only
    } else if (date == yesterday) {
      return 'Yesterday';
    } else if (now.difference(receivedAt).inDays < 7) {
      return DateFormat.E().format(receivedAt); // Show day of week
    } else {
      return DateFormat.yMd()
          .format(receivedAt); // Show full date for older emails
    }
  }

  /// Get a snippet of the email body for preview
  String get snippet {
    if (body.length > 100) {
      return '${body.substring(0, 100)}...';
    }
    return body;
  }

  /// Create a copy of this Email with some fields updated
  Email copyWith({
    String? subject,
    String? senderEmail,
    String? senderName,
    List<String>? recipients,
    String? body,
    DateTime? receivedAt,
    EmailStatus? status,
    String? aiResponse,
    int? priority,
    bool? isRead,
    bool? hasAttachments,
    List<String>? attachmentUrls,
    List<String>? tags,
    bool? needsResponse,
    bool? isSpam,
    bool? archived,
  }) {
    return Email(
      id: this.id,
      subject: subject ?? this.subject,
      senderEmail: senderEmail ?? this.senderEmail,
      senderName: senderName ?? this.senderName,
      recipients: recipients ?? this.recipients,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      status: status ?? this.status,
      aiResponse: aiResponse ?? this.aiResponse,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      tags: tags ?? this.tags,
      needsResponse: needsResponse ?? this.needsResponse,
      isSpam: isSpam ?? this.isSpam,
      archived: archived ?? this.archived,
    );
  }
}
