import 'package:hive/hive.dart';
import 'food_item.dart';

@HiveType(typeId: 1)
enum MealType { 
  @HiveField(0) breakfast, 
  @HiveField(1) lunch, 
  @HiveField(2) dinner, 
  @HiveField(3) snacks 
}

@HiveType(typeId: 2)
class Meal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String foodName;

  @HiveField(2)
  final MealType type;

  @HiveField(3)
  final double quantity;

  @HiveField(4)
  final double calories;

  @HiveField(5)
  final double protein;

  @HiveField(6)
  final double carbs;

  @HiveField(7)
  final double fats;

  @HiveField(8)
  final DateTime date;

  Meal({
    required this.id,
    required this.foodName,
    required this.type,
    required this.quantity,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.date,
  });
}

// Manual Adapters
class MealTypeAdapter extends TypeAdapter<MealType> {
  @override
  final int typeId = 1;

  @override
  MealType read(BinaryReader reader) {
    return MealType.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, MealType obj) {
    writer.writeInt(obj.index);
  }
}

class MealAdapter extends TypeAdapter<Meal> {
  @override
  final int typeId = 2;

  @override
  Meal read(BinaryReader reader) {
    return Meal(
      id: reader.read(),
      foodName: reader.read(),
      type: reader.read(),
      quantity: reader.read(),
      calories: reader.read(),
      protein: reader.read(),
      carbs: reader.read(),
      fats: reader.read(),
      date: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Meal obj) {
    writer.write(obj.id);
    writer.write(obj.foodName);
    writer.write(obj.type);
    writer.write(obj.quantity);
    writer.write(obj.calories);
    writer.write(obj.protein);
    writer.write(obj.carbs);
    writer.write(obj.fats);
    writer.write(obj.date);
  }
}
