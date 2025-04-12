import 'package:fl_chart/fl_chart.dart';

class AgentAnalysisData {
  final double successRate; // Should be 0.0 to 100.0
  final List<FlSpot> overviewTrend;
  final List<double>
      contentAccuracyValues; // List of percentage values for the bars
  final double AiTaskGenerationSuccessRate; // Should be 0.0 to 100.0
  final int activeTasks;
  final int tasksCompleted;

  final int tasksCreated;
  final int tasksAccepted;
  final int tasksRejected;

  AgentAnalysisData({
    this.successRate = 0.0,
    this.activeTasks = 0,
    this.tasksCreated = 0,
    this.tasksAccepted = 0,
    this.tasksRejected = 0,
    this.tasksCompleted = 0,
    this.overviewTrend = const [],
    this.contentAccuracyValues = const [],
    this.AiTaskGenerationSuccessRate = 0.0,
  });

  /// Creates an AgentAnalysisData from a Map
  factory AgentAnalysisData.fromMap(Map<String, dynamic> map) {
    // Helper to safely get list of doubles
    List<double> _getDoubleList(dynamic list) {
      if (list is List) {
        return list.map((e) => (e as num?)?.toDouble() ?? 0.0).toList();
      }
      return [];
    }

    // Helper to safely get list of FlSpot
    List<FlSpot> _getSpotList(dynamic list) {
      if (list is List) {
        return list.asMap().entries.map((entry) {
          double y = (entry.value as num?)?.toDouble() ?? 0.0;
          return FlSpot(entry.key.toDouble(), y);
        }).toList();
      }
      return [];
    }

    return AgentAnalysisData(
      successRate: (map['successRate'] as num?)?.toDouble() ?? 0.0,
      activeTasks: (map['activeTasks'] as num?)?.toInt() ?? 0,
      tasksCreated: (map['tasksCreated'] as num?)?.toInt() ?? 0,
      tasksAccepted: (map['tasksAccepted'] as num?)?.toInt() ?? 0,
      tasksRejected: (map['tasksRejected'] as num?)?.toInt() ?? 0,
      tasksCompleted: (map['tasksCompleted'] as num?)?.toInt() ?? 0,
      overviewTrend: _getSpotList(map['overviewTrend']),
      contentAccuracyValues: _getDoubleList(map['contentAccuracyValues']),
      AiTaskGenerationSuccessRate:
          (map['AiTaskGenerationSuccessRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EmailAnalysisData extends AgentAnalysisData {
  final int totalEmailsReceived;
  final int totalEmailsSent;

  final int totalDraftsCreated;
  final int totalDraftsAccepted;
  final int totalDraftsRejected;

  final int activeDrafts;
  final int activeEmails;

  final double draftSuccessRate; // Should be 0.0 to 100.0
  final double writingStyleSuccessRate; // Should be 0.0 to 100.0
  final double contentAccuracySuccessRate; // Should be 0.0 to 100.0

  EmailAnalysisData({
    this.activeDrafts = 0,
    this.activeEmails = 0,
    this.totalEmailsReceived = 0,
    this.totalEmailsSent = 0,
    this.totalDraftsCreated = 0,
    this.totalDraftsAccepted = 0,
    this.totalDraftsRejected = 0,
    this.contentAccuracySuccessRate = 0.0,
    this.draftSuccessRate = 0.0,
    this.writingStyleSuccessRate = 0.0,

    // Pass through to parent class
    super.successRate = 0.0,
    super.activeTasks = 0,
    super.tasksCreated = 0,
    super.tasksAccepted = 0,
    super.tasksRejected = 0,
    super.tasksCompleted = 0,
    super.overviewTrend = const [],
    super.contentAccuracyValues = const [],
    super.AiTaskGenerationSuccessRate = 0.0,
  });

  /// Creates an EmailAnalysisData from a Map
  factory EmailAnalysisData.fromMap(Map<String, dynamic> map) {
    // First parse the AgentAnalysisData properties
    final agentData = AgentAnalysisData.fromMap(map);

    return EmailAnalysisData(
      // Email-specific properties
      totalEmailsReceived: (map['totalEmailsReceived'] as num?)?.toInt() ?? 0,
      totalEmailsSent: (map['totalEmailsSent'] as num?)?.toInt() ?? 0,
      totalDraftsCreated: (map['totalDraftsCreated'] as num?)?.toInt() ?? 0,
      totalDraftsAccepted: (map['totalDraftsAccepted'] as num?)?.toInt() ?? 0,
      totalDraftsRejected: (map['totalDraftsRejected'] as num?)?.toInt() ?? 0,
      activeDrafts: (map['activeDrafts'] as num?)?.toInt() ?? 0,
      activeEmails: (map['activeEmails'] as num?)?.toInt() ?? 0,
      draftSuccessRate: (map['draftSuccessRate'] as num?)?.toDouble() ?? 0.0,
      writingStyleSuccessRate:
          (map['writingStyleSuccessRate'] as num?)?.toDouble() ?? 0.0,
      contentAccuracySuccessRate:
          (map['contentAccuracySuccessRate'] as num?)?.toDouble() ?? 0.0,

      // Parent class properties
      successRate: agentData.successRate,
      activeTasks: agentData.activeTasks,
      tasksCreated: agentData.tasksCreated,
      tasksAccepted: agentData.tasksAccepted,
      tasksRejected: agentData.tasksRejected,
      tasksCompleted: agentData.tasksCompleted,
      overviewTrend: agentData.overviewTrend,
      contentAccuracyValues: agentData.contentAccuracyValues,
      AiTaskGenerationSuccessRate: agentData.AiTaskGenerationSuccessRate,
    );
  }
}
