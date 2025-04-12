import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/analysis/models/analysis_data.dart';
import '../../features/dashboard/models/dashboard_summary.dart'; // Import the new model
// Import other models as needed

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Analysis Data ---

  /// Fetches the single AnalysisData document.
  /// Assumes data is stored in a specific document, e.g., 'dashboard/analysis'
  Future<AnalysisData> getAnalysisData() async {
    try {
      // TODO: Make the document path configurable if needed
      DocumentSnapshot doc =
          await _db.collection('dashboard').doc('analysis').get();
      if (doc.exists) {
        return AnalysisData.fromFirestore(doc);
      } else {
        print('Analysis document not found, returning empty data.');
        return AnalysisData.empty();
      }
    } catch (e) {
      print('Error fetching analysis data: $e');
      // Consider more robust error handling/logging
      return AnalysisData.empty(); // Return empty data on error
    }
  }

  /// Returns a stream of the AnalysisData document for real-time updates.
  Stream<AnalysisData> streamAnalysisData() {
    // TODO: Make the document path configurable if needed
    return _db
        .collection('dashboard')
        .doc('analysis')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        try {
          return AnalysisData.fromFirestore(snapshot);
        } catch (e) {
          print('Error mapping analysis data snapshot: $e');
          return AnalysisData.empty(); // Return empty on mapping error
        }
      } else {
        return AnalysisData.empty();
      }
    }).handleError((error) {
      print('Error in analysis data stream: $error');
      // Optionally, yield a specific error state or just empty data
      return AnalysisData.empty();
    });
  }

  // --- Dashboard Summary Data ---

  /// Fetches the single DashboardSummary document.
  /// Assumes data is stored in 'dashboard/summary'
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      DocumentSnapshot doc =
          await _db.collection('dashboard').doc('summary').get();
      if (doc.exists) {
        return DashboardSummary.fromFirestore(doc);
      } else {
        print('Dashboard summary document not found, returning empty data.');
        return DashboardSummary.empty();
      }
    } catch (e) {
      print('Error fetching dashboard summary: $e');
      return DashboardSummary.empty();
    }
  }

  /// Returns a stream of the DashboardSummary document.
  Stream<DashboardSummary> streamDashboardSummary() {
    return _db
        .collection('dashboard')
        .doc('summary')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        try {
          return DashboardSummary.fromFirestore(snapshot);
        } catch (e) {
          print('Error mapping dashboard summary snapshot: $e');
          return DashboardSummary.empty();
        }
      } else {
        return DashboardSummary.empty();
      }
    }).handleError((error) {
      print('Error in dashboard summary stream: $error');
      return DashboardSummary.empty();
    });
  }

  // --- Other Data Fetching Methods ---
  // TODO: Add methods for fetching data for the main dashboard grid, user profile, etc.

  // Example for a collection (if needed later):
  // Stream<List<YourModel>> streamYourCollection() {
  //   return _db.collection('yourCollection').snapshots().map((snapshot) =>
  //     snapshot.docs.map((doc) => YourModel.fromFirestore(doc)).toList()
  //   );
  // }
}
