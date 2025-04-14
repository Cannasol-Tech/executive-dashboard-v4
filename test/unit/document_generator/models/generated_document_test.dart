// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:executive_dashboard/features/document_generator/models/document_request.dart';
// import 'package:executive_dashboard/features/document_generator/models/generated_document.dart';
// import 'package:flutter_test/flutter_test.dart';


// void main() {
//   group('GeneratedDocument', () {
//     final testDate = DateTime(2025, 4, 10);
    
//     test('should create a GeneratedDocument with required fields', () {
//       final document = GeneratedDocument(
//         id: 'doc-123',
//         userId: 'user-abc',
//         userName: 'John Doe',
//         title: 'Employee Contract - John Doe',
//         templateId: 'template-xyz',
//         templateName: 'Employee Contract',
//         storageUrl: 'gs://bucket/documents/doc-123.pdf',
//         fileFormat: 'pdf',
//         sizeInBytes: 158720,
//         privacy: DocumentPrivacy.private,
//         createdAt: testDate,
//       );

//       expect(document.id, equals('doc-123'));
//       expect(document.userId, equals('user-abc'));
//       expect(document.userName, equals('John Doe'));
//       expect(document.title, equals('Employee Contract - John Doe'));
//       expect(document.templateId, equals('template-xyz'));
//       expect(document.templateName, equals('Employee Contract'));
//       expect(document.storageUrl, equals('gs://bucket/documents/doc-123.pdf'));
//       expect(document.fileFormat, equals('pdf'));
//       expect(document.sizeInBytes, equals(158720));
//       expect(document.privacy, equals(DocumentPrivacy.private));
//       expect(document.createdAt, equals(testDate));
//       expect(document.thumbnailUrl, isNull);
//       expect(document.metadata, isEmpty);
//       expect(document.isArchived, isFalse);
//       expect(document.archivedAt, isNull);
//     });

//     test('should create a GeneratedDocument with all optional fields', () {
//       final archivedDate = testDate.add(const Duration(days: 30));
//       final document = GeneratedDocument(
//         id: 'doc-456',
//         userId: 'user-def',
//         userName: 'Jane Doe',
//         title: 'Invoice - April 2025',
//         templateId: 'template-invoice',
//         templateName: 'Invoice',
//         storageUrl: 'gs://bucket/documents/doc-456.docx',
//         fileFormat: 'docx',
//         sizeInBytes: 245760,
//         thumbnailUrl: 'gs://bucket/thumbnails/doc-456.png',
//         privacy: DocumentPrivacy.shared,
//         createdAt: testDate,
//         metadata: {'department': 'Finance', 'priority': 'High'},
//         isArchived: true,
//         archivedAt: archivedDate,
//       );

//       expect(document.id, equals('doc-456'));
//       expect(document.userId, equals('user-def'));
//       expect(document.userName, equals('Jane Doe'));
//       expect(document.title, equals('Invoice - April 2025'));
//       expect(document.templateId, equals('template-invoice'));
//       expect(document.templateName, equals('Invoice'));
//       expect(document.storageUrl, equals('gs://bucket/documents/doc-456.docx'));
//       expect(document.fileFormat, equals('docx'));
//       expect(document.sizeInBytes, equals(245760));
//       expect(document.thumbnailUrl, equals('gs://bucket/thumbnails/doc-456.png'));
//       expect(document.privacy, equals(DocumentPrivacy.shared));
//       expect(document.createdAt, equals(testDate));
//       expect(document.metadata['department'], equals('Finance'));
//       expect(document.metadata['priority'], equals('High'));
//       expect(document.isArchived, isTrue);
//       expect(document.archivedAt, equals(archivedDate));
//     });

//     test('should correctly convert GeneratedDocument to map', () {
//       final archivedDate = testDate.add(const Duration(days: 30));
//       final document = GeneratedDocument(
//         id: 'doc-789',
//         userId: 'user-ghi',
//         userName: 'Alice Smith',
//         title: 'Project Proposal',
//         templateId: 'template-proposal',
//         templateName: 'Proposal',
//         storageUrl: 'gs://bucket/documents/doc-789.pdf',
//         fileFormat: 'pdf',
//         sizeInBytes: 352256,
//         thumbnailUrl: 'gs://bucket/thumbnails/doc-789.png',
//         privacy: DocumentPrivacy.oneTime,
//         createdAt: testDate,
//         metadata: {'department': 'Sales', 'client': 'Acme Inc.'},
//         isArchived: true,
//         archivedAt: archivedDate,
//       );

//       final map = document.toMap();

