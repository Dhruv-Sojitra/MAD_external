import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:mealp/core/constants/colors.dart';
import 'package:mealp/features/meals/providers/meal_provider.dart';
import 'package:mealp/features/meals/presentation/widgets/summary_card.dart';
import 'package:mealp/features/meals/presentation/widgets/macro_chart.dart';
import 'package:mealp/features/meals/domain/models/meal.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final meals = ref.watch(dailyMealsProvider(today));
    final calorieGoal = ref.watch(calorieGoalProvider);
    final macrosGoal = ref.watch(macrosGoalProvider);

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (var meal in meals) {
      totalCalories += meal.calories;
      totalProtein += meal.protein;
      totalCarbs += meal.carbs;
      totalFats += meal.fats;
    }

    double caloriePercent = (totalCalories / calorieGoal).clamp(0.0, 1.0);
    double remainingCalories = calorieGoal - totalCalories;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'My Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Calorie Progress Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircularPercentIndicator(
                          radius: 80.0,
                          lineWidth: 12.0,
                          animation: true,
                          percent: caloriePercent,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${totalCalories.toInt()}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Kcal Eaten'),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: AppColors.primary,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Goal', '${calorieGoal.toInt()}'),
                            _buildStatItem('Remaining', '${remainingCalories.toInt()}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Macros Row
                Row(
                  children: [
                    Expanded(
                      child: MacroSummaryCard(
                        label: 'Protein',
                        current: totalProtein,
                        goal: macrosGoal['protein']!,
                        color: AppColors.protein,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MacroSummaryCard(
                        label: 'Carbs',
                        current: totalCarbs,
                        goal: macrosGoal['carbs']!,
                        color: AppColors.carbs,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MacroSummaryCard(
                        label: 'Fats',
                        current: totalFats,
                        goal: macrosGoal['fats']!,
                        color: AppColors.fats,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Recent Meals Header
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Meals',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'View All',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (meals.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text('No meals recorded today'),
                    ),
                  )
                else
                  ...meals.take(3).map((meal) => _buildMealItem(meal)),
                
                const SizedBox(height: 20),
                const MacroChart(),
                const SizedBox(height: 80), // Space for bottom nav
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add quick meal logic
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMealItem(Meal meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getMealColor(meal.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_getMealIcon(meal.type), color: _getMealColor(meal.type)),
        ),
        title: Text(meal.foodName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${meal.quantity.toInt()}g • ${meal.calories.toInt()} Kcal'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Color _getMealColor(MealType type) {
    switch (type) {
      case MealType.breakfast: return AppColors.breakfast;
      case MealType.lunch: return AppColors.lunch;
      case MealType.dinner: return AppColors.dinner;
      case MealType.snacks: return AppColors.snacks;
    }
  }

  IconData _getMealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast: return Icons.wb_sunny_outlined;
      case MealType.lunch: return Icons.light_mode_outlined;
      case MealType.dinner: return Icons.nightlight_outlined;
      case MealType.snacks: return Icons.bakery_dining_outlined;
    }
  }
}
