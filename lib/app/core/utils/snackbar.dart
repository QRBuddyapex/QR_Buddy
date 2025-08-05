
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

class CustomSnackbar {
  static void info(String message) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(
          message,
          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
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

  static void success(String message) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(
          message,
          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
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

  static void error(String message) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(
          message,
          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
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
