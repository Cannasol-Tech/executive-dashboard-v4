import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/document_request.dart';
import '../models/generated_document.dart';

/// Service for managing generated documents in Firestore.
class GeneratedDocumentService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _userCollectionPath = 'generated-documents/user';
  final String _sharedCollectionPath = 'generated-documents/shared';

  GeneratedDocumentService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Get a stream of user-specific generated documents
  Stream<List<GeneratedDocument>> getUserDocuments(String userId) {
    return _firestore
        .collection(_userCollectionPath)
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GeneratedDocument.fromFirestore(doc))
            .toList());
  }

  /// Get a stream of shared generated documents
  Stream<List<GeneratedDocument>> getSharedDocuments() {
    return _firestore
        .collection(_sharedCollectionPath)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GeneratedDocument.fromFirestore(doc))
            .toList());
  }

  /// Get a specific generated document by ID
  Future<GeneratedDocument?> getDocumentById(
      String documentId, DocumentPrivacy privacy) async {
    final collectionPath = privacy == DocumentPrivacy.shared
        ? _sharedCollectionPath
        : _userCollectionPath;

    final docSnapshot =
        await _firestore.collection(collectionPath).doc(documentId).get();

    if (docSnapshot.exists) {
      return GeneratedDocument.fromFirestore(docSnapshot);
    }

    return null;
  }

  /// Create a new generated document record
  Future<String> createGeneratedDocument({
    required String requestId,
    required String userId,
    required String userName,
    required String templateId,
    required String templateName,
    required String title,
    required DocumentPrivacy privacy,
    required String fileFormat,
    required int sizeInBytes,
    required Uint8List fileData,
    Map<String, dynamic>? metadata,
    Uint8List? thumbnailData,
  }) async {
    // Determine the collection based on privacy setting
    final collectionPath = privacy == DocumentPrivacy.shared
        ? _sharedCollectionPath
        : _userCollectionPath;

    // Create a document reference
    final docRef = _firestore.collection(collectionPath).doc();
    final documentId = docRef.id;

    // Upload the document to Storage
    final String storageUrl = await _uploadDocument(
      documentId: documentId,
      userId: userId,
      fileData: fileData,
      fileFormat: fileFormat,
      privacy: privacy,
    );

    // Upload thumbnail if provided
    String? thumbnailUrl;
    if (thumbnailData != null) {
      thumbnailUrl = await _uploadThumbnail(
        documentId: documentId,
        userId: userId,
        thumbnailData: thumbnailData,
        privacy: privacy,
      );
    }

    // Create the document record
    final document = GeneratedDocument(
      id: documentId,
      userId: userId,
      userName: userName,
      templateId: templateId,
      templateName: templateName,
      title: title,
      storageUrl: storageUrl,
      createdAt: DateTime.now(),
      privacy: privacy,
      sizeInBytes: sizeInBytes,
      fileFormat: fileFormat,
      metadata: metadata ?? {},
      thumbnailUrl: thumbnailUrl,
    );

    // Save to Firestore
    await docRef.set(document.toMap());

    return documentId;
  }

  /// Download a generated document
  Future<Uint8List> downloadDocument(
      String documentId, DocumentPrivacy privacy) async {
    final document = await getDocumentById(documentId, privacy);
    if (document == null) {
      throw Exception('Document not found');
    }

    // Get the file from Storage
    final ref = _storage.refFromURL(document.storageUrl);
    final data = await ref.getData();

    if (data == null) {
      throw Exception('Document data not found');
    }

    // Increment download count
    await _incrementDownloadCount(documentId, privacy);

    // For one-time documents, delete after download
    if (privacy == DocumentPrivacy.oneTime) {
      await _deleteDocument(documentId, privacy);
    }

    return data;
  }

  /// Archive a generated document
  Future<void> archiveDocument(
      String documentId, DocumentPrivacy privacy) async {
    final collectionPath = privacy == DocumentPrivacy.shared
        ? _sharedCollectionPath
        : _userCollectionPath;

    await _firestore
        .collection(collectionPath)
        .doc(documentId)
        .update({'isArchived': true});
  }

  /// Permanently delete a generated document
  Future<void> deleteDocument(
      String documentId, DocumentPrivacy privacy) async {
    await _deleteDocument(documentId, privacy);
  }

  /// Upload a document to Firebase Storage
  Future<String> _uploadDocument({
    required String documentId,
    required String userId,
    required Uint8List fileData,
    required String fileFormat,
    required DocumentPrivacy privacy,
  }) async {
    final path = privacy == DocumentPrivacy.shared
        ? 'documents/shared/$documentId.$fileFormat'
        : 'documents/user/$userId/$documentId.$fileFormat';

    final storageRef = _storage.ref().child(path);
    final uploadTask = storageRef.putData(
      fileData,
      SettableMetadata(contentType: _getContentType(fileFormat)),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Upload a document thumbnail to Firebase Storage
  Future<String> _uploadThumbnail({
    required String documentId,
    required String userId,
    required Uint8List thumbnailData,
    required DocumentPrivacy privacy,
  }) async {
    final path = privacy == DocumentPrivacy.shared
        ? 'documents/shared/thumbnails/$documentId.png'
        : 'documents/user/$userId/thumbnails/$documentId.png';

    final storageRef = _storage.ref().child(path);
    final uploadTask = storageRef.putData(
      thumbnailData,
      SettableMetadata(contentType: 'image/png'),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Increment the download count for a document
  Future<void> _incrementDownloadCount(
      String documentId, DocumentPrivacy privacy) async {
    final collectionPath = privacy == DocumentPrivacy.shared
        ? _sharedCollectionPath
        : _userCollectionPath;

    await _firestore.collection(collectionPath).doc(documentId).update({
      'downloadCount': FieldValue.increment(1),
    });
  }

  /// Delete a document from Firestore and Storage
  Future<void> _deleteDocument(
      String documentId, DocumentPrivacy privacy) async {
    try {
      // Get the document to find file URLs
      final document = await getDocumentById(documentId, privacy);
      if (document == null) return;

      // Delete the main document file
      try {
        await _storage.refFromURL(document.storageUrl).delete();
      } catch (e) {
        if (kDebugMode) {
          print('Error deleting document file: $e');
        }
      }

      // Delete thumbnail if it exists
      if (document.thumbnailUrl != null) {
        try {
          await _storage.refFromURL(document.thumbnailUrl!).delete();
        } catch (e) {
          if (kDebugMode) {
            print('Error deleting document thumbnail: $e');
          }
        }
      }

      // Delete from Firestore
      final collectionPath = privacy == DocumentPrivacy.shared
          ? _sharedCollectionPath
          : _userCollectionPath;

      await _firestore.collection(collectionPath).doc(documentId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error during document deletion: $e');
      }
      throw Exception('Failed to delete document');
    }
  }

  /// Get content type based on file extension
  String _getContentType(String fileFormat) {
    switch (fileFormat.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
