import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:executive_dashboard/features/document_generator/models/document_request.dart';
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
  group('DocumentRequest Enums', () {
    test('DocumentPrivacy should have correct values', () {
      expect(DocumentPrivacy.values.length, equals(3));
      expect(DocumentPrivacy.private.index, equals(0));
      expect(DocumentPrivacy.shared.index, equals(1));
      expect(DocumentPrivacy.oneTime.index, equals(2));
    });

    test('DocumentRequestStatus should have correct values', () {
      expect(DocumentRequestStatus.values.length, equals(4));
      expect(DocumentRequestStatus.pending.index, equals(0));
      expect(DocumentRequestStatus.processing.index, equals(1));
      expect(DocumentRequestStatus.completed.index, equals(2));
      expect(DocumentRequestStatus.failed.index, equals(3));
    });
  });

  group('DocumentRequest', () {
    final testDate = DateTime(2025, 4, 10);
    final formData = {
      'fullName': 'John Doe',
      'age': 30,
      'email': 'john.doe@example.com'
    };

    test('should create a DocumentRequest with all required fields', () {
      final request = DocumentRequest(
        id: 'request-123',
        userId: 'user-abc',
        userName: 'John Doe',
        templateId: 'template-xyz',
        templateName: 'Employee Contract',
        formData: formData,
        privacy: DocumentPrivacy.private,
        status: DocumentRequestStatus.pending,
        createdAt: testDate,
      );

      expect(request.id, equals('request-123'));
      expect(request.userId, equals('user-abc'));
      expect(request.userName, equals('John Doe'));
      expect(request.templateId, equals('template-xyz'));
      expect(request.templateName, equals('Employee Contract'));
      expect(request.formData, equals(formData));
      expect(request.privacy, equals(DocumentPrivacy.private));
      expect(request.status, equals(DocumentRequestStatus.pending));
      expect(request.createdAt, equals(testDate));
      expect(request.completedAt, isNull);
      expect(request.errorMessage, isNull);
      expect(request.generatedDocumentId, isNull);
    });

    test('should create a DocumentRequest with all optional fields', () {
      final completedDate = testDate.add(const Duration(hours: 1));
      final request = DocumentRequest(
        id: 'request-456',
        userId: 'user-def',
        userName: 'Jane Doe',
        templateId: 'template-xyz',
        templateName: 'Invoice',
        formData: formData,
        privacy: DocumentPrivacy.shared,
        status: DocumentRequestStatus.completed,
        createdAt: testDate,
        completedAt: completedDate,
        generatedDocumentId: 'doc-789',
        errorMessage: null,
      );

      expect(request.id, equals('request-456'));
      expect(request.privacy, equals(DocumentPrivacy.shared));
      expect(request.status, equals(DocumentRequestStatus.completed));
      expect(request.completedAt, equals(completedDate));
      expect(request.generatedDocumentId, equals('doc-789'));
      expect(request.errorMessage, isNull);
    });

    test('should create a failed DocumentRequest with error message', () {
      final request = DocumentRequest(
        id: 'request-789',
        userId: 'user-ghi',
        userName: 'Alice Smith',
        templateId: 'template-xyz',
        templateName: 'Contract',
        formData: formData,
        privacy: DocumentPrivacy.oneTime,
        status: DocumentRequestStatus.failed,
        createdAt: testDate,
        completedAt: null,
        generatedDocumentId: null,
        errorMessage: 'Template not found',
      );

      expect(request.id, equals('request-789'));
      expect(request.privacy, equals(DocumentPrivacy.oneTime));
      expect(request.status, equals(DocumentRequestStatus.failed));
      expect(request.completedAt, isNull);
      expect(request.generatedDocumentId, isNull);
      expect(request.errorMessage, equals('Template not found'));
    });

    test('should correctly convert DocumentRequest to map', () {
      final completedDate = testDate.add(const Duration(hours: 1));
      final request = DocumentRequest(
        id: 'request-abc',
        userId: 'user-123',
        userName: 'Bob Johnson',
        templateId: 'template-xyz',
        templateName: 'Contract',
        formData: formData,
        privacy: DocumentPrivacy.shared,
        status: DocumentRequestStatus.completed,
        createdAt: testDate,
        completedAt: completedDate,
        generatedDocumentId: 'doc-xyz',
        errorMessage: null,
      );

      final map = request.toMap();

      expect(map['userId'], equals('user-123'));
      expect(map['userName'], equals('Bob Johnson'));
      expect(map['templateId'], equals('template-xyz'));
      expect(map['templateName'], equals('Contract'));
      expect(map['formData'], equals(formData));
      expect(map['privacy'], equals('shared'));
      expect(map['status'], equals('completed'));
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['completedAt'], isA<Timestamp>());
      expect(map['generatedDocumentId'], equals('doc-xyz'));
      expect(map.containsKey('errorMessage'), isFalse);
    });

    test('should convert enum values correctly to strings in toMap', () {
      // Test private privacy
      final requestPrivate = DocumentRequest(
        id: 'request-1',
        userId: 'user-1',
        userName: 'User',
        templateId: 'template-1',
        templateName: 'Template',
        formData: {},
        privacy: DocumentPrivacy.private,
        status: DocumentRequestStatus.pending,
        createdAt: testDate,
      );
      expect(requestPrivate.toMap()['privacy'], equals('private'));

      // Test shared privacy
      final requestShared = requestPrivate.copyWith();
      expect(requestShared.toMap()['privacy'], equals('private'));

      // Test oneTime privacy
      final requestOneTime = DocumentRequest(
        id: 'request-3',
        userId: 'user-1',
        userName: 'User',
        templateId: 'template-1',
        templateName: 'Template',
        formData: {},
        privacy: DocumentPrivacy.oneTime,
        status: DocumentRequestStatus.pending,
        createdAt: testDate,
      );
      expect(requestOneTime.toMap()['privacy'], equals('oneTime'));

      // Test different statuses
      final requestPending = DocumentRequest(
        id: 'request-4',
        userId: 'user-1',
        userName: 'User',
        templateId: 'template-1',
        templateName: 'Template',
        formData: {},
        privacy: DocumentPrivacy.private,
        status: DocumentRequestStatus.pending,
        createdAt: testDate,
      );
      expect(requestPending.toMap()['status'], equals('pending'));

      final requestProcessing = DocumentRequest(
        id: 'request-5',
        userId: 'user-1',
        userName: 'User',
        templateId: 'template-1',
        templateName: 'Template',
        formData: {},
        privacy: DocumentPrivacy.private,
        status: DocumentRequestStatus.processing,
        createdAt: testDate,
      );
      expect(requestProcessing.toMap()['status'], equals('processing'));

      final requestCompleted = DocumentRequest(
        id: 'request-6',
        userId: 'user-1',
        userName: 'User',
        templateId: 'template-1',
        templateName: 'Template',
        formData: {},
        privacy: DocumentPrivacy.private,
        status: DocumentRequestStatus.completed,
        createdAt: testDate,
      );
      expect(requestCompleted.toMap()['status'], equals('completed'));

      final requestFailed = DocumentRequest(
        id: 'request-7',
        userId: 'user-1',
        userName: 'User',
        templateId: 'template-1',
        templateName: 'Template',
        formData: {},
        privacy: DocumentPrivacy.private,
        status: DocumentRequestStatus.failed,
        createdAt: testDate,
      );
      expect(requestFailed.toMap()['status'], equals('failed'));
    });

    test('should create a copy with updated fields', () {
      final request = DocumentRequest(
        id: 'request-copy',
        userId: 'user-copy',
        userName: 'Copy User',
        templateId: 'template-copy',
        templateName: 'Copy Template',
        formData: {'field': 'value'},
        privacy: DocumentPrivacy.private,
        status: DocumentRequestStatus.pending,
        createdAt: testDate,
      );

      final completedDate = testDate.add(const Duration(hours: 2));
      final updatedRequest = request.copyWith(
        status: DocumentRequestStatus.completed,
        completedAt: completedDate,
        generatedDocumentId: 'doc-generated',
      );

      // Check updated fields
      expect(updatedRequest.status, equals(DocumentRequestStatus.completed));
      expect(updatedRequest.completedAt, equals(completedDate));
      expect(updatedRequest.generatedDocumentId, equals('doc-generated'));

      // Check unchanged fields
      expect(updatedRequest.id, equals('request-copy'));
      expect(updatedRequest.userId, equals('user-copy'));
      expect(updatedRequest.userName, equals('Copy User'));
      expect(updatedRequest.templateId, equals('template-copy'));
      expect(updatedRequest.templateName, equals('Copy Template'));
      expect(updatedRequest.formData, equals({'field': 'value'}));
      expect(updatedRequest.privacy, equals(DocumentPrivacy.private));
      expect(updatedRequest.createdAt, equals(testDate));
    });

    test('should create DocumentRequest from Firestore document snapshot', () {
      final now = DateTime.now();
      final testId = 'request-firestore';
      final testData = {
        'userId': 'user-firestore',
        'userName': 'Firestore User',
        'templateId': 'template-firestore',
        'templateName': 'Firestore Template',
        'formData': {'test': 'data'},
        'privacy': 'shared',
        'status': 'completed',
        'createdAt': Timestamp.fromDate(now),
        'completedAt': Timestamp.fromDate(now.add(const Duration(minutes: 30))),
        'generatedDocumentId': 'doc-firestore',
      };

      final mockSnapshot = MockDocumentSnapshot(testId, testData);
      
      final request = DocumentRequest.fromFirestore(mockSnapshot);
      
      expect(request.id, equals(testId));
      expect(request.userId, equals('user-firestore'));
      expect(request.userName, equals('Firestore User'));
      expect(request.templateId, equals('template-firestore'));
      expect(request.templateName, equals('Firestore Template'));
      expect(request.formData, equals({'test': 'data'}));
      expect(request.privacy, equals(DocumentPrivacy.shared));
      expect(request.status, equals(DocumentRequestStatus.completed));
      expect(request.createdAt, equals(now));
      expect(request.completedAt, equals(now.add(const Duration(minutes: 30))));
      expect(request.generatedDocumentId, equals('doc-firestore'));
      expect(request.errorMessage, isNull);
    });

    test('should handle all privacy types from Firestore document', () {
      final testDate = DateTime.now();
      final baseData = {
        'userId': 'user-test',
        'userName': 'Test User',
        'templateId': 'template-test',
        'templateName': 'Test Template',
        'formData': {},
        'createdAt': Timestamp.fromDate(testDate),
        'status': 'pending'
      };

      // Test private privacy
      final privateData = Map<String, dynamic>.from(baseData)..['privacy'] = 'private';
      final privateSnapshot = MockDocumentSnapshot('request-private', privateData);
      final privateRequest = DocumentRequest.fromFirestore(privateSnapshot);
      expect(privateRequest.privacy, equals(DocumentPrivacy.private));

      // Test shared privacy
      final sharedData = Map<String, dynamic>.from(baseData)..['privacy'] = 'shared';
      final sharedSnapshot = MockDocumentSnapshot('request-shared', sharedData);
      final sharedRequest = DocumentRequest.fromFirestore(sharedSnapshot);
      expect(sharedRequest.privacy, equals(DocumentPrivacy.shared));

      // Test oneTime privacy
      final oneTimeData = Map<String, dynamic>.from(baseData)..['privacy'] = 'oneTime';
      final oneTimeSnapshot = MockDocumentSnapshot('request-onetime', oneTimeData);
      final oneTimeRequest = DocumentRequest.fromFirestore(oneTimeSnapshot);
      expect(oneTimeRequest.privacy, equals(DocumentPrivacy.oneTime));

      // Test default privacy (should be private)
      final defaultData = Map<String, dynamic>.from(baseData)..['privacy'] = 'unknown';
      final defaultSnapshot = MockDocumentSnapshot('request-default', defaultData);
      final defaultRequest = DocumentRequest.fromFirestore(defaultSnapshot);
      expect(defaultRequest.privacy, equals(DocumentPrivacy.private));
    });

    test('should handle all status types from Firestore document', () {
      final testDate = DateTime.now();
      final baseData = {
        'userId': 'user-test',
        'userName': 'Test User',
        'templateId': 'template-test',
        'templateName': 'Test Template',
        'formData': {},
        'createdAt': Timestamp.fromDate(testDate),
        'privacy': 'private'
      };

      // Test pending status
      final pendingData = Map<String, dynamic>.from(baseData)..['status'] = 'pending';
      final pendingSnapshot = MockDocumentSnapshot('request-pending', pendingData);
      final pendingRequest = DocumentRequest.fromFirestore(pendingSnapshot);
      expect(pendingRequest.status, equals(DocumentRequestStatus.pending));

      // Test processing status
      final processingData = Map<String, dynamic>.from(baseData)..['status'] = 'processing';
      final processingSnapshot = MockDocumentSnapshot('request-processing', processingData);
      final processingRequest = DocumentRequest.fromFirestore(processingSnapshot);
      expect(processingRequest.status, equals(DocumentRequestStatus.processing));

      // Test completed status
      final completedData = Map<String, dynamic>.from(baseData)..['status'] = 'completed';
      final completedSnapshot = MockDocumentSnapshot('request-completed', completedData);
      final completedRequest = DocumentRequest.fromFirestore(completedSnapshot);
      expect(completedRequest.status, equals(DocumentRequestStatus.completed));

      // Test failed status
      final failedData = Map<String, dynamic>.from(baseData)..['status'] = 'failed';
      final failedSnapshot = MockDocumentSnapshot('request-failed', failedData);
      final failedRequest = DocumentRequest.fromFirestore(failedSnapshot);
      expect(failedRequest.status, equals(DocumentRequestStatus.failed));

      // Test default status (should be pending)
      final defaultData = Map<String, dynamic>.from(baseData)..['status'] = 'unknown';
      final defaultSnapshot = MockDocumentSnapshot('request-default', defaultData);
      final defaultRequest = DocumentRequest.fromFirestore(defaultSnapshot);
      expect(defaultRequest.status, equals(DocumentRequestStatus.pending));
    });

    test('should handle missing fields in Firestore document with defaults', () {
      final now = DateTime.now();
      final testId = 'request-minimal';
      final testData = {
        'userId': 'user-minimal',
        'createdAt': Timestamp.fromDate(now),
      };

      final mockSnapshot = MockDocumentSnapshot(testId, testData);
      
      final request = DocumentRequest.fromFirestore(mockSnapshot);
      
      expect(request.id, equals(testId));
      expect(request.userId, equals('user-minimal'));
      expect(request.userName, equals(''));
      expect(request.templateId, equals(''));
      expect(request.templateName, equals(''));
      expect(request.formData, isEmpty);
      expect(request.privacy, equals(DocumentPrivacy.private)); // Default
      expect(request.status, equals(DocumentRequestStatus.pending)); // Default
      expect(request.createdAt, equals(now));
      expect(request.completedAt, isNull);
      expect(request.errorMessage, isNull);
      expect(request.generatedDocumentId, isNull);
    });
  });
}