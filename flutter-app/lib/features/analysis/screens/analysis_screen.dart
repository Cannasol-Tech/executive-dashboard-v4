import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../../core/providers/analysis_data_provider.dart';
import '../../../models/analysis_data.dart';
import '../widgets/content_accuracy_chart.dart';
import '../widgets/radial_progress_chart.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  static const String routeName = '/analysis';

  @override
  Widget build(BuildContext context) {
    final analysisProvider = Provider.of<AnalysisDataProvider>(context);
    final analysisData = analysisProvider.analysisData;
    final isLoading = analysisProvider.isLoading;
    final error = analysisProvider.error;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ANALYTICS',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Date range selector
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildDateRangeSelector(context),
          ),
          // Animated refresh button
          _buildRefreshButton(context, isLoading, analysisProvider),
        ],
      ),
      body: _buildBody(context, isLoading, error, analysisData, theme),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return PopupMenuButton<String>(
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppTheme.emeraldGleam.withOpacity(0.2)),
          ),
          color: AppTheme.deepOcean,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'Last 7 Days',
              child: _buildPopupMenuItem('Last 7 Days', Icons.calendar_today),
            ),
            PopupMenuItem(
              value: 'Last 30 Days',
              child: _buildPopupMenuItem('Last 30 Days', Icons.date_range),
            ),
            PopupMenuItem(
              value: 'Last Quarter',
              child: _buildPopupMenuItem(
                  'Last Quarter', Icons.calendar_view_month),
            ),
            PopupMenuItem(
              value: 'Last Year',
              child: _buildPopupMenuItem('Last Year', Icons.calendar_view_day),
            ),
            PopupMenuItem(
              value: 'Custom Range',
              child: _buildPopupMenuItem('Custom Range', Icons.calendar_month),
            ),
          ],
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.deepOcean.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.emeraldGleam.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.emeraldGleam.withOpacity(0.05 * value),
                      blurRadius: 8 * value,
                      spreadRadius: 1 * value,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.date_range,
                        size: 16, color: AppTheme.emeraldGleam),
                    const SizedBox(width: 8),
                    Text(
                      'Last 30 Days',
                      style: TextStyle(
                        color: AppTheme.moonlight,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: AppTheme.emeraldGleam),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPopupMenuItem(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.emeraldGleam),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(color: AppTheme.moonlight),
        ),
      ],
    );
  }

  Widget _buildRefreshButton(
      BuildContext context, bool isLoading, AnalysisDataProvider provider) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: isLoading ? 1 : 0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return RotationTransition(
                turns: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: isLoading
                ? const Icon(Icons.sync,
                    key: ValueKey('loading'), color: AppTheme.emeraldGleam)
                : const Icon(Icons.refresh,
                    key: ValueKey('refresh'), color: AppTheme.moonlight),
          ),
          onPressed: isLoading ? null : () => provider.refreshAnalysisData(),
          tooltip: 'Refresh Data',
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, bool isLoading, String? error,
      AnalysisData analysisData, ThemeData theme) {
    if (isLoading && analysisData == AnalysisData.empty()) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.emeraldGleam),
                    strokeWidth: 3,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Analytics Data...',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.moonlight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.deepOcean,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.errorColor.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 4,
                          )
                        ],
                      ),
                      child: const Icon(Icons.error_outline,
                          color: AppTheme.errorColor, size: 48),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Failed to Load Data',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.moonlight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.moonlight.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGleam,
                  foregroundColor: AppTheme.deepOcean,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () =>
                    Provider.of<AnalysisDataProvider>(context, listen: false)
                        .refreshAnalysisData(),
              ),
            ],
          ),
        ),
      );
    }

    // Animation for the content when it appears
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: RefreshIndicator(
        color: AppTheme.emeraldGleam,
        backgroundColor: AppTheme.deepOcean,
        onRefresh: () =>
            Provider.of<AnalysisDataProvider>(context, listen: false)
                .refreshAnalysisData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary header
              _buildSummaryHeader(context, analysisData),
              const SizedBox(height: 30),

              // Overview Section with enhanced visual styling
              _buildSectionCard(
                context,
                title: 'Performance Overview',
                icon: Icons.trending_up,
                color: AppTheme.royalAzure,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetricItem(
                                  context,
                                  'Active Systems',
                                  analysisData.activeSystems.toString(),
                                  Icons.devices,
                                  AppTheme.royalAzure),
                              const SizedBox(height: 16),
                              _buildMetricItem(
                                  context,
                                  'Tasks Completed',
                                  analysisData.tasksCompleted.toString(),
                                  Icons.task_alt,
                                  AppTheme.emeraldGleam),
                              const SizedBox(height: 16),
                              _buildMetricItem(
                                  context,
                                  'Success Rate',
                                  '${analysisData.successRate.toStringAsFixed(0)}%',
                                  Icons.verified,
                                  AppTheme.successEmerald),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.deepOcean.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.royalAzure.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Task Trend',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: AppTheme.moonlight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.royalAzure
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.royalAzure
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '+12% vs Previous',
                                        style: TextStyle(
                                          color: AppTheme.royalAzure,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                AspectRatio(
                                  aspectRatio: 2,
                                  child: _buildEnhancedOverviewChart(
                                      analysisData.overviewTrend),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Success Metrics Section
              Text(
                'Performance Metrics',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.moonlight,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Key performance indicators for AI-generated content',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.moonlight.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Row with enhanced charts
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isWide = constraints.maxWidth > 700;
                  return Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: isWide ? 1 : 0,
                        child: _buildSectionCard(
                          context,
                          title: 'Draft Acceptance',
                          icon: Icons.description,
                          color: AppTheme.emeraldGleam,
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              RadialProgressChart(
                                percentage: analysisData.draftSuccessPercent,
                                label: 'Accepted',
                                progressColor: AppTheme.emeraldGleam,
                                backgroundColor:
                                    AppTheme.deepOcean.withOpacity(0.2),
                              ),
                              const SizedBox(height: 16),
                              _buildMetricRow(
                                  'Total Drafts',
                                  analysisData.emailData?.totalDraftsCreated
                                          .toString() ??
                                      '0'),
                              const SizedBox(height: 8),
                              _buildMetricRow('Accepted',
                                  '${(analysisData.draftSuccessPercent * (analysisData.emailData?.totalDraftsCreated ?? 0) / 100).round()}'),
                              const SizedBox(height: 8),
                              _buildMetricRow('Rejected',
                                  '${(analysisData.totalDraftsCreated - (analysisData.draftSuccessPercent * analysisData.totalDraftsCreated / 100).round())}'),
                            ],
                          ),
                        ),
                      ),
                      if (isWide) const SizedBox(width: 20),
                      if (!isWide) const SizedBox(height: 20),
                      Flexible(
                        flex: isWide ? 1 : 0,
                        child: _buildSectionCard(
                          context,
                          title: 'Writing Style',
                          icon: Icons.format_quote,
                          color: AppTheme.infoSapphire,
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              RadialProgressChart(
                                percentage: analysisData.writingStylePercent,
                                label: 'Match Score',
                                progressColor: AppTheme.infoSapphire,
                                backgroundColor:
                                    AppTheme.deepOcean.withOpacity(0.2),
                              ),
                              const SizedBox(height: 16),
                              _buildMetricRow('Tone Accuracy',
                                  '${analysisData.writingStylePercent.toStringAsFixed(1)}%'),
                              const SizedBox(height: 8),
                              _buildMetricRow('Brand Voice', 'Excellent'),
                              const SizedBox(height: 8),
                              _buildMetricRow('Formality', 'Professional'),
                            ],
                          ),
                        ),
                      ),
                      if (isWide) const SizedBox(width: 20),
                      if (!isWide) const SizedBox(height: 20),
                      Flexible(
                        flex: isWide ? 1 : 0,
                        child: _buildSectionCard(
                          context,
                          title: 'Content Accuracy',
                          icon: Icons.fact_check,
                          color: AppTheme.warningAmber,
                          child: ContentAccuracyChart(
                            accuracyData: analysisData.contentAccuracyValues,
                            chartColor: AppTheme.warningAmber,
                            backgroundColor:
                                AppTheme.deepOcean.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, AnalysisData data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.deepOcean,
            AppTheme.deepOcean.withOpacity(0.8),
            Color.lerp(AppTheme.deepOcean, AppTheme.emeraldGleam, 0.3)!
                .withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.elevation2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics Summary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.moonlight,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: data.successRate >= 75
                      ? AppTheme.successEmerald.withOpacity(0.2)
                      : AppTheme.warningAmber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      data.successRate >= 75
                          ? Icons.trending_up
                          : Icons.trending_flat,
                      color: data.successRate >= 75
                          ? AppTheme.successEmerald
                          : AppTheme.warningAmber,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      data.successRate >= 75
                          ? 'Strong Performance'
                          : 'Moderate Performance',
                      style: TextStyle(
                        color: data.successRate >= 75
                            ? AppTheme.successEmerald
                            : AppTheme.warningAmber,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSummaryMetric(
                'Overall Rating',
                '${data.successRate.toStringAsFixed(0)}%',
                Icons.star_rate_rounded,
                AppTheme.emeraldGleam,
              ),
              const SizedBox(width: 24),
              _buildSummaryMetric(
                'AI Tasks',
                data.totalDraftsCreated.toString(),
                Icons.checklist_rounded,
                AppTheme.infoSapphire,
              ),
              const SizedBox(width: 24),
              _buildSummaryMetric(
                'Customer Sat.',
                '${(data.successRate * 0.98).toStringAsFixed(0)}%',
                Icons.sentiment_satisfied_alt,
                AppTheme.warningAmber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.moonlight.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.moonlight,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedOverviewChart(List<FlSpot> spots) {
    // Find max Y value for dynamic range, add some padding
    double maxY =
        spots.fold<double>(0, (max, spot) => spot.y > max ? spot.y : max) + 2;
    // Ensure maxY is at least a minimum value (e.g., 10) to avoid flat lines for low values
    maxY = maxY < 10 ? 10 : maxY;
    // Find max X value for dynamic range
    double maxX = spots.isNotEmpty ? spots.last.x : 0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.moonlight.withOpacity(0.1),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: maxX / 4,
              getTitlesWidget: (value, meta) {
                // Convert to day names or week numbers based on range
                String text = 'W${(value / 7).ceil()}';
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: AppTheme.moonlight.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: AppTheme.moonlight.withOpacity(0.7),
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppTheme.deepOcean.withOpacity(0.8),
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  'Day ${barSpot.x.toInt()}: ${barSpot.y.toInt()} tasks',
                  TextStyle(color: AppTheme.moonlight),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((spotIndex) {
              return TouchedSpotIndicatorData(
                FlLine(color: AppTheme.royalAzure, strokeWidth: 2),
                FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: AppTheme.moonlight,
                      strokeWidth: 2,
                      strokeColor: AppTheme.royalAzure,
                    );
                  },
                ),
              );
            }).toList();
          },
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots.isNotEmpty ? spots : [const FlSpot(0, 0)],
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppTheme.royalAzure,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.royalAzure.withOpacity(0.2),
              gradient: LinearGradient(
                colors: [
                  AppTheme.royalAzure.withOpacity(0.4),
                  AppTheme.royalAzure.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            shadow: const Shadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced section card with icon and color
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.deepOcean,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppTheme.obsidian.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header with animated indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.moonlight,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Animated divider
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.3, end: 0.7),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      color.withOpacity(value),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 6,
                    )
                  ],
                ),
              );
            },
          ),

          // Card content
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  // Enhanced metric items with icons and hover effect
  Widget _buildMetricItem(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.deepOcean.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.moonlight.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.moonlight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for metric rows on radial progress charts
  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.moonlight.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.moonlight,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
