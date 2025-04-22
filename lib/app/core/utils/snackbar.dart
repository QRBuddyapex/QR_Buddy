import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
 

class CustomSnackbar {
  static info(String message) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(
          message,
          style: AppTheme.theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        icon: const Icon(
          Icons.info_outline,
          color: Colors.white,
        ),
        shouldIconPulse: false,
        backgroundColor: AppColors.primaryColor.withOpacity(0.9),
        barBlur: 50.0,
        margin: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 20.0),
        borderRadius: 15.0,
        animationDuration: const Duration(milliseconds: 100),
        forwardAnimationCurve: Curves.elasticIn,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static success(String message) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(
          message,
          style: AppTheme.theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        icon: const Icon(
          Icons.check_circle_outline,
          color: Colors.white,
        ),
        shouldIconPulse: false,
        backgroundColor: Colors.green.withOpacity(0.9),
        barBlur: 50.0,
        margin: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 20.0),
        borderRadius: 15.0,
        animationDuration: const Duration(milliseconds: 100),
        forwardAnimationCurve: Curves.elasticIn,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static error(String message) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(
          message,
          style: AppTheme.theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        icon: const Icon(
          Icons.error_outline,
          color: Colors.white,
        ),
        shouldIconPulse: false,
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        barBlur: 50.0,
        margin: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 20.0),
        borderRadius: 15.0,
        animationDuration: const Duration(milliseconds: 100),
        forwardAnimationCurve: Curves.elasticIn,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
