import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../auth/models/user_model.dart';
import '../models/document_request.dart';
import '../models/document_template.dart';
import '../models/generated_document.dart';
import '../services/document_request_service.dart';
import '../services/document_template_service.dart';
import '../services/generated_document_service.dart';

/// Provider for managing document generator state
class DocumentGeneratorProvider extends ChangeNotifier {
  // Services
  final DocumentTemplateService _templateService;
  final DocumentRequestService _requestService;
  final GeneratedDocumentService _documentService;

  // User
  final UserModel currentUser;

  // Data
  List<DocumentTemplate> _templates = [];
  List<DocumentRequest> _userRequests = [];
  List<GeneratedDocument> _userDocuments = [];
  List<GeneratedDocument> _sharedDocuments = [];

  // Subscription handles
  StreamSubscription? _templatesSubscription;
  StreamSubscription? _userRequestsSubscription;
  StreamSubscription? _userDocumentsSubscription;
  StreamSubscription? _sharedDocumentsSubscription;

  // Loading states
  bool _isLoadingTemplates = false;
  bool _isLoadingRequests = false;
  bool _isLoadingDocuments = false;
  bool _isLoadingShared = false;
  bool _isSubmitting = false;

  // Error handling
  String? _errorMessage;

  // Selected template
  DocumentTemplate? _selectedTemplate;

  // Getters
  bool get isLoadingTemplates => _isLoadingTemplates;
  bool get isLoadingRequests => _isLoadingRequests;
  bool get isLoadingDocuments => _isLoadingDocuments;
  bool get isLoadingShared => _isLoadingShared;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  List<DocumentTemplate> get templates => List.unmodifiable(_templates);
  List<DocumentRequest> get userRequests => List.unmodifiable(_userRequests);
  List<GeneratedDocument> get userDocuments =>
      List.unmodifiable(_userDocuments);
  List<GeneratedDocument> get sharedDocuments =>
      List.unmodifiable(_sharedDocuments);

  DocumentTemplate? get selectedTemplate => _selectedTemplate;

  DocumentGeneratorProvider({
    required this.currentUser,
    DocumentTemplateService? templateService,
    DocumentRequestService? requestService,
    GeneratedDocumentService? documentService,
  })  : _templateService = templateService ?? DocumentTemplateService(),
        _requestService = requestService ?? DocumentRequestService(),
        _documentService = documentService ?? GeneratedDocumentService() {
    _initStreams();
  }

  @override
  void dispose() {
    _templatesSubscription?.cancel();
    _userRequestsSubscription?.cancel();
    _userDocumentsSubscription?.cancel();
    _sharedDocumentsSubscription?.cancel();
    super.dispose();
  }

  /// Initialize all data streams
  void _initStreams() {
    _loadTemplates();
    _loadUserRequests();
    _loadUserDocuments();
    _loadSharedDocuments();
  }

  /// Refresh all data
  void refreshAllData() {
    _loadTemplates();
    _loadUserRequests();
    _loadUserDocuments();
    _loadSharedDocuments();
  }

  /// Load document templates
  void _loadTemplates() {
    _isLoadingTemplates = true;
    notifyListeners();

    _templatesSubscription?.cancel();
    _templatesSubscription =
        _templateService.getTemplates().listen((templates) {
      _templates = templates;
      _isLoadingTemplates = false;
      notifyListeners();
    }, onError: (error) {
      _isLoadingTemplates = false;
      _errorMessage = 'Error loading templates: $error';
      notifyListeners();
    });
  }

  /// Load user document requests
  void _loadUserRequests() {
    _isLoadingRequests = true;
    notifyListeners();

    _userRequestsSubscription?.cancel();
    _userRequestsSubscription =
        _requestService.getUserRequests(currentUser.uid).listen((requests) {
      _userRequests = requests;
      _isLoadingRequests = false;
      notifyListeners();
    }, onError: (error) {
      _isLoadingRequests = false;
      _errorMessage = 'Error loading requests: $error';
      notifyListeners();
    });
  }

  /// Load user generated documents
  void _loadUserDocuments() {
    _isLoadingDocuments = true;
    notifyListeners();

    _userDocumentsSubscription?.cancel();
    _userDocumentsSubscription =
        _documentService.getUserDocuments(currentUser.uid).listen((documents) {
      _userDocuments = documents;
      _isLoadingDocuments = false;
      notifyListeners();
    }, onError: (error) {
      _isLoadingDocuments = false;
      _errorMessage = 'Error loading documents: $error';
      notifyListeners();
    });
  }

  /// Load documents shared with the user
  void _loadSharedDocuments() {
    _isLoadingShared = true;
    notifyListeners();

    _sharedDocumentsSubscription?.cancel();
    _sharedDocumentsSubscription = _documentService
        .getSharedDocuments(currentUser.uid)
        .listen((documents) {
      _sharedDocuments = documents;
      _isLoadingShared = false;
      notifyListeners();
    }, onError: (error) {
      _isLoadingShared = false;
      _errorMessage = 'Error loading shared documents: $error';
      notifyListeners();
    });
  }

  /// Select a template
  void selectTemplate(String templateId) {
    final selected = _templates.firstWhere(
      (template) => template.id == templateId,
      orElse: () => throw Exception('Template not found'),
    );

    _selectedTemplate = selected;
    notifyListeners();
  }

  /// Clear selected template
  void clearSelectedTemplate() {
    _selectedTemplate = null;
    notifyListeners();
  }

  /// Submit document request
  Future<void> submitDocumentRequest({
    required String templateId,
    required Map<String, dynamic> formData,
    required String privacyOption,
    List<String>? sharedWith,
  }) async {
    try {
      _isSubmitting = true;
      _errorMessage = null;
      notifyListeners();

      await _requestService.createDocumentRequest(
        userId: currentUser.uid,
        userName: currentUser.displayName,
        templateId: templateId,
        formData: formData,
        privacyOption: privacyOption,
        sharedWith: sharedWith,
      );

      _isSubmitting = false;
      notifyListeners();
    } catch (error) {
      _isSubmitting = false;
      _errorMessage = 'Error submitting request: $error';
      notifyListeners();
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get a document template by ID
  DocumentTemplate? getTemplateById(String? templateId) {
    if (templateId == null) return null;

    try {
      return _templates.firstWhere((template) => template.id == templateId);
    } catch (e) {
      return null;
    }
  }
}
