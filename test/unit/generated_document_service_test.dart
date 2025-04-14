import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:executive_dashboard/features/document_generator/models/document_request.dart';
import 'package:executive_dashboard/features/document_generator/models/generated_document.dart';
import 'package:executive_dashboard/features/document_generator/services/generated_document_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Generate mocks using mockito's build_runner
import 'mocks/document_template_service_test.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseStorage mockStorage;
  late MockCollectionReference<Map<String, dynamic>> mockUserCollection;
  late MockCollectionReference<Map<String, dynamic>> mockSharedCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late GeneratedDocumentService service;

  // Constants for testing
  final userCollectionPath = 'generated-documents/user';
  final sharedCollectionPath = 'generated-documents/shared';

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    mockUserCollection = MockCollectionReference<Map<String, dynamic>>();
    mockSharedCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

    // Setup the mocks
    when(mockFirestore.collection(userCollectionPath))
        .thenReturn(mockUserCollection);
    when(mockFirestore.collection(sharedCollectionPath))
        .thenReturn(mockSharedCollection);

    // Initialize service with mocks
    service = GeneratedDocumentService(
      firestore: mockFirestore,
      storage: mockStorage,
    );
  });

  group('getUserDocuments', () {
    test('should return a stream of user-specific documents', () async {
      // Setup mock query chain
      when(mockUserCollection.where('userId', isEqualTo: 'user123'))
          .thenReturn(mockQuery);
      when(mockQuery.where('isArchived', isEqualTo: false))
          .thenReturn(mockQuery);
      when(mockQuery.orderBy('createdAt', descending: true))
          .thenReturn(mockQuery);
      
      // Mock snapshot data
      final now = DateTime.now();
      final mockDocs = [
        createMockDocumentSnapshot('doc1', {
          'id': 'doc1',
          'userId': 'user123',
          'userName': 'John Doe',
          'title': 'Employee Contract',
          'templateId': 'template1',
          'templateName': 'Contract',
          'storageUrl': 'gs://bucket/doc1.pdf',
          'fileFormat': 'pdf',
          'sizeInBytes': 150000,
          'privacy': 'private',
          'createdAt': Timestamp.fromDate(now),
          'metadata': {},
          'isArchived': false,
        }),
        createMockDocumentSnapshot('doc2', {
          'id': 'doc2',
          'userId': 'user123',
          'userName': 'John Doe',
          'title': 'Invoice April 2025',
          'templateId': 'template2',
          'templateName': 'Invoice',
          'storageUrl': 'gs://bucket/doc2.pdf',
          'fileFormat': 'pdf',
          'sizeInBytes': 120000,
          'privacy': 'private',
          'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 1))),
          'metadata': {},
          'isArchived': false,
        }),
      ];
      
      when(mockQuerySnapshot.docs).thenReturn(mockDocs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>());
      when(mockQuery.snapshots())
          .thenAnswer((_) => Stream.value(mockQuerySnapshot));

      // Call service method
      final result = service.getUserDocuments('user123');
      
      // Verify results
      await expectLater(
        result,
        emits(isA<List<GeneratedDocument>>().having(
          (list) => list.length,
          'length',
          2,
        )),
      );
    });
  });

  group('getSharedDocuments', () {
    test('should return a stream of shared documents', () async {
      // Setup mock query chain
      when(mockSharedCollection.where('isArchived', isEqualTo: false))
          .thenReturn(mockQuery);
      when(mockQuery.orderBy('createdAt', descending: true))
          .thenReturn(mockQuery);
      
      // Mock snapshot data
      final now = DateTime.now();
      final mockDocs = [
        createMockDocumentSnapshot('shared1', {
          'id': 'shared1',
          'userId': 'user123',
          'userName': 'John Doe',
          'title': 'Shared Contract',
          'templateId': 'template1',
          'templateName': 'Contract',
          'storageUrl': 'gs://bucket/shared1.pdf',
          'fileFormat': 'pdf',
          'sizeInBytes': 160000,
          'privacy': 'shared',
          'createdAt': Timestamp.fromDate(now),
          'metadata': {'department': 'HR'},
          'isArchived': false,
        }),
      ];
      
      when(mockQuerySnapshot.docs).thenReturn(mockDocs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>());
      when(mockQuery.snapshots())
          .thenAnswer((_) => Stream.value(mockQuerySnapshot));

      // Call service method
      final result = service.getSharedDocuments();
      
      // Verify results
      await expectLater(
        result,
        emits(isA<List<GeneratedDocument>>().having(
          (list) => list.length,
          'length',
          1,
        )),
      );
    });
  });

  group('getDocumentById', () {
    test('should return a user document when it exists', () async {
      // Setup mock
      when(mockUserCollection.doc('doc123')).thenReturn(mockDocRef);
      
      final now = DateTime.now();
      final mockDocSnapshot = MockDocumentSnapshot();
      
      when(mockDocSnapshot.id).thenReturn('doc123');
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn({
        'id': 'doc123',
        'userId': 'user123',
        'userName': 'John Doe',
        'title': 'Test Document',
        'templateId': 'template1',
        'templateName': 'Contract',
        'storageUrl': 'gs://bucket/doc123.pdf',
        'fileFormat': 'pdf',
        'sizeInBytes': 140000,
        'privacy': 'private',
        'createdAt': Timestamp.fromDate(now),
        'metadata': {},
        'isArchived': false,
      });
      
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot as DocumentSnapshot<Map<String, dynamic>>);

      // Call service method
      final document = await service.getDocumentById('doc123', DocumentPrivacy.private);
      
      // Verify results
      expect(document, isNotNull);
      expect(document!.id, equals('doc123'));
      expect(document.userId, equals('user123'));
      expect(document.title, equals('Test Document'));
      expect(document.privacy, equals(DocumentPrivacy.private));
    });

    test('should return a shared document when it exists', () async {
      // Setup mock
      when(mockSharedCollection.doc('shared123')).thenReturn(mockDocRef);
      
      final now = DateTime.now();
      final mockDocSnapshot = MockDocumentSnapshot();
      
      when(mockDocSnapshot.id).thenReturn('shared123');
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn({
        'id': 'shared123',
        'userId': 'user123',
        'userName': 'John Doe',
        'title': 'Shared Document',
        'templateId': 'template1',
        'templateName': 'Contract',
        'storageUrl': 'gs://bucket/shared123.pdf',
        'fileFormat': 'pdf',
        'sizeInBytes': 140000,
        'privacy': 'shared',
        'createdAt': Timestamp.fromDate(now),
        'metadata': {},
        'isArchived': false,
      });
      
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot as DocumentSnapshot<Map<String, dynamic>>);

      // Call service method
      final document = await service.getDocumentById('shared123', DocumentPrivacy.shared);
      
      // Verify results
      expect(document, isNotNull);
      expect(document!.id, equals('shared123'));
      expect(document.userId, equals('user123'));
      expect(document.title, equals('Shared Document'));
      expect(document.privacy, equals(DocumentPrivacy.shared));
    });

    test('should return null when document does not exist', () async {
      // Setup mock
      when(mockUserCollection.doc('nonexistent')).thenReturn(mockDocRef);
      
      final mockDocSnapshot = MockDocumentSnapshot();
      when(mockDocSnapshot.exists).thenReturn(false);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot as DocumentSnapshot<Map<String, dynamic>>);

      // Call service method
      final document = await service.getDocumentById('nonexistent', DocumentPrivacy.private);
      
      // Verify results
      expect(document, isNull);
    });
  });

  group('createGeneratedDocument', () {
    test('should upload file and create document record for private document', () async {
      // Setup mocks
      when(mockUserCollection.doc()).thenReturn(mockDocRef);
      when(mockDocRef.id).thenReturn('new-doc-id');
      
      // Storage mocks for main file
      final mockStorageRef = MockReference();
      final mockUploadTask = MockUploadTask();
      final mockTaskSnapshot = MockTaskSnapshot();
      
      when(mockStorage.ref()).thenReturn(mockStorageRef);
      when(mockStorageRef.child(any)).thenReturn(mockStorageRef);
      when(mockStorageRef.putData(any, any)).thenReturn(mockUploadTask);
      when(mockUploadTask.then<TaskSnapshot>(any, onError: anyNamed('onError')))
          .thenAnswer((invocation) {
        final completer = invocation.positionalArguments[0];
        return Future.value(completer(mockTaskSnapshot));
      });
      when(mockTaskSnapshot.ref).thenReturn(mockStorageRef);
      when(mockStorageRef.getDownloadURL())
          .thenAnswer((_) async => 'https://storage-url.com/doc.pdf');
          
      // Set mock for Firestore .set()
      when(mockDocRef.set(any)).thenAnswer((_) async {});

      // Call service method
      final documentId = await service.createGeneratedDocument(
        requestId: 'request123',
        userId: 'user123',
        userName: 'John Doe',
        templateId: 'template1',
        templateName: 'Contract',
        title: 'Employment Contract - John Doe',
        privacy: DocumentPrivacy.private,
        fileFormat: 'pdf',
        sizeInBytes: 150000,
        fileData: Uint8List(10), // Dummy file data
      );
      
      // Verify results
      expect(documentId, equals('new-doc-id'));
      
      // Verify the correct calls were made
      verify(mockUserCollection.doc()).called(1);
      verify(mockDocRef.set(any)).called(1);
    });

    test('should upload file, thumbnail and create shared document record', () async {
      // Setup mocks
      when(mockSharedCollection.doc()).thenReturn(mockDocRef);
      when(mockDocRef.id).thenReturn('new-shared-id');
      
      // Storage mocks for main file
      final mockStorageRef = MockReference();
      final mockUploadTask = MockUploadTask();
      final mockTaskSnapshot = MockTaskSnapshot();
      
      when(mockStorage.ref()).thenReturn(mockStorageRef);
      when(mockStorageRef.child(any)).thenReturn(mockStorageRef);
      when(mockStorageRef.putData(any, any)).thenReturn(mockUploadTask);
      when(mockUploadTask.then<TaskSnapshot>(any, onError: anyNamed('onError')))
          .thenAnswer((invocation) {
        final completer = invocation.positionalArguments[0];
        return Future.value(completer(mockTaskSnapshot));
      });
      when(mockTaskSnapshot.ref).thenReturn(mockStorageRef);
      
      // First call returns main file URL, second call returns thumbnail URL
      when(mockStorageRef.getDownloadURL())
          .thenAnswer((_) async => 'https://storage-url.com/doc.pdf');
      
      // Create a separate mock for the thumbnail reference
      final mockThumbnailRef = MockReference();
      when(mockStorageRef.child('thumbnails/new-shared-id.png')).thenReturn(mockThumbnailRef);
      when(mockThumbnailRef.putData(any, any)).thenReturn(mockUploadTask);
      when(mockThumbnailRef.getDownloadURL())
          .thenAnswer((_) async => 'https://storage-url.com/thumb.png');
          
      // Set mock for Firestore .set()
      when(mockDocRef.set(any)).thenAnswer((_) async {});

      // Call service method with thumbnail data
      final documentId = await service.createGeneratedDocument(
        requestId: 'request123',
        userId: 'user123',
        userName: 'John Doe',
        templateId: 'template1',
        templateName: 'Contract',
        title: 'Shared Contract',
        privacy: DocumentPrivacy.shared,
        fileFormat: 'pdf',
        sizeInBytes: 150000,
        fileData: Uint8List(10), // Dummy file data
        thumbnailData: Uint8List(5), // Dummy thumbnail data
      );
      
      // Verify results
      expect(documentId, equals('new-shared-id'));
      
      // Verify the correct calls were made
      verify(mockSharedCollection.doc()).called(1);
      verify(mockStorageRef.putData(any, any)).called(2); // Main file and thumbnail
      verify(mockDocRef.set(any)).called(1);
    });
  });

  group('downloadDocument', () {
    test('should download document and increment download count', () async {
    // Setup mocks for getDocumentById
    when(mockUserCollection.doc('doc-to-download')).thenReturn(mockDocRef);
    
    final mockDocSnapshot = MockDocumentSnapshot();
    when(mockDocSnapshot.id).thenReturn('doc-to-download');
    when(mockDocSnapshot.exists).thenReturn(true);
    when(mockDocSnapshot.data()).thenReturn({
        'userId': 'user123',
        'title': 'Download Test',
        'storageUrl': 'gs://bucket/download.pdf',
        'fileFormat': 'pdf',
        'sizeInBytes': 100000,
        'privacy': 'private',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'metadata': {},
        'isArchived': false,
      });
      
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot as DocumentSnapshot<Map<String, dynamic>>);
      
      // Setup mock for storage download
      final mockStorageRef = MockReference();
      when(mockStorage.refFromURL('gs://bucket/download.pdf'))
          .thenReturn(mockStorageRef);
      
      final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
      when(mockStorageRef.getData()).thenAnswer((_) async => testData);
      
      // Setup mock for increment download count
      when(mockDocRef.update(any)).thenAnswer((_) async {});
      
      // Call service method
      final downloadedData = await service.downloadDocument(
        'doc-to-download',
        DocumentPrivacy.private,
      );
      
      // Verify results
      expect(downloadedData, equals(testData));
      
      // Verify download count was incremented
      verify(mockDocRef.update(any)).called(1);
    });

    test('should delete one-time document after download', () async {
    // Setup mocks for getDocumentById
    when(mockUserCollection.doc('one-time-doc')).thenReturn(mockDocRef);
    
    final mockDocSnapshot = MockDocumentSnapshot();
    when(mockDocSnapshot.id).thenReturn('one-time-doc');
    when(mockDocSnapshot.exists).thenReturn(true);
    when(mockDocSnapshot.data()).thenReturn({
        'userId': 'user123',
        'title': 'One-Time Document',
        'storageUrl': 'gs://bucket/one-time.pdf',
        'fileFormat': 'pdf',
        'sizeInBytes': 100000,
        'privacy': 'oneTime',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'metadata': {},
        'isArchived': false,
      });
      
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot as DocumentSnapshot<Map<String, dynamic>>);
      
      // Setup mock for storage download and delete
      final mockStorageRef = MockReference();
      when(mockStorage.refFromURL('gs://bucket/one-time.pdf'))
          .thenReturn(mockStorageRef);
      
      final testData = Uint8List.fromList([1, 2, 3, 4, 5]);
      when(mockStorageRef.getData()).thenAnswer((_) async => testData);
      when(mockStorageRef.delete()).thenAnswer((_) async {});
      
      // Setup mock for increment download count and delete document
      when(mockDocRef.update(any)).thenAnswer((_) async {});
      when(mockDocRef.delete()).thenAnswer((_) async {});
      
      // Call service method
      final downloadedData = await service.downloadDocument(
        'one-time-doc',
        DocumentPrivacy.oneTime,
      );
      
      // Verify results
      expect(downloadedData, equals(testData));
      
      // Verify document was deleted
      verify(mockStorageRef.delete()).called(1);
      verify(mockDocRef.delete()).called(1);
    });

    test('should throw exception when document not found', () async {
      // Setup mock
      when(mockUserCollection.doc('nonexistent')).thenReturn(mockDocRef);
      
      final mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockDocSnapshot.exists).thenReturn(false);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot as DocumentSnapshot<Map<String, dynamic>>);

      // Call service method and expect exception
      expect(() => service.downloadDocument(
        'nonexistent',
        DocumentPrivacy.private,
      ), throwsException);
    });
  });

  group('archiveDocument', () {
    test('should update document as archived', () async {
      // Setup mocks
      when(mockUserCollection.doc('doc-to-archive')).thenReturn(mockDocRef);
      when(mockDocRef.update(any)).thenAnswer((_) async {});

      // Call service method
      await service.archiveDocument('doc-to-archive', DocumentPrivacy.private);
      
      // Verify the update was called with isArchived=true
      verify(mockDocRef.update({'isArchived': true})).called(1);
    });
  });

  group('deleteDocument', () {
    test('should delete document file and record', () async {
    // Setup mocks for getDocumentById
    when(mockUserCollection.doc('doc-to-delete')).thenReturn(mockDocRef);
    
    final mockDocSnapshot = MockDocumentSnapshot();
    when(mockDocSnapshot.id).thenReturn('doc-to-delete');
    when(mockDocSnapshot.exists).thenReturn(true);
    when(mockDocSnapshot.data()).thenReturn({
        'userId': 'user123',
        'title': 'Document to Delete',
        'storageUrl': 'gs://bucket/delete.pdf',
        'thumbnailUrl': 'gs://bucket/delete-thumb.png',
        'fileFormat': 'pdf',
        'sizeInBytes': 100000,
        'privacy': 'private',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'metadata': {},
        'isArchived': false,
      });
      
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot as DocumentSnapshot<Map<String, dynamic>>);
      
      // Setup mock for storage deletion
      final mockFileRef = MockReference();
      final mockThumbRef = MockReference();
      when(mockStorage.refFromURL('gs://bucket/delete.pdf'))
          .thenReturn(mockFileRef);
      when(mockStorage.refFromURL('gs://bucket/delete-thumb.png'))
          .thenReturn(mockThumbRef);
      
      when(mockFileRef.delete()).thenAnswer((_) async {});
      when(mockThumbRef.delete()).thenAnswer((_) async {});
      
      // Setup mock for document deletion
      when(mockDocRef.delete()).thenAnswer((_) async {});

      // Call service method
      await service.deleteDocument('doc-to-delete', DocumentPrivacy.private);
      
      // Verify the file and document were deleted
      verify(mockFileRef.delete()).called(1);
      verify(mockThumbRef.delete()).called(1);
      verify(mockDocRef.delete()).called(1);
    });

    test('should gracefully handle errors during file deletion', () async {
    // Setup mocks for getDocumentById
    when(mockUserCollection.doc('error-doc')).thenReturn(mockDocRef);
    
    final mockDocSnapshot = MockDocumentSnapshot();
    when(mockDocSnapshot.id).thenReturn('error-doc');
    when(mockDocSnapshot.exists).thenReturn(true);
    when(mockDocSnapshot.data()).thenReturn({
        'userId': 'user123',
        'title': 'Error Document',
        'storageUrl': 'gs://bucket/error.pdf',
        'fileFormat': 'pdf',
        'sizeInBytes': 100000,
        'privacy': 'private',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'metadata': {},
        'isArchived': false,
      });
      
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot as DocumentSnapshot<Map<String, dynamic>>);
      
      // Setup mock for storage deletion with error
      final mockFileRef = MockReference();
      when(mockStorage.refFromURL('gs://bucket/error.pdf'))
          .thenReturn(mockFileRef);
      
      when(mockFileRef.delete()).thenThrow(Exception('Storage error'));
      
      // Setup mock for document deletion
      when(mockDocRef.delete()).thenAnswer((_) async {});

      // Call service method - should not throw
      await service.deleteDocument('error-doc', DocumentPrivacy.private);
      
      // Verify document was still deleted despite file error
      verify(mockDocRef.delete()).called(1);
    });

    test('should throw exception when total deletion fails', () async {
    // Setup mocks for getDocumentById
    when(mockUserCollection.doc('critical-error')).thenReturn(mockDocRef);
    
    MockDocumentSnapshot mockDocSnapshot = MockDocumentSnapshot();
    when(mockDocSnapshot.id).thenReturn('critical-error');
    when(mockDocSnapshot.exists).thenReturn(true);
    when(mockDocSnapshot.data()).thenReturn({
        'userId': 'user123',
        'title': 'Critical Error Doc',
        'storageUrl': 'gs://bucket/critical.pdf',
        'fileFormat': 'pdf',
        'sizeInBytes': 100000,
        'privacy': 'private',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'metadata': {},
        'isArchived': false,
      });
      
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot as DocumentSnapshot<Map<String, dynamic>>);
      
      // Setup mock for storage reference
      final mockFileRef = MockReference();
      when(mockStorage.refFromURL('gs://bucket/critical.pdf'))
          .thenReturn(mockFileRef);
      
      when(mockFileRef.delete()).thenAnswer((_) async {});
      
      // Setup mock for document deletion with critical error
      when(mockDocRef.delete()).thenThrow(Exception('Critical Firestore error'));

      // Call service method and expect exception
      expect(() => service.deleteDocument('critical-error', DocumentPrivacy.private), 
        throwsException);
    });
  });
}

// Helper to create mock document snapshots
MockQueryDocumentSnapshot createMockDocumentSnapshot(String id, Map<String, dynamic> data) {
  final snapshot = MockQueryDocumentSnapshot();
  when(snapshot.id).thenReturn(id);
  when(snapshot.data()).thenReturn(data);
  return snapshot;
}