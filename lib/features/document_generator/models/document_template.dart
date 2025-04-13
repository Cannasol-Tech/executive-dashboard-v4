import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a field in a document template
class DocumentField {
  final String name;
  final String label;
  final String type;
  final bool required;
  final dynamic defaultValue;
  final Map<String, dynamic> options;

  DocumentField({
    required this.name,
    required this.label,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.options = const {},
  });

  factory DocumentField.fromMap(Map<String, dynamic> map) {
    return DocumentField(
      name: map['name'] ?? '',
      label: map['label'] ?? '',
      type: map['type'] ?? 'text',
      required: map['required'] ?? false,
      defaultValue: map['defaultValue'],
      options: map['options'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'label': label,
      'type': type,
      'required': required,
      'defaultValue': defaultValue,
      'options': options,
    };
  }
}

/// Represents a document template stored in Firestore
class DocumentTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final String storageUrl;
  final List<DocumentField> fields;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  final bool isActive;

  DocumentTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.storageUrl,
    required this.fields,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
    this.isActive = true,
  });

  /// Creates a DocumentTemplate from a Firestore DocumentSnapshot
  factory DocumentTemplate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Convert fields from raw data
    final List<dynamic> rawFields = data['fields'] ?? [];
    final fields =
        rawFields.map((fieldData) => DocumentField.fromMap(fieldData)).toList();

    return DocumentTemplate(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      storageUrl: data['storageUrl'] ?? '',
      fields: fields,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      metadata: data['metadata'] ?? {},
      isActive: data['isActive'] ?? true,
    );
  }

  /// Converts DocumentTemplate to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'storageUrl': storageUrl,
      'fields': fields.map((field) => field.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'metadata': metadata,
      'isActive': isActive,
    };
  }

  /// Create a copy with some fields updated
  DocumentTemplate copyWith({
    String? name,
    String? description,
    String? category,
    String? storageUrl,
    List<DocumentField>? fields,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    bool? isActive,
  }) {
    return DocumentTemplate(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      storageUrl: storageUrl ?? this.storageUrl,
      fields: fields ?? this.fields,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
    );
  }
}
