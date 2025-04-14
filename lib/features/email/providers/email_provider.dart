import 'package:flutter/foundation.dart';
import '../models/email.dart';
import '../models/email_task.dart';
import '../services/email_service.dart';

/// Provider class for managing email state
class EmailProvider with ChangeNotifier {
  final EmailService _emailService = EmailService();

  // Emails state
  List<Email> _emails = [];
  List<Email> get emails => _emails;

  // Filtering state
  String? _statusFilter;
  String? get statusFilter => _statusFilter;

  int? _priorityFilter;
  int? get priorityFilter => _priorityFilter;

  bool _includeArchived = false;
  bool get includeArchived => _includeArchived;

  bool _includeSpam = false;
  bool get includeSpam => _includeSpam;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Selected emails state (for multi-select operations)
  final Set<String> _selectedEmailIds = {};
  Set<String> get selectedEmailIds => _selectedEmailIds;

  // Task management state
  List<EmailTask> _tasks = [];
  List<EmailTask> get tasks => _tasks;

  // Email detail state
  Email? _selectedEmail;
  Email? get selectedEmail => _selectedEmail;

  // Loading and error state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Initialize with default emails
  Future<void> initialize() async {
    await fetchEmails();
  }

  /// Fetch emails from Firestore with current filters
  Future<void> fetchEmails() async {
    try {
      _setLoading(true);
      _clearError();

      _emails = await _emailService.getEmails(
        statusFilter: _statusFilter,
        priorityFilter: _priorityFilter,
        includeArchived: _includeArchived,
        includeSpam: _includeSpam,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load emails: $e');
    }
  }

  /// Set the status filter
  Future<void> setStatusFilter(String? status) async {
    if (_statusFilter == status) return;
    _statusFilter = status;
    await fetchEmails();
  }

  /// Set the priority filter
  Future<void> setPriorityFilter(int? priority) async {
    if (_priorityFilter == priority) return;
    _priorityFilter = priority;
    await fetchEmails();
  }

  /// Set the search query
  Future<void> setSearchQuery(String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query;
    await fetchEmails();
  }

  /// Toggle archived emails inclusion
  Future<void> toggleIncludeArchived() async {
    _includeArchived = !_includeArchived;
    await fetchEmails();
  }

  /// Toggle spam emails inclusion
  Future<void> toggleIncludeSpam() async {
    _includeSpam = !_includeSpam;
    await fetchEmails();
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _statusFilter = null;
    _priorityFilter = null;
    _searchQuery = '';
    _includeArchived = false;
    _includeSpam = false;
    await fetchEmails();
  }

  /// Select an email ID for multi-select operations
  void toggleEmailSelection(String emailId) {
    if (_selectedEmailIds.contains(emailId)) {
      _selectedEmailIds.remove(emailId);
    } else {
      _selectedEmailIds.add(emailId);
    }
    notifyListeners();
  }

  /// Clear all selected emails
  void clearSelectedEmails() {
    _selectedEmailIds.clear();
    notifyListeners();
  }

  /// Mark selected emails as read/unread
  Future<void> markEmailsReadStatus(List<String> emailIds, bool isRead) async {
    try {
      _setLoading(true);

      for (final emailId in emailIds) {
        await _emailService.markEmailReadStatus(emailId, isRead);

        // Update local state
        final index = _emails.indexWhere((e) => e.id == emailId);
        if (index != -1) {
          final updatedEmail = _emails[index].copyWith(isRead: isRead);
          _emails[index] = updatedEmail;

          if (_selectedEmail?.id == emailId) {
            _selectedEmail = updatedEmail;
          }
        }
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update email status: $e');
    }
  }

  void setFilters(
      {String? searchQuery,
      String? statusFilter,
      int? priorityFilter,
      bool? includeArchived,
      bool? includeSpam}) {
    // Update filter values; add your filter logic as needed.
    if (searchQuery != null) {
      // e.g., _searchQuery = searchQuery;
    }
    if (statusFilter != null) {
      // e.g., _statusFilter = statusFilter;
    }
    if (priorityFilter != null) {
      // e.g., _priorityFilter = priorityFilter;
    }
    if (includeArchived != null) {
      // e.g., _includeArchived = includeArchived;
    }
    if (includeSpam != null) {
      // e.g., _includeSpam = includeSpam;
    }
    notifyListeners();
  }

  /// Archive selected emails
  Future<void> archiveSelectedEmails() async {
    if (_selectedEmailIds.isEmpty) return;

    try {
      _setLoading(true);

      for (final emailId in _selectedEmailIds) {
        await _emailService.archiveEmail(emailId);
      }

      // Remove archived emails from the list if not including archived
      if (!_includeArchived) {
        _emails =
            _emails.where((e) => !_selectedEmailIds.contains(e.id)).toList();
      } else {
        // Otherwise update the local state
        for (int i = 0; i < _emails.length; i++) {
          if (_selectedEmailIds.contains(_emails[i].id)) {
            _emails[i] = _emails[i].copyWith(archived: true);
          }
        }
      }

      _selectedEmailIds.clear();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to archive emails: $e');
    }
  }

  /// Mark selected emails as spam
  Future<void> markAsSpam(String emailId) async {
    try {
      _setLoading(true);

      await _emailService.markAsSpam(emailId);

      // Remove spam email from the list if not including spam
      if (!_includeSpam) {
        _emails = _emails.where((e) => e.id != emailId).toList();
      } else {
        // Otherwise update the local state
        final index = _emails.indexWhere((e) => e.id == emailId);
        if (index != -1) {
          _emails[index] = _emails[index].copyWith(isSpam: true);
        }
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to mark email as spam: $e');
    }
  }

  /// Select an email to view in detail
  Future<void> selectEmail(String emailId) async {
    try {
      _setLoading(true);
      _clearError();

      _selectedEmail = await _emailService.getEmailById(emailId);

      if (_selectedEmail != null) {
        // Mark as read when viewed
        if (!_selectedEmail!.isRead) {
          await _emailService.markEmailReadStatus(emailId, true);
          _selectedEmail = _selectedEmail!.copyWith(isRead: true);

          // Update in the email list as well
          final index = _emails.indexWhere((e) => e.id == emailId);
          if (index != -1) {
            _emails[index] = _emails[index].copyWith(isRead: true);
          }
        }

        // Fetch related tasks
        await fetchTasksForEmail(emailId);
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load email: $e');
    }
  }

  /// Clear the selected email
  void clearSelectedEmail() {
    _selectedEmail = null;
    _tasks = [];
    notifyListeners();
  }

  /// Update the AI response for an email
  Future<void> updateAiResponse(String emailId, String response) async {
    try {
      _setLoading(true);

      await _emailService.updateAiResponse(emailId, response);

      // Update local state
      if (_selectedEmail?.id == emailId) {
        _selectedEmail = _selectedEmail!.copyWith(
          aiResponse: response,
          status: EmailStatus.responded,
        );
      }

      final index = _emails.indexWhere((e) => e.id == emailId);
      if (index != -1) {
        _emails[index] = _emails[index].copyWith(
          aiResponse: response,
          status: EmailStatus.responded,
        );
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update AI response: $e');
    }
  }

  /// Approve the AI response for an email
  Future<void> approveAiResponse(String emailId) async {
    try {
      _setLoading(true);

      await _emailService.approveAiResponse(emailId);

      // Update local state
      if (_selectedEmail?.id == emailId) {
        _selectedEmail = _selectedEmail!.copyWith(
          status: EmailStatus.approved,
          needsResponse: false,
        );
      }

      final index = _emails.indexWhere((e) => e.id == emailId);
      if (index != -1) {
        _emails[index] = _emails[index].copyWith(
          status: EmailStatus.approved,
          needsResponse: false,
        );
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to approve AI response: $e');
    }
  }

  /// Reject the AI response for an email
  Future<void> rejectAiResponse(String emailId) async {
    try {
      _setLoading(true);

      await _emailService.rejectAiResponse(emailId);

      // Update local state
      if (_selectedEmail?.id == emailId) {
        _selectedEmail = _selectedEmail!.copyWith(
          status: EmailStatus.rejected,
        );
      }

      final index = _emails.indexWhere((e) => e.id == emailId);
      if (index != -1) {
        _emails[index] = _emails[index].copyWith(
          status: EmailStatus.rejected,
        );
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to reject AI response: $e');
    }
  }

  /// Fetch tasks for a specific email
  Future<void> fetchTasksForEmail(String emailId) async {
    try {
      _tasks = await _emailService.getTasksForEmail(emailId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tasks: $e');
    }
  }

  /// Add a new task
  Future<void> addTask(EmailTask task) async {
    try {
      _setLoading(true);

      final newTask = await _emailService.addTask(task);
      _tasks = [..._tasks, newTask];

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add task: $e');
    }
  }

  /// Update an existing task
  Future<void> updateTask(EmailTask task) async {
    try {
      _setLoading(true);

      await _emailService.updateTask(task);

      // Update local state
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update task: $e');
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      _setLoading(true);

      await _emailService.deleteTask(taskId);

      // Remove from local state
      _tasks = _tasks.where((t) => t.id != taskId).toList();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete task: $e');
    }
  }

  /// Generate sample emails for testing
  Future<void> generateSampleEmails(int count) async {
    try {
      _setLoading(true);

      await _emailService.generateSampleEmails(count);

      // Refresh the email list
      await fetchEmails();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to generate sample emails: $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _clearError();
    }
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
