import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mealp/core/constants/colors.dart';
import 'package:mealp/features/meals/domain/models/meal.dart';
import 'package:mealp/features/meals/providers/meal_provider.dart';

class MealCard extends ConsumerWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onLongPress;

  const MealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.onEdit,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Slidable(
          key: Key(meal.id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => onEdit?.call(),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: (_) => _showDeleteConfirmation(context, ref),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: meal.isCompleted ? Colors.green.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: meal.isCompleted ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                // 1. Checkbox System
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Checkbox(
                    value: meal.isCompleted,
                    activeColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    onChanged: (_) {
                      ref.read(dailyMealsProvider(meal.date).notifier).toggleMealCompletion(meal.id);
                    },
                  ),
                ),
                
                // 2. Content Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.foodName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: meal.isCompleted ? TextDecoration.lineThrough : null,
                            color: meal.isCompleted ? Colors.grey : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                meal.type.name.toUpperCase(),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${meal.quantity.toInt()}g • ${meal.calories.toInt()} kcal',
                              style: TextStyle(
                                fontSize: 12,
                                color: meal.isCompleted ? Colors.grey : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 3. Trailing Quick Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: meal.isCompleted ? Colors.grey : AppColors.primary,
                      ),
                      onPressed: onEdit,
                      splashRadius: 24,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _showDeleteConfirmation(context, ref),
                      splashRadius: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal?'),
        content: const Text('Are you sure you want to remove this meal? This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(dailyMealsProvider(meal.date).notifier).deleteMeal(meal.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
