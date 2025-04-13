import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:executive_dashboard/features/document_generator/models/document_template.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {
  final String _id;
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic> data() => _data;
}

void main() {
  group('DocumentField', () {
    test('should create a DocumentField with default values', () {
      final field = DocumentField(
        name: 'fullName',
        label: 'Full Name',
        type: 'text',
      );

      expect(field.name, equals('fullName'));
      expect(field.label, equals('Full Name'));
      expect(field.type, equals('text'));
      expect(field.required, isFalse);
      expect(field.defaultValue, isNull);
      expect(field.options, isEmpty);
    });

    test('should create a DocumentField with all values provided', () {
      final field = DocumentField(
        name: 'country',
        label: 'Country',
        type: 'select',
        required: true,
        defaultValue: 'USA',
        options: {'choices': ['USA', 'Canada', 'Mexico']},
      );

      expect(field.name, equals('country'));
      expect(field.label, equals('Country'));
      expect(field.type, equals('select'));
      expect(field.required, isTrue);
      expect(field.defaultValue, equals('USA'));
      expect(field.options['choices'], contains('USA'));
      expect(field.options['choices'], contains('Canada'));
      expect(field.options['choices'], contains('Mexico'));
    });

    test('should correctly convert DocumentField to map', () {
      final field = DocumentField(
        name: 'birthDate',
        label: 'Date of Birth',
        type: 'date',
        required: true,
      );

      final map = field.toMap();

      expect(map['name'], equals('birthDate'));
      expect(map['label'], equals('Date of Birth'));
      expect(map['type'], equals('date'));
      expect(map['required'], isTrue);
      expect(map['defaultValue'], isNull);
      expect(map['options'], isEmpty);
    });

    test('should correctly create DocumentField from map', () {
      final map = {
        'name': 'email',
        'label': 'Email Address',
        'type': 'email',
        'required': true,
        'defaultValue': 'test@example.com',
      };

      final field = DocumentField.fromMap(map);

      expect(field.name, equals('email'));
      expect(field.label, equals('Email Address'));
      expect(field.type, equals('email'));
      expect(field.required, isTrue);
      expect(field.defaultValue, equals('test@example.com'));
    });

    test('should handle missing values in map with defaults', () {
      final map = {'name': 'testField'};

      final field = DocumentField.fromMap(map);

      expect(field.name, equals('testField'));
      expect(field.label, equals(''));
      expect(field.type, equals('text'));
      expect(field.required, isFalse);
      expect(field.defaultValue, isNull);
      expect(field.options, isEmpty);
    });
  });

  group('DocumentTemplate', () {
    final testDate = DateTime(2025, 4, 10);
    final testFields = [
      DocumentField(
        name: 'fullName',
        label: 'Full Name',
        type: 'text',
        required: true,
      ),
      DocumentField(
        name: 'age',
        label: 'Age',
        type: 'number',
      ),
    ];

    test('should create a DocumentTemplate with required fields', () {
      final template = DocumentTemplate(
        id: 'template-123',
        name: 'Employee Contract',
        description: 'Standard employment contract',
        category: 'HR',
        storageUrl: 'gs://bucket/templates/employment.docx',
        fields: testFields,
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(template.id, equals('template-123'));
      expect(template.name, equals('Employee Contract'));
      expect(template.description, equals('Standard employment contract'));
      expect(template.category, equals('HR'));
      expect(template.storageUrl, equals('gs://bucket/templates/employment.docx'));
      expect(template.fields.length, equals(2));
      expect(template.createdAt, equals(testDate));
      expect(template.updatedAt, equals(testDate));
      expect(template.metadata, isEmpty);
      expect(template.isActive, isTrue);
    });

    test('should correctly convert DocumentTemplate to map', () {
      final template = DocumentTemplate(
        id: 'template-456',
        name: 'Invoice',
        description: 'Standard invoice template',
        category: 'Finance',
        storageUrl: 'gs://bucket/templates/invoice.docx',
        fields: testFields,
        createdAt: testDate,
        updatedAt: testDate,
        metadata: {'owner': 'finance-team'},
        isActive: true,
      );

      final map = template.toMap();

      expect(map['name'], equals('Invoice'));
      expect(map['description'], equals('Standard invoice template'));
      expect(map['category'], equals('Finance'));
      expect(map['storageUrl'], equals('gs://bucket/templates/invoice.docx'));
      expect(map['fields'], isA<List>());
      expect(map['fields'].length, equals(2));
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['updatedAt'], isA<Timestamp>());
      expect(map['metadata'], isA<Map>());
      expect(map['metadata']['owner'], equals('finance-team'));
      expect(map['isActive'], isTrue);
    });

    test('should correctly create a copy with updated fields', () {
      final template = DocumentTemplate(
        id: 'template-789',
        name: 'Old Contract',
        description: 'Outdated contract',
        category: 'HR',
        storageUrl: 'gs://bucket/templates/old.docx',
        fields: testFields,
        createdAt: testDate,
        updatedAt: testDate,
      );

      final newDate = DateTime(2025, 4, 15);
      final updatedTemplate = template.copyWith(
        name: 'New Contract',
        description: 'Updated contract',
        updatedAt: newDate,
        isActive: false,
      );

      // Check updated fields
      expect(updatedTemplate.name, equals('New Contract'));
      expect(updatedTemplate.description, equals('Updated contract'));
      expect(updatedTemplate.updatedAt, equals(newDate));
      expect(updatedTemplate.isActive, isFalse);

      // Check unchanged fields
      expect(updatedTemplate.id, equals('template-789'));
      expect(updatedTemplate.category, equals('HR'));
      expect(updatedTemplate.storageUrl, equals('gs://bucket/templates/old.docx'));
      expect(updatedTemplate.fields, equals(testFields));
      expect(updatedTemplate.createdAt, equals(testDate));
    });

    // We'll need to mock the DocumentSnapshot for fromFirestore() tests
    test('should create DocumentTemplate from Firestore document snapshot', () {
      final now = DateTime.now();
      final testId = 'template-abc';
      final testData = {
        'name': 'Test Template',
        'description': 'Template for testing',
        'category': 'Test',
        'storageUrl': 'gs://bucket/test.docx',
        'fields': [
          {
            'name': 'testField',
            'label': 'Test Field',
            'type': 'text',
            'required': true,
          }
        ],
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'metadata': {'purpose': 'testing'},
        'isActive': true,
      };

      final mockSnapshot = MockDocumentSnapshot(testId, testData);
      
      final template = DocumentTemplate.fromFirestore(mockSnapshot);
      
      expect(template.id, equals(testId));
      expect(template.name, equals('Test Template'));
      expect(template.description, equals('Template for testing'));
      expect(template.category, equals('Test'));
      expect(template.storageUrl, equals('gs://bucket/test.docx'));
      expect(template.fields.length, equals(1));
      expect(template.fields[0].name, equals('testField'));
      expect(template.fields[0].label, equals('Test Field'));
      expect(template.createdAt, equals(now));
      expect(template.updatedAt, equals(now));
      expect(template.metadata['purpose'], equals('testing'));
      expect(template.isActive, isTrue);
    });

    test('should handle missing fields in Firestore document with defaults', () {
      final now = DateTime.now();
      final testId = 'template-minimal';
      final testData = {
        'name': 'Minimal Template',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final mockSnapshot = MockDocumentSnapshot(testId, testData);
      
      final template = DocumentTemplate.fromFirestore(mockSnapshot);
      
      expect(template.id, equals(testId));
      expect(template.name, equals('Minimal Template'));
      expect(template.description, equals(''));
      expect(template.category, equals(''));
      expect(template.storageUrl, equals(''));
      expect(template.fields, isEmpty);
      expect(template.createdAt, equals(now));
      expect(template.updatedAt, equals(now));
      expect(template.metadata, isEmpty);
      expect(template.isActive, isTrue);
    });
  });
}