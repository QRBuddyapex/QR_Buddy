
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';

class AppColors {
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardBackgroundColor = Colors.white;
  static const Color primaryColor = Color(0xFF006afd);
  static const Color textColor = Color(0xFF333333);
  static const Color hintTextColor = Color(0xFFB0BEC5);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color shadowColor = Color(0x1F000000);
  static const Color subtitleColor = Color(0xFF616161);
  static const Color linkColor = Colors.blue;
  static const Color escalationIconColor = Colors.red;
  static const Color assignmentIconColor = Colors.blue;
  static const Color whatsappIconColor = Color(0xFF44a047);
  static const Color statusButtonColor = Color(0xFF006afd);
  static const Color holdButtonColor = Color.fromARGB(255, 161, 145, 0);
  static const Color statusButtonColor1 = Color(0xFFffc008);
  static const Color dangerButtonColor = Color(0xFFf44336);
  static const Color blackColor = Colors.black;
  static const Color drawerBackground = Color(0xFFF5F7FA);
  static const Color drawerHeaderGradientStart = Color(0xFF006afd);
  static const Color drawerHeaderGradientEnd = Color(0xFF0047b3);
  static const Color drawerTileHover = Color(0xFFE3F2FD);
  static const Color glassBackground = Color(0x33FFFFFF);
  static const Color glassTileBackground = Color(0x1AFFFFFF);

  static const Color darkBackgroundColor = Color(0xFF1A1A1A);
  static const Color darkCardBackgroundColor = Color(0xFF2A2A2A);
  static const Color darkTextColor = Color(0xFFE0E0E0);
  static const Color darkHintTextColor = Color(0xFF757575);
  static const Color darkBorderColor = Color(0xFF424242);
  static const Color darkShadowColor = Color(0x4D000000);
  static const Color darkSubtitleColor = Color(0xFFB0BEC5);
  static const Color darkDrawerBackground = Color(0xFF1A1A1A);
  static const Color darkDrawerHeaderGradientStart = Color(0xFF0288D1);
  static const Color darkDrawerHeaderGradientEnd = Color(0xFF01579B);
  static const Color darkDrawerTileHover = Color(0xFF37474F);
  static const Color darkGlassBackground = Color(0x26FFFFFF);
  static const Color darkGlassTileBackground = Color(0x1AFFFFFF);
  static const Color iconColor = Colors.black54;
  static const Color darkIconColor = Colors.white70;
}

class AppTheme {
  static ThemeData get lightTheme {
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
        labelLarge: GoogleFonts.poppins( // Added for CustomTextField, CustomButton, etc.
          fontSize: 14,
          fontWeight: FontWeight.w500,
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
      brightness: Brightness.light,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.darkBackgroundColor,
      textTheme: TextTheme(
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextColor,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.darkTextColor,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.darkSubtitleColor,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.darkTextColor,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextColor,
        ),
        labelLarge: GoogleFonts.poppins( // Added for CustomTextField, CustomButton, etc.
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextColor,
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
        hintStyle: TextStyle(color: AppColors.darkHintTextColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
      ),
      iconTheme: IconThemeData(
        color: AppColors.darkHintTextColor,
      ),
      brightness: Brightness.dark,
    );
  }
}

class ThemeController extends GetxController {
  var isDarkMode = false.obs;
  final TokenStorage _tokenStorage = TokenStorage();

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    await _tokenStorage.saveTheme(isDarkMode.value);
    Get.changeTheme(isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme);
  }

  void _loadTheme() async {
    bool? savedTheme = await _tokenStorage.getTheme();
    if (savedTheme != null) {
      isDarkMode.value = savedTheme;
    } else {

      isDarkMode.value = false;
      await _tokenStorage.saveTheme(false);
    }
    Get.changeTheme(isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme);
  }
}
