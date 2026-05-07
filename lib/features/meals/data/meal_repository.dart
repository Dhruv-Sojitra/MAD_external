import 'package:hive/hive.dart';
import 'package:mealp/features/meals/domain/models/meal.dart';
import 'package:mealp/features/meals/domain/models/food_item.dart';
import 'package:mealp/core/services/local_storage_service.dart';

class MealRepository {
  final Box<Meal> _mealBox = Hive.box<Meal>(LocalStorageService.mealBoxName);
  final Box<FoodItem> _foodBox = Hive.box<FoodItem>(LocalStorageService.foodBoxName);
  final Box _settingsBox = Hive.box(LocalStorageService.settingsBoxName);

  List<Meal> getMealsByDate(DateTime date) {
    return _mealBox.values.where((meal) {
      return meal.date.year == date.year &&
             meal.date.month == date.month &&
             meal.date.day == date.day;
    }).toList();
  }

  List<Meal> getCompletedMeals(DateTime date) {
    return getMealsByDate(date).where((m) => m.isCompleted).toList();
  }

  List<Meal> getPendingMeals(DateTime date) {
    return getMealsByDate(date).where((m) => !m.isCompleted).toList();
  }

  Future<void> addMeal(Meal meal) async {
    await _mealBox.put(meal.id, meal);
  }

  Future<void> updateMeal(Meal meal) async {
    final updatedMeal = meal.copyWith(updatedAt: DateTime.now());
    await _mealBox.put(meal.id, updatedMeal);
  }

  Future<void> toggleMealCompletion(String id) async {
    final meal = _mealBox.get(id);
    if (meal != null) {
      final updatedMeal = meal.copyWith(
        isCompleted: !meal.isCompleted,
        completedAt: !meal.isCompleted ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );
      await _mealBox.put(id, updatedMeal);
    }
  }

  Future<void> deleteMeal(String id) async {
    await _mealBox.delete(id);
  }

  List<FoodItem> getAllFoodItems() {
    return _foodBox.values.toList();
  }

  Future<void> addFoodItem(FoodItem item) async {
    await _foodBox.put(item.id, item);
  }

  double getDailyCalorieGoal() => _settingsBox.get('daily_calories', defaultValue: 2000.0);
  double getDailyProteinGoal() => _settingsBox.get('daily_protein', defaultValue: 150.0);
  double getDailyCarbsGoal() => _settingsBox.get('daily_carbs', defaultValue: 250.0);
  double getDailyFatsGoal() => _settingsBox.get('daily_fats', defaultValue: 70.0);

  Future<void> updateGoals({double? calories, double? protein, double? carbs, double? fats}) async {
    if (calories != null) await _settingsBox.put('daily_calories', calories);
    if (protein != null) await _settingsBox.put('daily_protein', protein);
    if (carbs != null) await _settingsBox.put('daily_carbs', carbs);
    if (fats != null) await _settingsBox.put('daily_fats', fats);
  }
}