//       expect(map['userId'], equals('user-ghi'));
//       expect(map['userName'], equals('Alice Smith'));
//       expect(map['title'], equals('Project Proposal'));
//       expect(map['templateId'], equals('template-proposal'));
//       expect(map['templateName'], equals('Proposal'));
//       expect(map['storageUrl'], equals('gs://bucket/documents/doc-789.pdf'));
//       expect(map['fileFormat'], equals('pdf'));
//       expect(map['sizeInBytes'], equals(352256));
//       expect(map['thumbnailUrl'], equals('gs://bucket/thumbnails/doc-789.png'));
//       expect(map['privacy'], equals('oneTime'));
//       expect(map['createdAt'], isA<Timestamp>());
//       expect(map['archivedAt'], isA<Timestamp>());
//       expect(map['metadata'], isA<Map>());
//       expect(map['metadata']['department'], equals('Sales'));
//       expect(map['metadata']['client'], equals('Acme Inc.'));
//       expect(map['isArchived'], isTrue);
//     });

//     test('should convert privacy enum values correctly to strings in toMap', () {
//       // Test private privacy
//       final privateDoc = GeneratedDocument(
//         id: 'doc-private',
//         userId: 'user-1',
//         userName: 'User',
//         title: 'Private Document',
//         templateId: 'template-1',
//         templateName: 'Template',
//         storageUrl: 'gs://bucket/doc.pdf',
//         fileFormat: 'pdf',
//         sizeInBytes: 100000,
//         privacy: DocumentPrivacy.private,
//         createdAt: testDate,
//       );
//       expect(privateDoc.toMap()['privacy'], equals('private'));

//       // Test shared privacy
//       final sharedDoc = GeneratedDocument(
//         id: 'doc-shared',
//         userId: 'user-1',
//         userName: 'User',
//         title: 'Shared Document',
//         templateId: 'template-1',
//         templateName: 'Template',
//         storageUrl: 'gs://bucket/doc.pdf',
//         fileFormat: 'pdf',
//         sizeInBytes: 100000,
//         privacy: DocumentPrivacy.shared,
//         createdAt: testDate,
//       );
//       expect(sharedDoc.toMap()['privacy'], equals('shared'));

//       // Test oneTime privacy
//       final oneTimeDoc = GeneratedDocument(
//         id: 'doc-onetime',
//         userId: 'user-1',
//         userName: 'User',
//         title: 'One-Time Document',
//         templateId: 'template-1',
//         templateName: 'Template',
//         storageUrl: 'gs://bucket/doc.pdf',
//         fileFormat: 'pdf',
//         sizeInBytes: 100000,
//         privacy: DocumentPrivacy.oneTime,
//         createdAt: testDate,
//       );
//       expect(oneTimeDoc.toMap()['privacy'], equals('oneTime'));
//     });

//     test('should create a copy with updated fields', () {
//       final document = GeneratedDocument(
//         id: 'doc-copy',
//         userId: 'user-copy',
//         userName: 'Copy User',
//         title: 'Original Title',
//         templateId: 'template-copy',
//         templateName: 'Template',
//         storageUrl: 'gs://bucket/documents/doc-copy.pdf',
//         fileFormat: 'pdf',
//         sizeInBytes: 100000,
//         privacy: DocumentPrivacy.private,
//         createdAt: testDate,
//       );

//       final archivedDate = testDate.add(const Duration(days: 30));
//       final updatedDocument = document.copyWith(
//         title: 'Updated Title',
//         thumbnailUrl: 'gs://bucket/thumbnails/doc-copy.png',
//         metadata: {'key': 'value'},
//         isArchived: true,
//         archivedAt: archivedDate,
//       );

//       // Check updated fields
//       expect(updatedDocument.title, equals('Updated Title'));
//       expect(updatedDocument.thumbnailUrl, equals('gs://bucket/thumbnails/doc-copy.png'));
//       expect(updatedDocument.metadata['key'], equals('value'));
//       expect(updatedDocument.isArchived, isTrue);
//       expect(updatedDocument.archivedAt, equals(archivedDate));

//       // Check unchanged fields
//       expect(updatedDocument.id, equals('doc-copy'));
//       expect(updatedDocument.userId, equals('user-copy'));
//       expect(updatedDocument.userName, equals('Copy User'));
//       expect(updatedDocument.templateId, equals('template-copy'));
//       expect(updatedDocument.templateName, equals('Template'));
//       expect(updatedDocument.storageUrl, equals('gs://bucket/documents/doc-copy.pdf'));
//       expect(updatedDocument.fileFormat, equals('pdf'));
//       expect(updatedDocument.sizeInBytes, equals(100000));
//       expect(updatedDocument.privacy, equals(DocumentPrivacy.private));
//       expect(updatedDocument.createdAt, equals(testDate));
//     });

