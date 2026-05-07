import 'package:mealp/features/meals/domain/models/meal.dart';

class NutritionEngine {
  static Map<String, double> calculateTotals(List<Meal> meals) {
    // ONLY completed meals count toward the totals
    final completedMeals = meals.where((m) => m.isCompleted).toList();
    
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fats = 0;

    for (var meal in completedMeals) {
      calories += meal.calories;
      protein += meal.protein;
      carbs += meal.carbs;
      fats += meal.fats;
    }

    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    };
  }

  static double calculateRemaining(double goal, double consumed) {
    final remaining = goal - consumed;
    return remaining > 0 ? remaining : 0;
  }

  static double calculateProgress(double consumed, double goal) {
    if (goal <= 0) return 0;
    final progress = consumed / goal;
    return progress > 1.0 ? 1.0 : progress;
  }

  static Map<String, int> getCompletionStats(List<Meal> meals) {
    int completed = meals.where((m) => m.isCompleted).length;
    int total = meals.length;
    return {
      'completed': completed,
      'pending': total - completed,
      'total': total,
    };
  }
}
