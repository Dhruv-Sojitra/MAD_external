import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class MacroSummaryCard extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;

  const MacroSummaryCard({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    double percent = (current / goal).clamp(0.0, 1.2); // Allow slight overflow for color logic
    Color statusColor = _getStatusColor(percent);
    
    return Card(
      elevation: 0,
      color: statusColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${current.toInt()}g',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearPercentIndicator(
              lineHeight: 4.0,
              percent: percent.clamp(0.0, 1.0),
              backgroundColor: statusColor.withOpacity(0.1),
              progressColor: statusColor,
              padding: EdgeInsets.zero,
              barRadius: const Radius.circular(2),
            ),
            const SizedBox(height: 4),
            Text(
              'Goal: ${goal.toInt()}g',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(double percent) {
    if (percent < 0.8) return color; // Default color for healthy
    if (percent <= 1.0) return Colors.orange; // Near limit
    return Colors.red; // Exceeded
  }
}
