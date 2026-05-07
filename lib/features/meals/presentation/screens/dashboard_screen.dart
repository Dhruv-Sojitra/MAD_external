import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mealp/core/constants/colors.dart';
import 'package:mealp/features/meals/providers/meal_provider.dart';
import 'package:mealp/features/meals/presentation/widgets/summary_card.dart';
import 'package:mealp/features/meals/presentation/widgets/macro_chart.dart';
import 'package:mealp/features/meals/presentation/widgets/meal_card.dart';
import 'package:mealp/features/meals/domain/models/meal.dart';
import 'add_meal_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final totals = ref.watch(nutritionTotalsProvider(today));
    final stats = ref.watch(mealStatsProvider(today));
    final calorieGoal = ref.watch(calorieGoalProvider);
    final remainingCalories = ref.watch(remainingCaloriesProvider(today));
    final progress = ref.watch(nutritionProgressProvider(today));
    final macrosGoal = ref.watch(macrosGoalProvider);
    final meals = ref.watch(dailyMealsProvider(today));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Wellness Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Opacity(
                    opacity: 0.2,
                    child: Icon(Icons.fitness_center, size: 100, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Main Calorie Card
                _buildMainCalorieCard(totals, calorieGoal, remainingCalories, progress, stats),
                const SizedBox(height: 20),
                
                // Macros Row
                Row(
                  children: [
                    Expanded(
                      child: MacroSummaryCard(
                        label: 'Protein',
                        current: totals['protein']!,
                        goal: macrosGoal['protein']!,
                        color: AppColors.protein,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MacroSummaryCard(
                        label: 'Carbs',
                        current: totals['carbs']!,
                        goal: macrosGoal['carbs']!,
                        color: AppColors.carbs,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MacroSummaryCard(
                        label: 'Fats',
                        current: totals['fats']!,
                        goal: macrosGoal['fats']!,
                        color: AppColors.fats,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 24),
                _buildMealStatusSummary(stats),
                const SizedBox(height: 24),

                const Text(
                  'Quick View',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (meals.isEmpty)
                  _buildEmptyState()
                else
                  ...meals.take(3).map((meal) => _buildMealItem(meal, ref, context)),
                
                const SizedBox(height: 20),
                const MacroChart(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCalorieCard(Map<String, double> totals, double goal, double remaining, double progress, Map<String, int> stats) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.primary.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Goal', style: TextStyle(color: AppColors.textSecondary)),
                    Text('${goal.toInt()} kcal', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                CircularPercentIndicator(
                  radius: 50.0,
                  lineWidth: 8.0,
                  animation: true,
                  percent: progress,
                  center: Text(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: _getProgressColor(progress),
                  backgroundColor: AppColors.primary.withOpacity(0.05),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn('Consumed', '${totals['calories']!.toInt()}', AppColors.primary),
                _buildStatColumn('Remaining', '${remaining.toInt()}', remaining > 0 ? Colors.green : Colors.red),
                _buildStatColumn('Completed', '${stats['completed']}', AppColors.protein),
              ],
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildMealStatusSummary(Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.assignment_turned_in, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            '${stats['completed']} of ${stats['completed']! + stats['pending']!} meals completed today',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildMealItem(Meal meal, WidgetRef ref, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MealCard(
        meal: meal,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMealScreen(selectedDate: meal.date, mealToEdit: meal),
            ),
          );
        },
        onEdit: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMealScreen(selectedDate: meal.date, mealToEdit: meal),
            ),
          );
        },
      ),
    ).animate().fadeIn().slideX();
  }

  void _showQuickActions(BuildContext context, Meal meal, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit Meal'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddMealScreen(selectedDate: meal.date, mealToEdit: meal)));
              },
            ),
            ListTile(
              leading: Icon(meal.isCompleted ? Icons.undo : Icons.check_circle, color: Colors.green),
              title: Text(meal.isCompleted ? 'Mark as Pending' : 'Mark as Completed'),
              onTap: () {
                ref.read(dailyMealsProvider(meal.date).notifier).toggleMealCompletion(meal.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Meal', style: TextStyle(color: Colors.red)),
              onTap: () {
                ref.read(dailyMealsProvider(meal.date).notifier).deleteMeal(meal.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Text('No meals recorded today', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.8) return AppColors.primary;
    if (progress <= 1.0) return Colors.orange;
    return Colors.red;
  }
}
