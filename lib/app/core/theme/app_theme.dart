import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color backgroundColor = Color(0xFFF5F7FA); // Light gray background
  static const Color cardBackgroundColor = Colors.white; // White card background
  static const Color primaryColor = Color(0xFF26C6DA); // Teal for the button
  static const Color textColor = Color(0xFF333333); // Dark gray for text
  static const Color hintTextColor = Color(0xFFB0BEC5); // Light gray for hint text
  static const Color borderColor = Color(0xFFE0E0E0); // Light gray for borders
  static const Color shadowColor = Color(0x1F000000); // Subtle shadow color
  static const Color subtitleColor = Color(0xFF616161); // Subtitle text color
  static const Color linkColor = Colors.blue; // Color for clickable links
  static const Color escalationIconColor = Colors.red; // Color for escalation icons
  static const Color assignmentIconColor = Colors.blue; // Color for assignment icons
  static const Color whatsappIconColor = Colors.green; // Color for WhatsApp icons
  static const Color holdButtonColor = Color.fromARGB(255, 161, 145, 0); // Color for Hold button
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      textTheme: TextTheme(
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.textColor,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.subtitleColor,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textColor,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
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
        hintStyle: TextStyle(color: AppColors.hintTextColor),
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
      iconTheme: IconThemeData(
        color: AppColors.hintTextColor,
      ),
    );
  }
}