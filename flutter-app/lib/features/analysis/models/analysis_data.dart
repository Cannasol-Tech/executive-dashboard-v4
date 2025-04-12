// NOTE: Ensure that the 'cloud_firestore' package is correctly added in your pubspec.yaml.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:executive_dashboard/features/email/email_analysis_data.dart';
import 'package:fl_chart/fl_chart.dart';

/// Represents the data structure for the Analysis screen fetched from Firestore.
class AnalysisData {
  final int activeUsers;
  final int activeSystems;
  final EmailAnalysisData? emailData;
  final List<FlSpot> overviewTrend;
  final double draftSuccessPercent;
  final double writingStylePercent;
  final List<double> contentAccuracyValues;

  int? get tasksCompleted => emailData?.tasksCompleted;

  /// Get the total drafts created from email data, or 0 if no email data is available
  int get totalDraftsCreated => emailData?.totalDraftsCreated ?? 0;

  /// Get the success rate based on draft success percentage, or 0 if not set
  double get successRate => draftSuccessPercent;

  /// Get the combined tasks completed count which includes email tasks
  int get combinedTasksCompleted => emailData?.tasksCompleted ?? 0;

  AnalysisData({
    this.activeUsers = 0,
    this.activeSystems = 0,
    this.emailData,
    this.overviewTrend = const [],
    this.draftSuccessPercent = 0.0,
    this.writingStylePercent = 0.0,
    this.contentAccuracyValues = const [],
  });

  /// Creates AnalysisData from a Firestore DocumentSnapshot.
  factory AnalysisData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    // Helper to safely get list of doubles
    List<double> _getDoubleList(dynamic list) {
      if (list is List) {
        return list.map((e) => (e as num?)?.toDouble() ?? 0.0).toList();
      }
      return [];
    }

    // Helper to safely get list of FlSpot (assuming stored as maps)
    List<FlSpot> _getSpotList(dynamic list) {
      if (list is List) {
        return list.asMap().entries.map((entry) {
          // Simple index-based x-value, assuming data[index] is y-value
          double y = (entry.value as num?)?.toDouble() ?? 0.0;
          return FlSpot(entry.key.toDouble(), y);
          // If storing richer point data (e.g., maps like {'x': 1, 'y': 5}):
          // if (item is Map) {
          //   double x = (item['x'] as num?)?.toDouble() ?? 0.0;
          //   double y = (item['y'] as num?)?.toDouble() ?? 0.0;
          //   return FlSpot(x, y);
          // }
          // return FlSpot(0, 0); // Default fallback
        }).toList();
      }
      return [];
    }

    // Parse email data if available
    EmailAnalysisData? emailAnalysisData;
    if (data['emailData'] is Map<String, dynamic>) {
      emailAnalysisData = EmailAnalysisData.fromMap(
        data['emailData'] as Map<String, dynamic>,
      );
    }

    return AnalysisData(
      activeUsers: (data['activeUsers'] as num?)?.toInt() ?? 0,
      activeSystems: (data['activeSystems'] as num?)?.toInt() ?? 0,
      emailData: emailAnalysisData,
      overviewTrend: _getSpotList(data['overviewTrend']),
      draftSuccessPercent:
          (data['draftSuccessPercent'] as num?)?.toDouble() ?? 0.0,
      writingStylePercent:
          (data['writingStylePercent'] as num?)?.toDouble() ?? 0.0,
      contentAccuracyValues: _getDoubleList(data['contentAccuracyValues']),
    );
  }

  /// Creates a default/empty AnalysisData object.
  factory AnalysisData.empty() {
    return AnalysisData();
  }
}
