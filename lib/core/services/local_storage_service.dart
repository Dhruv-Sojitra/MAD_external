import 'package:hive_flutter/hive_flutter.dart';
import 'package:mealp/features/meals/domain/models/food_item.dart';
import 'package:mealp/features/meals/domain/models/meal.dart';
import 'package:mealp/core/constants/sample_data.dart';

class LocalStorageService {
  static const String foodBoxName = 'food_items';
  static const String mealBoxName = 'meals';
  static const String settingsBoxName = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(FoodItemAdapter());
    Hive.registerAdapter(MealTypeAdapter());
    Hive.registerAdapter(MealAdapter());

    // Open Boxes
    final foodBox = await Hive.openBox<FoodItem>(foodBoxName);
    await Hive.openBox<Meal>(mealBoxName);
    final settingsBox = await Hive.openBox(settingsBoxName);

    // Preload data if empty
    if (foodBox.isEmpty) {
      await foodBox.addAll(SampleData.initialFoodItems);
    }
    
    // Default goals
    if (settingsBox.get('daily_calories') == null) {
      await settingsBox.put('daily_calories', 2000.0);
      await settingsBox.put('daily_protein', 150.0);
      await settingsBox.put('daily_carbs', 250.0);
      await settingsBox.put('daily_fats', 70.0);
    }
  }
}
