import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mealp/core/constants/colors.dart';
import 'package:mealp/features/meals/providers/meal_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final analytics = ref.watch(analyticsProvider(today));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(analytics),
            const SizedBox(height: 32),
            const Text(
              'Weekly Calorie Adherence',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildWeeklyChart(),
            const SizedBox(height: 40),
            const Text(
              'Meal Completion Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTrendsChart(analytics['completionRate'] * 100),
            const SizedBox(height: 40),
            _buildInsightsCard(analytics),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> analytics) {
    return Row(
      children: [
        _buildStatBox('Adherence', '${(analytics['completionRate'] * 100).toInt()}%', Colors.blue),
        const SizedBox(width: 12),
        _buildStatBox('Completed', '${analytics['mealCount']}', Colors.green),
        const SizedBox(width: 12),
        _buildStatBox('Kcal Total', '${analytics['totalCalories'].toInt()}', AppColors.primary),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 3000,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return Text(days[value.toInt() % 7], style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeGroupData(0, 1800, Colors.green),
            _makeGroupData(1, 2100, Colors.green),
            _makeGroupData(2, 1600, Colors.orange),
            _makeGroupData(3, 2400, Colors.green),
            _makeGroupData(4, 1900, Colors.green),
            _makeGroupData(5, 2800, Colors.red),
            _makeGroupData(6, 2200, Colors.green),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color.withOpacity(0.8),
          width: 16,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildTrendsChart(double rate) {
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 60),
                const FlSpot(1, 75),
                const FlSpot(2, 65),
                const FlSpot(3, 85),
                const FlSpot(4, 90),
                FlSpot(5, rate),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(Map<String, dynamic> analytics) {
    final bool isHighlyAdherent = analytics['completionRate'] > 0.8;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlyAdherent ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isHighlyAdherent ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isHighlyAdherent ? Icons.star : Icons.info_outline, color: isHighlyAdherent ? Colors.green : Colors.blue),
              const SizedBox(width: 12),
              Text(
                isHighlyAdherent ? 'Excellent Adherence!' : 'Keep Going!',
                style: TextStyle(fontWeight: FontWeight.bold, color: isHighlyAdherent ? Colors.green.shade800 : Colors.blue.shade800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isHighlyAdherent 
              ? 'You have completed over 80% of your planned meals this week. Your consistency is leading to better metabolic health.'
              : 'You have completed ${(analytics['completionRate'] * 100).toInt()}% of your meals. Try to mark more meals as completed to hit your goals.',
            style: TextStyle(color: isHighlyAdherent ? Colors.green.shade700 : Colors.blue.shade700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
