import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealp/core/constants/colors.dart';
import 'package:mealp/features/meals/providers/meal_provider.dart';

class MacroChart extends ConsumerWidget {
  const MacroChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final totals = ref.watch(nutritionTotalsProvider(today));
    
    final protein = totals['protein'] ?? 0;
    final carbs = totals['carbs'] ?? 0;
    final fats = totals['fats'] ?? 0;
    final total = protein + carbs + fats;

    if (total == 0) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('No macro data available', style: TextStyle(color: Colors.grey)),
                Text('Complete meals to see distribution', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    final proteinPct = (protein / total) * 100;
    final carbsPct = (carbs / total) * 100;
    final fatsPct = (fats / total) * 100;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Macro Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: proteinPct,
                      title: '${proteinPct.toInt()}%',
                      color: AppColors.protein,
                      radius: 50,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    PieChartSectionData(
                      value: carbsPct,
                      title: '${carbsPct.toInt()}%',
                      color: AppColors.carbs,
                      radius: 50,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    PieChartSectionData(
                      value: fatsPct,
                      title: '${fatsPct.toInt()}%',
                      color: AppColors.fats,
                      radius: 50,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                swapAnimationDuration: const Duration(milliseconds: 400),
                swapAnimationCurve: Curves.easeInOut,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Protein', AppColors.protein, protein),
                const SizedBox(width: 16),
                _buildLegendItem('Carbs', AppColors.carbs, carbs),
                const SizedBox(width: 16),
                _buildLegendItem('Fats', AppColors.fats, fats),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, double grams) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        Text('${grams.toInt()}g', style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
