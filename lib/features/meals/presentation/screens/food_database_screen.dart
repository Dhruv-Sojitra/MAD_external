import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:mealp/core/constants/colors.dart';
import 'package:mealp/features/meals/providers/meal_provider.dart';
import 'package:mealp/features/meals/domain/models/food_item.dart';

class FoodDatabaseScreen extends ConsumerStatefulWidget {
  const FoodDatabaseScreen({super.key});

  @override
  ConsumerState<FoodDatabaseScreen> createState() => _FoodDatabaseScreenState();
}

class _FoodDatabaseScreenState extends ConsumerState<FoodDatabaseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final foodItems = ref.watch(foodListProvider);
    final filteredFoods = foodItems.where((food) => 
      food.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Database'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search food database...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredFoods.length,
              itemBuilder: (context, index) {
                final food = filteredFoods[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('P: ${food.protein}g • C: ${food.carbs}g • F: ${food.fats}g'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${food.calories.toInt()} Kcal', 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        Text('per ${food.unit}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFoodDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddFoodDialog() {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatsController = TextEditingController();
    final unitController = TextEditingController(text: '100g');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Food'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Food Name')),
              TextField(controller: unitController, decoration: const InputDecoration(labelText: 'Unit (e.g. 100g, piece)')),
              TextField(controller: calController, decoration: const InputDecoration(labelText: 'Calories'), keyboardType: TextInputType.number),
              TextField(controller: proteinController, decoration: const InputDecoration(labelText: 'Protein (g)'), keyboardType: TextInputType.number),
              TextField(controller: carbsController, decoration: const InputDecoration(labelText: 'Carbs (g)'), keyboardType: TextInputType.number),
              TextField(controller: fatsController, decoration: const InputDecoration(labelText: 'Fats (g)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newItem = FoodItem(
                id: const Uuid().v4(),
                name: nameController.text,
                calories: double.tryParse(calController.text) ?? 0,
                protein: double.tryParse(proteinController.text) ?? 0,
                carbs: double.tryParse(carbsController.text) ?? 0,
                fats: double.tryParse(fatsController.text) ?? 0,
                unit: unitController.text,
              );
              ref.read(mealRepositoryProvider).addFoodItem(newItem);
              ref.read(foodListProvider.notifier).state = ref.read(mealRepositoryProvider).getAllFoodItems();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
