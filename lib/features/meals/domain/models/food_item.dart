import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class FoodItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double calories; // per 100g/unit

  @HiveField(3)
  final double protein;

  @HiveField(4)
  final double carbs;

  @HiveField(5)
  final double fats;

  @HiveField(6)
  final String unit; // e.g., "g", "piece", "cup"

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.unit = "g",
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'],
        name: json['name'],
        calories: json['calories'].toDouble(),
        protein: json['protein'].toDouble(),
        carbs: json['carbs'].toDouble(),
        fats: json['fats'].toDouble(),
        unit: json['unit'] ?? "g",
      );
}

// Manual Adapter to ensure it runs immediately
class FoodItemAdapter extends TypeAdapter<FoodItem> {
  @override
  final int typeId = 0;

  @override
  FoodItem read(BinaryReader reader) {
    return FoodItem(
      id: reader.read(),
      name: reader.read(),
      calories: reader.read(),
      protein: reader.read(),
      carbs: reader.read(),
      fats: reader.read(),
      unit: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, FoodItem obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.calories);
    writer.write(obj.protein);
    writer.write(obj.carbs);
    writer.write(obj.fats);
    writer.write(obj.unit);
  }
}
