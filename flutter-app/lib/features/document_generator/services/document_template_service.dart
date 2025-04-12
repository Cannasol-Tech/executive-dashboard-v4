import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../models/document_template.dart';

/// Service for managing document templates in Firestore.
class DocumentTemplateService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _collectionPath = 'document-templates';

  DocumentTemplateService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Get a stream of all active document templates
  Stream<List<DocumentTemplate>> getTemplates() {
    return _firestore
        .collection(_collectionPath)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DocumentTemplate.fromFirestore(doc))
          .toList();
    });
  }

  /// Get templates by category
  Stream<List<DocumentTemplate>> getTemplatesByCategory(String category) {
    return _firestore
        .collection(_collectionPath)
        .where('isActive', isEqualTo: true)
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DocumentTemplate.fromFirestore(doc))
          .toList();
    });
  }

  /// Get a specific document template by ID
  Future<DocumentTemplate?> getTemplateById(String templateId) async {
    final docSnapshot =
        await _firestore.collection(_collectionPath).doc(templateId).get();

    if (docSnapshot.exists) {
      return DocumentTemplate.fromFirestore(docSnapshot);
    }

    return null;
  }

  /// Create a new document template
  Future<String> createTemplate({
    required String name,
    required String description,
    required String category,
    required List<DocumentField> fields,
    required Uint8List fileData,
    required String fileName,
    Map<String, dynamic>? metadata,
  }) async {
    // 1. Create a reference in Firestore to get an ID
    final templateRef = _firestore.collection(_collectionPath).doc();
    final templateId = templateRef.id;

    // 2. Upload the template file to Storage
    final storageRef = _storage.ref().child('templates/$templateId/$fileName');
    final uploadTask = storageRef.putData(
      fileData,
      SettableMetadata(contentType: _getContentType(fileName)),
    );

    // 3. Wait for upload to complete and get download URL
    final snapshot = await uploadTask;
    final storageUrl = await snapshot.ref.getDownloadURL();

    // 4. Create the document template with the file URL
    final template = DocumentTemplate(
      id: templateId,
      name: name,
      description: description,
      category: category,
      storageUrl: storageUrl,
      fields: fields,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: metadata ?? {},
    );

    // 5. Save the template to Firestore
    await templateRef.set(template.toMap());

    return templateId;
  }

  /// Update an existing document template
  Future<void> updateTemplate({
    required String templateId,
    String? name,
    String? description,
    String? category,
    List<DocumentField>? fields,
    Uint8List? fileData,
    String? fileName,
    Map<String, dynamic>? metadata,
    bool? isActive,
  }) async {
    // Get the current template
    final templateSnapshot =
        await _firestore.collection(_collectionPath).doc(templateId).get();
    if (!templateSnapshot.exists) {
      throw Exception('Template not found');
    }

    final currentTemplate = DocumentTemplate.fromFirestore(templateSnapshot);
    String storageUrl = currentTemplate.storageUrl;

    // If there's new file data, upload it
    if (fileData != null && fileName != null) {
      final storageRef =
          _storage.ref().child('templates/$templateId/$fileName');
      final uploadTask = storageRef.putData(
        fileData,
        SettableMetadata(contentType: _getContentType(fileName)),
      );

      final snapshot = await uploadTask;
      storageUrl = await snapshot.ref.getDownloadURL();
    }

    // Create updated template
    final updatedTemplate = currentTemplate.copyWith(
      name: name,
      description: description,
      category: category,
      storageUrl: storageUrl,
      fields: fields,
      updatedAt: DateTime.now(),
      metadata: metadata,
      isActive: isActive,
    );

    // Update Firestore
    await _firestore
        .collection(_collectionPath)
        .doc(templateId)
        .update(updatedTemplate.toMap());
  }

  /// Delete a document template (mark as inactive)
  Future<void> deleteTemplate(String templateId) async {
    await _firestore
        .collection(_collectionPath)
        .doc(templateId)
        .update({'isActive': false});
  }

  /// Permanently delete a document template and its file
  Future<void> permanentlyDeleteTemplate(String templateId) async {
    // Get the template to find the file path
    final templateSnapshot =
        await _firestore.collection(_collectionPath).doc(templateId).get();
    if (templateSnapshot.exists) {
      // Delete from Storage
      try {
        final fileRef = _storage.refFromURL(
            (templateSnapshot.data() as Map<String, dynamic>)['storageUrl']);
        await fileRef.delete();
      } catch (e) {
        if (kDebugMode) {
          print('Error deleting template file: $e');
        }
        // Continue even if file deletion fails
      }
    }

    // Delete from Firestore
    await _firestore.collection(_collectionPath).doc(templateId).delete();
  }

  /// Get content type based on file extension
  String _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
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
