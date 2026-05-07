import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mealp/core/constants/colors.dart';
import 'package:mealp/features/meals/providers/meal_provider.dart';
import 'package:mealp/features/meals/domain/models/meal.dart';
import 'package:mealp/features/meals/presentation/widgets/meal_card.dart';
import 'add_meal_screen.dart';

class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> {
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(dailyMealsProvider(_selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _selectedDate = DateTime(picked.year, picked.month, picked.day));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildDateSelector(),
        ),
      ),
      body: meals.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: MealType.values.length,
              itemBuilder: (context, index) {
                final type = MealType.values[index];
                final typeMeals = meals.where((m) => m.type == type).toList();
                return _buildMealTypeSection(type, typeMeals);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddMeal(),
        label: const Text('Add Meal'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              DateFormat('EEEE, MMM d').format(_selectedDate),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_outlined, size: 80, color: Colors.grey.shade300)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds),
          const SizedBox(height: 16),
          const Text('Your meal plan is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddMeal(),
            icon: const Icon(Icons.add),
            label: const Text('Start Planning'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSection(MealType type, List<Meal> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              _getMealIcon(type),
              const SizedBox(width: 8),
              Text(
                type.name.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w900, color: _getMealColor(type), letterSpacing: 1.5),
              ),
              const Spacer(),
              Text(
                '${meals.where((m) => m.isCompleted).fold(0.0, (sum, m) => sum + m.calories).toInt()} / ${meals.fold(0.0, (sum, m) => sum + m.calories).toInt()} kcal',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        ...meals.map((meal) => _buildSlidableMealCard(meal)).toList(),
      ],
    ).animate().fadeIn().slideX();
  }

  Widget _buildSlidableMealCard(Meal meal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: Key(meal.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _toggleCompletion(meal),
              backgroundColor: meal.isCompleted ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              icon: meal.isCompleted ? Icons.undo : Icons.check_circle,
              label: meal.isCompleted ? 'Undo' : 'Complete',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _navigateToEditMeal(meal),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: BorderRadius.circular(16),
            ),
            SlidableAction(
              onPressed: (_) => _deleteMeal(meal),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: MealCard(
          meal: meal,
          onTap: () => _navigateToEditMeal(meal),
          onEdit: () => _navigateToEditMeal(meal),
          onLongPress: () => _showQuickActions(context, meal, ref),
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context, Meal meal, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit Meal'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditMeal(meal);
              },
            ),
            ListTile(
              leading: Icon(meal.isCompleted ? Icons.undo : Icons.check_circle, color: Colors.green),
              title: Text(meal.isCompleted ? 'Mark as Pending' : 'Mark as Completed'),
              onTap: () {
                _toggleCompletion(meal);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Meal', style: TextStyle(color: Colors.red)),
              onTap: () {
                _deleteMeal(meal);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getMealIcon(MealType type) {
    IconData icon;
    switch (type) {
      case MealType.breakfast: icon = Icons.wb_sunny; break;
      case MealType.lunch: icon = Icons.light_mode; break;
      case MealType.dinner: icon = Icons.nightlight_round; break;
      case MealType.snacks: icon = Icons.cookie; break;
    }
    return Icon(icon, color: _getMealColor(type), size: 20);
  }

  Color _getMealColor(MealType type) {
    switch (type) {
      case MealType.breakfast: return AppColors.breakfast;
      case MealType.lunch: return AppColors.lunch;
      case MealType.dinner: return AppColors.dinner;
      case MealType.snacks: return AppColors.snacks;
    }
  }

  void _toggleCompletion(Meal meal) {
    ref.read(dailyMealsProvider(_selectedDate).notifier).toggleMealCompletion(meal.id);
  }

  void _deleteMeal(Meal meal) {
    ref.read(dailyMealsProvider(_selectedDate).notifier).deleteMeal(meal.id);
  }

  void _navigateToAddMeal() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddMealScreen(selectedDate: _selectedDate)),
    );
  }

  void _navigateToEditMeal(Meal meal) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddMealScreen(selectedDate: _selectedDate, mealToEdit: meal)),
    );
  }
}
