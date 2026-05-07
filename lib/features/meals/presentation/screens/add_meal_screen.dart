import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:mealp/core/constants/colors.dart';
import 'package:mealp/features/meals/providers/meal_provider.dart';
import 'package:mealp/features/meals/domain/models/meal.dart';
import 'package:mealp/features/meals/domain/models/food_item.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  const AddMealScreen({super.key, required this.selectedDate});

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '100');
  FoodItem? _selectedFood;
  MealType _selectedType = MealType.breakfast;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final foodItems = ref.watch(foodListProvider);
    final filteredFoods = foodItems.where((food) => 
      food.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Type Selector
            const Text('Select Meal Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: MealType.values.map((type) => _buildTypeChip(type)).toList(),
            ),
            const SizedBox(height: 24),

            // Search Food
            const Text('Search Food', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search for a food...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            
            if (_selectedFood == null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  itemCount: filteredFoods.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final food = filteredFoods[index];
                    return ListTile(
                      title: Text(food.name),
                      subtitle: Text('${food.calories.toInt()} Kcal per ${food.unit}'),
                      onTap: () {
                        setState(() {
                          _selectedFood = food;
                          _searchController.text = food.name;
                        });
                      },
                    );
                  },
                ),
              )
            else
              _buildSelectedFoodCard(),

            const SizedBox(height: 24),

            if (_selectedFood != null) ...[
              const Text('Quantity (g / units)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixText: _selectedFood!.unit,
                ),
                onChanged: (val) => setState(() {}),
              ),
              const SizedBox(height: 40),
              _buildSummary(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(MealType type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _getMealColor(type) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _getMealColor(type) : Colors.grey.shade300),
        ),
        child: Text(
          type.name.substring(0, 1).toUpperCase() + type.name.substring(1),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFoodCard() {
    return Card(
      color: AppColors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.primary, width: 1),
      ),
      child: ListTile(
        title: Text(_selectedFood!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${_selectedFood!.calories.toInt()} Kcal per ${_selectedFood!.unit}'),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() {
            _selectedFood = null;
            _searchController.clear();
          }),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    double qty = double.tryParse(_quantityController.text) ?? 0;
    double factor = qty / 100; // Assuming basic nutrients are per 100g if unit is 'g'
    if (_selectedFood!.unit != 'g' && _selectedFood!.unit != '100g') {
      factor = qty; // Per unit
    }

    double totalCals = _selectedFood!.calories * factor;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Calories', '${totalCals.toInt()}'),
          _buildSummaryItem('Protein', '${(_selectedFood!.protein * factor).toInt()}g'),
          _buildSummaryItem('Carbs', '${(_selectedFood!.carbs * factor).toInt()}g'),
          _buildSummaryItem('Fats', '${(_selectedFood!.fats * factor).toInt()}g'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _saveMeal() {
    if (_selectedFood == null) return;
    
    double qty = double.tryParse(_quantityController.text) ?? 100;
    double factor = (_selectedFood!.unit == 'g' || _selectedFood!.unit == '100g') ? qty / 100 : qty;

    final meal = Meal(
      id: const Uuid().v4(),
      foodName: _selectedFood!.name,
      type: _selectedType,
      quantity: qty,
      calories: _selectedFood!.calories * factor,
      protein: _selectedFood!.protein * factor,
      carbs: _selectedFood!.carbs * factor,
      fats: _selectedFood!.fats * factor,
      date: widget.selectedDate,
    );

    ref.read(dailyMealsProvider(widget.selectedDate).notifier).addMeal(meal);
    Navigator.pop(context);
  }

  Color _getMealColor(MealType type) {
    switch (type) {
      case MealType.breakfast: return AppColors.breakfast;
      case MealType.lunch: return AppColors.lunch;
      case MealType.dinner: return AppColors.dinner;
      case MealType.snacks: return AppColors.snacks;
    }
  }
}
