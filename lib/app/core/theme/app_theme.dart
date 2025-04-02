import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundColor = Color(0xFFF5F7FA); // Light gray background
  static const Color cardBackgroundColor = Colors.white; // White card background
  static const Color primaryColor = Color(0xFF26C6DA); // Teal for the button
  static const Color textColor = Color(0xFF333333); // Dark gray for text
  static const Color hintTextColor = Color(0xFFB0BEC5); // Light gray for hint text
  static const Color borderColor = Color(0xFFE0E0E0); // Light gray for borders
  static const Color shadowColor = Color(0x1F000000); // Subtle shadow color
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: AppColors.textColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(color: AppColors.hintTextColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}