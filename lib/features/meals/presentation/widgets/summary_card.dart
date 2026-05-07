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
    double percent = (current / goal).clamp(0.0, 1.0);
    
    return Card(
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
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
                color: color,
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
              percent: percent,
              backgroundColor: color.withOpacity(0.1),
              progressColor: color,
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
}
