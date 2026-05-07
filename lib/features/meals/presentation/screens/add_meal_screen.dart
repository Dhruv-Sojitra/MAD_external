import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:mealp/core/constants/colors.dart';
import 'package:mealp/features/meals/providers/meal_provider.dart';
import 'package:mealp/features/meals/domain/models/meal.dart';
import 'package:mealp/features/meals/domain/models/food_item.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final Meal? mealToEdit;

  const AddMealScreen({
    super.key, 
    required this.selectedDate,
    this.mealToEdit,
  });

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '100');
  final TextEditingController _notesController = TextEditingController();
  
  FoodItem? _selectedFood;
  MealType _selectedType = MealType.breakfast;
  String _searchQuery = '';
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.mealToEdit != null) {
      _isEditMode = true;
      _selectedType = widget.mealToEdit!.type;
      _quantityController.text = widget.mealToEdit!.quantity.toInt().toString();
      _notesController.text = widget.mealToEdit!.notes;
      _searchController.text = widget.mealToEdit!.foodName;
      // Note: In a real app, we'd fetch the FoodItem from the DB using foodId
      // For this implementation, we'll create a temporary FoodItem to represent the current state
      _selectedFood = FoodItem(
        id: widget.mealToEdit!.foodId,
        name: widget.mealToEdit!.foodName,
        calories: widget.mealToEdit!.calories / (widget.mealToEdit!.quantity / 100),
        protein: widget.mealToEdit!.protein / (widget.mealToEdit!.quantity / 100),
        carbs: widget.mealToEdit!.carbs / (widget.mealToEdit!.quantity / 100),
        fats: widget.mealToEdit!.fats / (widget.mealToEdit!.quantity / 100),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodItems = ref.watch(foodListProvider);
    final filteredFoods = foodItems.where((food) => 
      food.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Meal' : 'Add Meal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Type Selector
            const Text('Meal Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: MealType.values.map((type) => _buildTypeChip(type)).toList(),
            ),
            const SizedBox(height: 24),

            // Search Food
            const Text('Search Food Item', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search for a food...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 12),
            
            if (_selectedFood == null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Notes (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Add some notes...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              _buildSummary(),
              const SizedBox(height: 32),
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
                  child: Text(
                    _isEditMode ? 'Update Meal' : 'Add to Plan', 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
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
          color: isSelected ? _getMealColor(type) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _getMealColor(type) : Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          type.name.substring(0, 1).toUpperCase() + type.name.substring(1),
          style: TextStyle(
            color: isSelected ? Colors.white : null,
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
          icon: const Icon(Icons.change_circle_outlined, color: AppColors.primary),
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
    double factor = (_selectedFood!.unit == 'g' || _selectedFood!.unit == '100g') ? qty / 100 : qty;

    double totalCals = _selectedFood!.calories * factor;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Calories', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${totalCals.toInt()} kcal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Protein', '${(_selectedFood!.protein * factor).toInt()}g'),
              _buildSummaryItem('Carbs', '${(_selectedFood!.carbs * factor).toInt()}g'),
              _buildSummaryItem('Fats', '${(_selectedFood!.fats * factor).toInt()}g'),
            ],
          ),
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
    final normalizedDate = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);

    if (_isEditMode) {
      final meal = widget.mealToEdit!.copyWith(
        foodName: _selectedFood!.name,
        type: _selectedType,
        quantity: qty,
        calories: _selectedFood!.calories * factor,
        protein: _selectedFood!.protein * factor,
        carbs: _selectedFood!.carbs * factor,
        fats: _selectedFood!.fats * factor,
        notes: _notesController.text,
        date: normalizedDate,
        updatedAt: DateTime.now(),
      );
      ref.read(dailyMealsProvider(normalizedDate).notifier).updateMeal(meal);
    } else {
      final meal = Meal(
        id: const Uuid().v4(),
        foodId: _selectedFood!.id,
        foodName: _selectedFood!.name,
        type: _selectedType,
        quantity: qty,
        calories: _selectedFood!.calories * factor,
        protein: _selectedFood!.protein * factor,
        carbs: _selectedFood!.carbs * factor,
        fats: _selectedFood!.fats * factor,
        date: normalizedDate,
        notes: _notesController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      ref.read(dailyMealsProvider(normalizedDate).notifier).addMeal(meal);
    }
    
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
