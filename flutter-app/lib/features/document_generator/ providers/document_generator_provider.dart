import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document_template.dart';
import '../models/document_request.dart';
import '../models/generated_document.dart';
import '../models/generator_status.dart';
import '../../auth/models/user_model.dart';
import '../../auth/services/auth_service.dart';

class DocumentGeneratorProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();

  // User documents
  List<GeneratedDocument> _userDocuments = [];
  bool _isLoadingUserDocuments = false;

  // Shared documents
  List<GeneratedDocument> _sharedDocuments = [];
  bool _isLoadingSharedDocuments = false;

  // Document requests
  List<DocumentRequest> _userRequests = [];
  bool _isLoadingRequests = false;

  // Templates
  List<DocumentTemplate> _templates = [];
  bool _isLoadingTemplates = false;

  // Selected template and form data
  DocumentTemplate? _selectedTemplate;
  final Map<String, dynamic> _formData = {};
  DocumentPrivacy _selectedPrivacy = DocumentPrivacy.private;

  // Request submission state
  bool _isSubmittingRequest = false;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Status tracking
  final Map<String, StreamSubscription<DocumentSnapshot>> _statusSubscriptions =
      {};

  // Getters
  List<GeneratedDocument> get userDocuments => _userDocuments;
  List<GeneratedDocument> get sharedDocuments => _sharedDocuments;
  List<DocumentRequest> get userRequests => _userRequests;
  List<DocumentTemplate> get templates => _templates;
  bool get isLoadingUserDocuments => _isLoadingUserDocuments;
  bool get isLoadingSharedDocuments => _isLoadingSharedDocuments;
  bool get isLoadingRequests => _isLoadingRequests;
  bool get isLoadingTemplates => _isLoadingTemplates;
  bool get isSubmittingRequest => _isSubmittingRequest;
  DocumentTemplate? get selectedTemplate => _selectedTemplate;
  Map<String, dynamic> get formData => _formData;
  DocumentPrivacy get selectedPrivacy => _selectedPrivacy;
  bool get hasSelectedTemplate => _selectedTemplate != null;
  UserModel get currentUser =>
      UserModel.fromFirebaseUser(_authService.currentUser);

  DocumentGeneratorProvider({required UserModel currentUser}) {
    init();
  }

  void init() {
    fetchTemplates();
    fetchUserDocuments();
    fetchSharedDocuments();
    fetchUserRequests();
  }

  Future<void> refreshAllData() async {
    await Future.wait([
      fetchTemplates(),
      fetchUserDocuments(),
      fetchSharedDocuments(),
      fetchUserRequests(),
    ]);
    notifyListeners();
  }

  // Template Methods
  Future<void> fetchTemplates() async {
    _isLoadingTemplates = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('documentTemplates')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      _templates = snapshot.docs
          .map((doc) => DocumentTemplate.fromFirestore(doc))
          .toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error fetching templates: $e';
      print(_errorMessage);
      _templates = [];
    }

    _isLoadingTemplates = false;
    notifyListeners();
  }

  void selectTemplate(DocumentTemplate template) {
    _selectedTemplate = template;

    // Initialize form data with default values if available
    _formData.clear();
    for (var field in template.fields) {
      if (field.defaultValue != null) {
        _formData[field.name] = field.defaultValue;
      }
    }

    notifyListeners();
  }

  void clearSelectedTemplate() {
    _selectedTemplate = null;
    _formData.clear();
    notifyListeners();
  }

  void updateFormData(String fieldName, dynamic value) {
    _formData[fieldName] = value;
    notifyListeners();
  }

  void setPrivacy(DocumentPrivacy privacy) {
    _selectedPrivacy = privacy;
    notifyListeners();
  }

  // Document Request Methods
  Future<String?> submitRequest() async {
    if (_selectedTemplate == null) return null;

    _isSubmittingRequest = true;
    notifyListeners();

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create request document
      final requestData = {
        'userId': user.uid,
        'userName': user.displayName ?? user.email ?? 'Unknown User',
        'templateId': _selectedTemplate!.id,
        'templateName': _selectedTemplate!.name,
        'formData': _formData,
        'privacy': _selectedPrivacy == DocumentPrivacy.shared
            ? 'shared'
            : _selectedPrivacy == DocumentPrivacy.oneTime
                ? 'oneTime'
                : 'private',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef =
          await _firestore.collection('documentRequests').add(requestData);

      // Create initial status document
      await _firestore.collection('generatorStatus').doc(docRef.id).set({
        'requestId': docRef.id,
        'status': 'pending',
        'progressPercentage': 0,
        'currentStep': 'Queued for processing',
        'remainingTimeInSeconds': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Refresh requests list
      await fetchUserRequests();

      _errorMessage = null;
      _isSubmittingRequest = false;
      notifyListeners();

      return docRef.id;
    } catch (e) {
      _errorMessage = 'Error submitting request: $e';
      print(_errorMessage);
      _isSubmittingRequest = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchUserRequests() async {
    final user = _authService.currentUser;
    if (user == null) return;

    _isLoadingRequests = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('documentRequests')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _userRequests = snapshot.docs
          .map((doc) => DocumentRequest.fromFirestore(doc))
          .toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error fetching user requests: $e';
      print(_errorMessage);
      _userRequests = [];
    }

    _isLoadingRequests = false;
    notifyListeners();
  }

  // Generated Documents Methods
  Future<void> fetchUserDocuments() async {
    final user = _authService.currentUser;
    if (user == null) return;

    _isLoadingUserDocuments = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('generatedDocuments')
          .where('userId', isEqualTo: user.uid)
          .where('isArchived', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      _userDocuments = snapshot.docs
          .map((doc) => GeneratedDocument.fromFirestore(doc))
          .toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error fetching user documents: $e';
      print(_errorMessage);
      _userDocuments = [];
    }

    _isLoadingUserDocuments = false;
    notifyListeners();
  }

  Future<void> fetchSharedDocuments() async {
    _isLoadingSharedDocuments = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('generatedDocuments')
          .where('privacy', isEqualTo: 'shared')
          .where('isArchived', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      _sharedDocuments = snapshot.docs
          .map((doc) => GeneratedDocument.fromFirestore(doc))
          .toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error fetching shared documents: $e';
      print(_errorMessage);
      _sharedDocuments = [];
    }

    _isLoadingSharedDocuments = false;
    notifyListeners();
  }

  Future<Uint8List?> downloadDocument(
      String documentId, DocumentPrivacy privacy) async {
    try {
      // Get document reference
      final docRef =
          _firestore.collection('generatedDocuments').doc(documentId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Document not found');
      }

      final document = GeneratedDocument.fromFirestore(doc);

      // Download file from Firebase Storage
      final ref = _storage.ref(document.storageUrl);
      final data = await ref.getData();

      // If this is a one-time document, delete it after download
      if (privacy == DocumentPrivacy.oneTime) {
        await docRef.delete();
        await ref.delete();

        // Refresh user documents list if it was a user document
        if (document.userId == _authService.currentUser?.uid) {
          _userDocuments.removeWhere((doc) => doc.id == documentId);
          notifyListeners();
        }
      }

      _errorMessage = null;
      return data;
    } catch (e) {
      _errorMessage = 'Error downloading document: $e';
      print(_errorMessage);
      return null;
    }
  }

  Future<void> deleteDocument(
      String documentId, DocumentPrivacy privacy) async {
    try {
      // Get document reference
      final docRef =
          _firestore.collection('generatedDocuments').doc(documentId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Document not found');
      }

      final document = GeneratedDocument.fromFirestore(doc);

      // Delete file from Firebase Storage
      final ref = _storage.ref(document.storageUrl);
      await ref.delete();

      // Delete document from Firestore
      await docRef.delete();

      // Update UI
      if (privacy == DocumentPrivacy.shared) {
        _sharedDocuments.removeWhere((doc) => doc.id == documentId);
      } else {
        _userDocuments.removeWhere((doc) => doc.id == documentId);
      }

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting document: $e';
      print(_errorMessage);
    }
  }

  // Status tracking methods
  Stream<GeneratorStatus?> getStatusStream(String requestId) {
    return _firestore
        .collection('generatorStatus')
        .doc(requestId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return GeneratorStatus.fromFirestore(snapshot);
    });
  }

  void startTrackingStatus(String requestId) {
    // Cancel existing subscription if present
    _statusSubscriptions[requestId]?.cancel();

    // Set up new subscription
    _statusSubscriptions[requestId] = _firestore
        .collection('generatorStatus')
        .doc(requestId)
        .snapshots()
        .listen((snapshot) {
      // Handle status updates if needed
      if (snapshot.exists) {
        final status = GeneratorStatus.fromFirestore(snapshot);

        // If the document generation is complete, refresh the documents list
        if (status.status == DocumentRequestStatus.completed) {
          fetchUserDocuments();
          fetchSharedDocuments();
        }
      }
    });
  }

  void stopTrackingStatus(String requestId) {
    _statusSubscriptions[requestId]?.cancel();
    _statusSubscriptions.remove(requestId);
  }

  @override
  void dispose() {
    // Cancel all status tracking subscriptions
    for (var subscription in _statusSubscriptions.values) {
      subscription.cancel();
    }
    _statusSubscriptions.clear();
    super.dispose();
  }
}