//     test('should create GeneratedDocument from Firestore document snapshot', () {
//       final now = DateTime.now();
//       final testId = 'doc-firestore';
//       final testData = {
//         'userId': 'user-firestore',
//         'userName': 'Firestore User',
//         'title': 'Generated from Firestore',
//         'templateId': 'template-firestore',
//         'templateName': 'Firestore Template',
//         'storageUrl': 'gs://bucket/doc-firestore.pdf',
//         'fileFormat': 'pdf',
//         'sizeInBytes': 450000,
//         'thumbnailUrl': 'gs://bucket/thumbnails/doc-firestore.png',
//         'privacy': 'shared',
//         'createdAt': Timestamp.fromDate(now),
//         'metadata': {'source': 'test'},
//         'isArchived': true,
//         'archivedAt': Timestamp.fromDate(now.add(const Duration(days: 10))),
//       };

//       final mockSnapshot = MockDocumentSnapshot(testId, testData);
      
//       final document = GeneratedDocument.fromFirestore(mockSnapshot);
      
//       expect(document.id, equals(testId));
//       expect(document.userId, equals('user-firestore'));
//       expect(document.userName, equals('Firestore User'));
//       expect(document.title, equals('Generated from Firestore'));
//       expect(document.templateId, equals('template-firestore'));
//       expect(document.templateName, equals('Firestore Template'));
//       expect(document.storageUrl, equals('gs://bucket/doc-firestore.pdf'));
//       expect(document.fileFormat, equals('pdf'));
//       expect(document.sizeInBytes, equals(450000));
//       expect(document.thumbnailUrl, equals('gs://bucket/thumbnails/doc-firestore.png'));
//       expect(document.privacy, equals(DocumentPrivacy.shared));
//       expect(document.createdAt, equals(now));
//       expect(document.metadata['source'], equals('test'));
//       expect(document.isArchived, isTrue);
//       expect(document.archivedAt, equals(now.add(const Duration(days: 10))));
//     });

//     test('should handle all privacy types from Firestore document', () {
//       final testDate = DateTime.now();
//       final baseData = {
//         'userId': 'user-test',
//         'userName': 'Test User',
//         'title': 'Test Document',
//         'templateId': 'template-test',
//         'templateName': 'Test Template',
//         'storageUrl': 'gs://bucket/test.pdf',
//         'fileFormat': 'pdf',
//         'sizeInBytes': 100000,
//         'createdAt': Timestamp.fromDate(testDate),
//       };

//       // Test private privacy
//       final privateData = Map<String, dynamic>.from(baseData)..['privacy'] = 'private';
//       final privateSnapshot = MockDocumentSnapshot('doc-private', privateData);
//       final privateDoc = GeneratedDocument.fromFirestore(privateSnapshot);
//       expect(privateDoc.privacy, equals(DocumentPrivacy.private));

//       // Test shared privacy
//       final sharedData = Map<String, dynamic>.from(baseData)..['privacy'] = 'shared';
//       final sharedSnapshot = MockDocumentSnapshot('doc-shared', sharedData);
//       final sharedDoc = GeneratedDocument.fromFirestore(sharedSnapshot);
//       expect(sharedDoc.privacy, equals(DocumentPrivacy.shared));

//       // Test oneTime privacy
//       final oneTimeData = Map<String, dynamic>.from(baseData)..['privacy'] = 'oneTime';
//       final oneTimeSnapshot = MockDocumentSnapshot('doc-onetime', oneTimeData);
//       final oneTimeDoc = GeneratedDocument.fromFirestore(oneTimeSnapshot);
//       expect(oneTimeDoc.privacy, equals(DocumentPrivacy.oneTime));

//       // Test default privacy (should be private)
//       final defaultData = Map<String, dynamic>.from(baseData)..['privacy'] = 'unknown';
//       final defaultSnapshot = MockDocumentSnapshot('doc-default', defaultData);
//       final defaultDoc = GeneratedDocument.fromFirestore(defaultSnapshot);
//       expect(defaultDoc.privacy, equals(DocumentPrivacy.private));
//     });

//     test('should handle missing fields in Firestore document with defaults', () {
//       final now = DateTime.now();
//       final testId = 'doc-minimal';
//       final testData = {
//         'userId': 'user-minimal',
//         'createdAt': Timestamp.fromDate(now),
//       };

//       final mockSnapshot = MockDocumentSnapshot(testId, testData);
      
//       final document = GeneratedDocument.fromFirestore(mockSnapshot);
      
//       expect(document.id, equals(testId));
//       expect(document.userId, equals('user-minimal'));
//       expect(document.userName, equals(''));
//       expect(document.title, equals(''));
//       expect(document.templateId, equals(''));
//       expect(document.templateName, equals(''));
//       expect(document.storageUrl, equals(''));
//       expect(document.fileFormat, equals(''));
//       expect(document.sizeInBytes, equals(0));
//       expect(document.thumbnailUrl, isNull);
//       expect(document.privacy, equals(DocumentPrivacy.private)); // Default
//       expect(document.createdAt, equals(now));
//       expect(document.metadata, isEmpty);
//       expect(document.isArchived, isFalse);
//       expect(document.archivedAt, isNull);
//     });
//   });
// }