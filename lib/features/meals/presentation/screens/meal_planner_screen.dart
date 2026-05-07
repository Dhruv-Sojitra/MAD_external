import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealp/core/constants/colors.dart';
import 'package:mealp/features/meals/providers/meal_provider.dart';
import 'package:mealp/features/meals/domain/models/meal.dart';
import 'add_meal_screen.dart';

class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(dailyMealsProvider(_selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildDateSelector(),
        ),
      ),
      body: meals.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: MealType.values.length,
              itemBuilder: (context, index) {
                final type = MealType.values[index];
                final typeMeals = meals.where((m) => m.type == type).toList();
                return _buildMealTypeSection(type, typeMeals);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddMeal(),
        label: const Text('Add Meal'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          Text(
            DateFormat('EEEE, MMM d').format(_selectedDate),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No meals planned for this day',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToAddMeal(),
            child: const Text('Plan a Meal'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSection(MealType type, List<Meal> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _getMealColor(type),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                type.name.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getMealColor(type),
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                '${meals.fold(0.0, (sum, m) => sum + m.calories).toInt()} Kcal',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (meals.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 16),
            child: Text(
              'No ${type.name} added yet',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          )
        else
          ...meals.map((meal) => _buildMealCard(meal)),
      ],
    );
  }

  Widget _buildMealCard(Meal meal) {
    return Dismissible(
      key: Key(meal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(dailyMealsProvider(_selectedDate).notifier).deleteMeal(meal.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(meal.foodName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${meal.quantity.toInt()}g • P: ${meal.protein.toInt()}g • C: ${meal.carbs.toInt()}g • F: ${meal.fats.toInt()}g'),
          trailing: Text(
            '${meal.calories.toInt()}\nKcal',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
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

  void _navigateToAddMeal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMealScreen(selectedDate: _selectedDate),
      ),
    );
  }
}
