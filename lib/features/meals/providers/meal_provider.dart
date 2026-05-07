import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealp/features/meals/data/meal_repository.dart';
import 'package:mealp/features/meals/domain/models/meal.dart';
import 'package:mealp/features/meals/domain/models/food_item.dart';
import 'package:mealp/core/services/nutrition_engine.dart';

final mealRepositoryProvider = Provider((ref) => MealRepository());

// Helper to normalize dates to midnight
DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

final dailyMealsProvider = StateNotifierProvider.family<DailyMealsNotifier, List<Meal>, DateTime>((ref, date) {
  final repository = ref.watch(mealRepositoryProvider);
  return DailyMealsNotifier(repository, normalizeDate(date));
});

class DailyMealsNotifier extends StateNotifier<List<Meal>> {
  final MealRepository _repository;
  final DateTime _date;

  DailyMealsNotifier(this._repository, this._date) : super([]) {
    _loadMeals();
  }

  void _loadMeals() {
    state = _repository.getMealsByDate(_date);
  }

  Future<void> addMeal(Meal meal) async {
    final normalizedMeal = meal.copyWith(date: normalizeDate(meal.date));
    await _repository.addMeal(normalizedMeal);
    if (normalizeDate(meal.date) == _date) {
      state = [...state, normalizedMeal];
    }
  }

  Future<void> updateMeal(Meal meal) async {
    final normalizedMeal = meal.copyWith(date: normalizeDate(meal.date));
    await _repository.updateMeal(normalizedMeal);
    if (normalizeDate(meal.date) == _date) {
      state = [
        for (final m in state)
          if (m.id == meal.id) normalizedMeal else m
      ];
    } else {
      // If date changed, remove from current state
      state = state.where((m) => m.id != meal.id).toList();
    }
  }

  Future<void> toggleMealCompletion(String id) async {
    // Find index instead of firstWhere to be safe
    final index = state.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final meal = state[index];
    final updatedMeal = meal.copyWith(
      isCompleted: !meal.isCompleted,
      completedAt: !meal.isCompleted ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
    
    // Update state immutably
    final newState = [...state];
    newState[index] = updatedMeal;
    state = newState;
    
    // Persist to local storage
    await _repository.updateMeal(updatedMeal);
  }

  Future<void> deleteMeal(String id) async {
    await _repository.deleteMeal(id);
    state = state.where((m) => m.id != id).toList();
  }
}

// --- Dashboard Providers ---

final nutritionTotalsProvider = Provider.family<Map<String, double>, DateTime>((ref, date) {
  final meals = ref.watch(dailyMealsProvider(normalizeDate(date)));
  return NutritionEngine.calculateTotals(meals);
});

final mealStatsProvider = Provider.family<Map<String, int>, DateTime>((ref, date) {
  final meals = ref.watch(dailyMealsProvider(normalizeDate(date)));
  return NutritionEngine.getCompletionStats(meals);
});

final calorieGoalProvider = StateProvider<double>((ref) {
  return ref.watch(mealRepositoryProvider).getDailyCalorieGoal();
});

final remainingCaloriesProvider = Provider.family<double, DateTime>((ref, date) {
  final totals = ref.watch(nutritionTotalsProvider(date));
  final goal = ref.watch(calorieGoalProvider);
  return NutritionEngine.calculateRemaining(goal, totals['calories']!);
});

final nutritionProgressProvider = Provider.family<double, DateTime>((ref, date) {
  final totals = ref.watch(nutritionTotalsProvider(date));
  final goal = ref.watch(calorieGoalProvider);
  return NutritionEngine.calculateProgress(totals['calories']!, goal);
});

final macrosGoalProvider = Provider<Map<String, double>>((ref) {
  final repo = ref.watch(mealRepositoryProvider);
  return {
    'protein': repo.getDailyProteinGoal(),
    'carbs': repo.getDailyCarbsGoal(),
    'fats': repo.getDailyFatsGoal(),
  };
});

final analyticsProvider = Provider.family<Map<String, dynamic>, DateTime>((ref, date) {
  final meals = ref.watch(dailyMealsProvider(normalizeDate(date)));
  final completedMeals = meals.where((m) => m.isCompleted).toList();
  
  double totalCals = completedMeals.fold(0.0, (sum, m) => sum + m.calories);
  int completionCount = completedMeals.length;
  double adherenceRate = meals.isEmpty ? 0 : (completionCount / meals.length);
  
  return {
    'totalCalories': totalCals,
    'completionRate': adherenceRate,
    'mealCount': completionCount,
    'isHealthy': totalCals < 2500,
  };
});

final foodListProvider = StateProvider<List<FoodItem>>((ref) {
  final repository = ref.watch(mealRepositoryProvider);
  return repository.getAllFoodItems();
});
