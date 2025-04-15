import 'package:flutter/foundation.dart';
import '../models/dashboard_summary.dart';
import '../../../core/services/firestore_service.dart';

/// Provider for dashboard summary data
class DashboardSummaryProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  DashboardSummary _summaryData = DashboardSummary.empty();
  bool _isLoading = false;
  String? _error;

  DashboardSummary get summaryData => _summaryData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DashboardSummaryProvider() {
    fetchSummaryData();
  }

  Future<void> fetchSummaryData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For development, we'll use sample data if Firestore fetch fails
      try {
        _summaryData = await _firestoreService.getDashboardSummary();
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
