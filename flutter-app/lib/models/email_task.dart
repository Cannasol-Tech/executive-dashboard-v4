import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Status of a task in the system
enum TaskStatus {
  todo, // Task is open and not started
  inProgress, // Task is currently being worked on
  completed, // Task has been completed
  archived, // Task has been archived
}

/// Model representing a task extracted from or related to an email
class EmailTask {
  final String id;
  final String title;
  final String description;
  final String sourceEmailId; // ID of the email this task is related to
  final DateTime createdDate;
  final DateTime? dueDate;
  final TaskStatus status;
  final String? assignedTo; // User ID or email of the assigned person

  EmailTask({
    required this.id,
    required this.title,
    required this.description,
    required this.sourceEmailId,
    required this.createdDate,
    this.dueDate,
    this.status = TaskStatus.todo,
    this.assignedTo,
  });

  factory EmailTask.fromJson(Map<String, dynamic> json) {
    return EmailTask(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled Task',
      description: json['description'] ?? '',
      sourceEmailId: json['sourceEmailId'] ?? '',
      createdDate: DateTime.parse(json['createdDate']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      assignedTo: json['assignedTo'],
    );
  }

  /// Create an EmailTask from a Firestore document
  factory EmailTask.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse the status string into the enum
    TaskStatus taskStatus;
    try {
      taskStatus = TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => TaskStatus.todo,
      );
    } catch (_) {
      taskStatus = TaskStatus.todo;
    }

    return EmailTask(
      id: doc.id,
      title: data['title'] ?? 'Untitled Task',
      description: data['description'] ?? '',
      sourceEmailId: data['sourceEmailId'] ?? '',
      createdDate: (data['createdDate'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      status: taskStatus,
      assignedTo: data['assignedTo'],
    );
  }

  /// Convert the EmailTask to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'sourceEmailId': sourceEmailId,
      'createdDate': Timestamp.fromDate(createdDate),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'status': status.toString().split('.').last,
      'assignedTo': assignedTo,
    };
  }

  /// Create a copy of this EmailTask with some fields updated
  EmailTask copyWith({
    String? title,
    String? description,
    String? sourceEmailId,
    DateTime? createdDate,
    DateTime? dueDate,
    TaskStatus? status,
    String? assignedTo,
  }) {
    return EmailTask(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sourceEmailId: sourceEmailId ?? this.sourceEmailId,
      createdDate: createdDate ?? this.createdDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}
