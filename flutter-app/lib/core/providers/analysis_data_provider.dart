import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/analysis_data.dart';
import '../../services/firestore_service.dart';

class AnalysisDataProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  AnalysisData _analysisData = AnalysisData.empty();
  StreamSubscription? _analysisStreamSubscription;
  bool _isLoading = false;
  String? _error;

  AnalysisData get analysisData => _analysisData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AnalysisDataProvider() {
    _listenToAnalysisData();
  }

  void _listenToAnalysisData() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _analysisStreamSubscription?.cancel(); // Cancel previous subscription if exists
    _analysisStreamSubscription = _firestoreService.streamAnalysisData().listen(
      (data) {
        _analysisData = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        print("Error in AnalysisDataProvider stream: $error");
        _isLoading = false;
        _error = "Failed to load analysis data. Please try again.";
        _analysisData = AnalysisData.empty(); // Reset data on error
        notifyListeners();
      },
      onDone: () {
        // Stream closed (might happen, e.g., if Firestore rules deny access later)
        _isLoading = false;
        if (_analysisData == AnalysisData.empty()) {
             _error = "Data stream closed unexpectedly.";
        }
        notifyListeners();
      }
    );
  }

  // Optional: Method to force a refresh (useful for pull-to-refresh)
  Future<void> refreshAnalysisData() async {
     // Although we use a stream, a manual fetch might be desired sometimes
     // For now, just ensure the stream listener is active
     if (_analysisStreamSubscription == null || _analysisStreamSubscription!.isPaused) {
       _listenToAnalysisData();
     }
     // If you wanted a one-time fetch instead of relying purely on the stream:
     /*
     _isLoading = true;
     _error = null;
     notifyListeners();
     try {
       _analysisData = await _firestoreService.getAnalysisData();
     } catch (e) {
       _error = "Failed to refresh analysis data.";
     } finally {
       _isLoading = false;
       notifyListeners();
     }
     */
  }

  @override
  void dispose() {
    _analysisStreamSubscription?.cancel();
    super.dispose();
  }
} 