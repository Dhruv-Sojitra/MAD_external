import 'package:hive/hive.dart';

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
  final String foodId;

  @HiveField(2)
  final String foodName;

  @HiveField(3)
  final MealType type;

  @HiveField(4)
  final double quantity;

  @HiveField(5)
  final double calories;

  @HiveField(6)
  final double protein;

  @HiveField(7)
  final double carbs;

  @HiveField(8)
  final double fats;

  @HiveField(9)
  final DateTime date;

  @HiveField(10)
  final String notes;

  @HiveField(11)
  final bool isCompleted;

  @HiveField(12)
  final DateTime? completedAt;

  @HiveField(13)
  final String syncStatus; // 'pending', 'synced', 'failed'

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime updatedAt;

  Meal({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.type,
    required this.quantity,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.date,
    this.notes = '',
    this.isCompleted = false,
    this.completedAt,
    this.syncStatus = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  Meal copyWith({
    String? id,
    String? foodId,
    String? foodName,
    MealType? type,
    double? quantity,
    double? calories,
    double? protein,
    double? carbs,
    double? fats,
    DateTime? date,
    String? notes,
    bool? isCompleted,
    DateTime? completedAt,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Meal(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Equality
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          foodId == other.foodId &&
          foodName == other.foodName &&
          type == other.type &&
          quantity == other.quantity &&
          calories == other.calories &&
          protein == other.protein &&
          carbs == other.carbs &&
          fats == other.fats &&
          date == other.date &&
          notes == other.notes &&
          isCompleted == other.isCompleted &&
          completedAt == other.completedAt &&
          syncStatus == other.syncStatus &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      foodId.hashCode ^
      foodName.hashCode ^
      type.hashCode ^
      quantity.hashCode ^
      calories.hashCode ^
      protein.hashCode ^
      carbs.hashCode ^
      fats.hashCode ^
      date.hashCode ^
      notes.hashCode ^
      isCompleted.hashCode ^
      completedAt.hashCode ^
      syncStatus.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
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
      foodId: reader.read(),
      foodName: reader.read(),
      type: reader.read(),
      quantity: reader.read(),
      calories: reader.read(),
      protein: reader.read(),
      carbs: reader.read(),
      fats: reader.read(),
      date: reader.read(),
      notes: reader.read(),
      isCompleted: reader.read(),
      completedAt: reader.read(),
      syncStatus: reader.read(),
      createdAt: reader.read(),
      updatedAt: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Meal obj) {
    writer.write(obj.id);
    writer.write(obj.foodId);
    writer.write(obj.foodName);
    writer.write(obj.type);
    writer.write(obj.quantity);
    writer.write(obj.calories);
    writer.write(obj.protein);
    writer.write(obj.carbs);
    writer.write(obj.fats);
    writer.write(obj.date);
    writer.write(obj.notes);
    writer.write(obj.isCompleted);
    writer.write(obj.completedAt);
    writer.write(obj.syncStatus);
    writer.write(obj.createdAt);
    writer.write(obj.updatedAt);
  }
}
