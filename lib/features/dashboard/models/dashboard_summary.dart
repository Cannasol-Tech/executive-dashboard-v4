import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents summary data potentially used across the dashboard,
/// including values for the main grid cards.
class DashboardSummary {
  // Example fields - adjust based on actual data needs
  final double revenueCurrent;
  final double revenueTarget;
  final double revenueGrowth;
  final int customerCount;
  final double customerGrowth;
  final int activeOperations;
  final double salesPerformancePercent;
  final int marketingLeads;
  final DateTime lastUpdated;

  DashboardSummary({
    this.revenueCurrent = 0.0,
    this.revenueTarget = 0.0,
    this.revenueGrowth = 0.0,
    this.customerCount = 0,
    this.customerGrowth = 0.0,
    this.activeOperations = 0,
    this.salesPerformancePercent = 0.0,
    this.marketingLeads = 0,
    DateTime? lastUpdated,
  }) : this.lastUpdated = lastUpdated ?? DateTime.now();

  /// Creates DashboardSummary from a Firestore DocumentSnapshot.
  factory DashboardSummary.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    // Helper function to safely get double values
    double _getDouble(dynamic value) => (value as num?)?.toDouble() ?? 0.0;
    // Helper function to safely get int values
    int _getInt(dynamic value) => (value as num?)?.toInt() ?? 0;
    // Helper function to safely get DateTime values
    DateTime _getDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      return DateTime.now();
    }

    return DashboardSummary(
      revenueCurrent: _getDouble(data['revenueCurrent']),
      revenueTarget: _getDouble(data['revenueTarget']),
      revenueGrowth: _getDouble(data['revenueGrowth']),
      customerCount: _getInt(data['customerCount']),
      customerGrowth: _getDouble(data['customerGrowth']),
      activeOperations: _getInt(data['activeOperations']),
      salesPerformancePercent: _getDouble(data['salesPerformancePercent']),
      marketingLeads: _getInt(data['marketingLeads']),
      lastUpdated: _getDateTime(data['lastUpdated']),
    );
  }

  /// Alias for fromFirestore for consistency with other models
  factory DashboardSummary.fromDocument(DocumentSnapshot doc) => 
      DashboardSummary.fromFirestore(doc);

  /// Creates a default/empty DashboardSummary object.
  factory DashboardSummary.empty() {
    return DashboardSummary();
  }
} 