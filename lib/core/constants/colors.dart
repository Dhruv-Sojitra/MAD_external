import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Secondary/Accent
  static const Color accent = Color(0xFFF43F5E);
  static const Color accentLight = Color(0xFFFB7185);

  // Nutrition Colors
  static const Color calories = Color(0xFF6366F1);
  static const Color protein = Color(0xFF10B981);
  static const Color carbs = Color(0xFFF59E0B);
  static const Color fats = Color(0xFFEF4444);

  // Meal Types
  static const Color breakfast = Color(0xFF60A5FA);
  static const Color lunch = Color(0xFF34D399);
  static const Color dinner = Color(0xFFF472B6);
  static const Color snacks = Color(0xFFFBBF24);

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  // Dark Mode
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
