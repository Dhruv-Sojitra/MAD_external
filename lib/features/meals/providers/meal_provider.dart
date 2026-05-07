import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealp/features/meals/data/meal_repository.dart';
import 'package:mealp/features/meals/domain/models/meal.dart';
import 'package:mealp/features/meals/domain/models/food_item.dart';

final mealRepositoryProvider = Provider((ref) => MealRepository());

final dailyMealsProvider = StateNotifierProvider.family<DailyMealsNotifier, List<Meal>, DateTime>((ref, date) {
  final repository = ref.watch(mealRepositoryProvider);
  return DailyMealsNotifier(repository, date);
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
    await _repository.addMeal(meal);
    _loadMeals();
  }

  Future<void> updateMeal(Meal meal) async {
    await _repository.updateMeal(meal);
    _loadMeals();
  }

  Future<void> deleteMeal(String id) async {
    await _repository.deleteMeal(id);
    _loadMeals();
  }
}

final foodListProvider = StateProvider<List<FoodItem>>((ref) {
  final repository = ref.watch(mealRepositoryProvider);
  return repository.getAllFoodItems();
});

final calorieGoalProvider = StateProvider<double>((ref) {
  return ref.watch(mealRepositoryProvider).getDailyCalorieGoal();
});

final macrosGoalProvider = Provider<Map<String, double>>((ref) {
  final repo = ref.watch(mealRepositoryProvider);
  return {
    'protein': repo.getDailyProteinGoal(),
    'carbs': repo.getDailyCarbsGoal(),
    'fats': repo.getDailyFatsGoal(),
  };
});
