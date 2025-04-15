import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/dashboard_summary.dart';
import '../../../core/services/firestore_service.dart';

/// Provider for dashboard summary data
class DashboardSummaryProvider with ChangeNotifier {
  FirestoreService? _firestoreService;
  
  DashboardSummary _summaryData = DashboardSummary.empty();
  bool _isLoading = false;
  String? _error;
  bool _firebaseInitialized = false;

  DashboardSummary get summaryData => _summaryData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DashboardSummaryProvider({bool firebaseInitialized = false}) {
    _firebaseInitialized = firebaseInitialized;
    // Do not auto-fetch in constructor. Wait for explicit call after auth.
    _summaryData = _createSampleData();
  }
  
  /// Call this after authentication is confirmed, passing the BuildContext
  void maybeStartFetching(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      if (_firestoreService == null) {
        _initializeServices();
      }
    } else {
      // If user logs out, clear data
      _firestoreService = null;
      _summaryData = _createSampleData();
      notifyListeners();
    }
  }
  
  void _initializeServices() {
    try {
      _firestoreService = FirestoreService();
      fetchSummaryData();
    } catch (e) {
      print('Error initializing Firebase services: $e');
      _error = 'Failed to initialize services';
      _summaryData = _createSampleData();
    }
  }
  
  // Set Firebase initialization state from outside
  void setFirebaseInitialized(bool initialized) {
    if (initialized && !_firebaseInitialized) {
      _firebaseInitialized = true;
      _initializeServices();
    }
  }

  Future<void> fetchSummaryData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For development, we'll use sample data if Firestore fetch fails
      try {
        _summaryData = await _firestoreService!.getDashboardSummary();
        // If the returned data is empty (which means the document doesn't exist),
        // create sample data instead
        if (_summaryData.customerCount == 0 && 
            _summaryData.revenueCurrent == 0.0) {
          _summaryData = _createSampleData();
        }
      } catch (e) {
        print('Error fetching from Firestore: $e');
        // Fallback to sample data
        _summaryData = _createSampleData();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Creates sample dashboard data for development and testing
  DashboardSummary _createSampleData() {
    return DashboardSummary(
      revenueCurrent: 527350.45,
      revenueTarget: 600000.00,
      revenueGrowth: 12.5,
      customerCount: 1842,
      customerGrowth: 8.2,
      activeOperations: 17,
      salesPerformancePercent: 87.8,
      marketingLeads: 324,
      lastUpdated: DateTime.now(),
    );
  }
}