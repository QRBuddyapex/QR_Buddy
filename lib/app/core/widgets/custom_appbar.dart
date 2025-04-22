import 'package:flutter/material.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onStartShiftPressed;
  final VoidCallback? onQrPressed;
  final VoidCallback? onBrightnessPressed;
  final VoidCallback? onLocationPressed;
  final VoidCallback? onProfilePressed;
  final Widget? leading;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onStartShiftPressed,
    this.onQrPressed,
    this.onBrightnessPressed,
    this.onLocationPressed,
    this.onProfilePressed,
    this.leading, required List<IconButton> actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      leading: leading,
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 20,
            ) ??
            const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
      ),
      actions: [
        ElevatedButton(
          onPressed: onStartShiftPressed,
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              ) ??
              ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
          child: const Text(
            'Start Shift',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.qr_code, color: AppColors.hintTextColor),
          onPressed: onQrPressed,
        ),
        IconButton(
          icon: const Icon(Icons.brightness_6, color: AppColors.hintTextColor),
          onPressed: onBrightnessPressed,
        ),
        IconButton(
          icon: const Icon(Icons.location_on, color: AppColors.hintTextColor),
          onPressed: onLocationPressed,
        ),
        IconButton(
          icon: const Icon(Icons.person, color: AppColors.hintTextColor),
          onPressed: onProfilePressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}