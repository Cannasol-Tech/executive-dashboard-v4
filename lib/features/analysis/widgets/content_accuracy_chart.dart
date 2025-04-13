import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ContentAccuracyChart extends StatelessWidget {
  final List<double> accuracyData; // Accept data as parameter
  final List<String> labels; // Keep labels or make them dynamic too?

  const ContentAccuracyChart({
    super.key,
    this.accuracyData = const [], // Default to empty list
    // For now, keep labels static as per original design
    this.labels = const ['0%', '20%', '40%', '60%', '80%'],
    required Color chartColor,
    required Color backgroundColor,
  });

  // Placeholder data - replace with actual data source
  // final List<double> accuracyData = const [15, 30, 45, 55, 65]; // Removed hardcoded data
  // final List<String> labels = const ['0%', '20%', '40%', '60%', '80%']; // Removed hardcoded data

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6, // Adjust aspect ratio as needed
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100, // Assuming percentage max
            barTouchData: BarTouchData(
                enabled: false), // Disable touch interactions for now
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: _bottomTitles,
                  reservedSize: 32,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 20,
                  getTitlesWidget: _leftTitles,
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: false, // Hide border lines
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.white24,
                  strokeWidth: 1,
                );
              },
            ),
            barGroups: _generateBarGroups(),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    // Use the passed-in accuracyData
    return List.generate(accuracyData.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: accuracyData[index],
            color: Colors.teal, // Match the image color
            width: 16, // Adjust bar width
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        // showingTooltipIndicators: [0], // Optional: Show tooltip on specific bars
      );
    });
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    final index = value.toInt();
    String text;
    // Use the passed-in labels list
    if (index >= 0 && index < labels.length) {
      text = labels[index];
    } else {
      text = '';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, // Space between chart and title
      child: Text(text,
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container(); // Avoid drawing title at the top
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(
        '${value.toInt()}%', // Display percentage
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}
