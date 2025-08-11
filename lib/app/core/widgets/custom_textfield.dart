import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String hintText;
  final bool obscureText;
  final bool showToggleIcon;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final String? initialValue;
  final int? maxLines;
  final TextInputType? keyboardType;
  final RxBool? visibilityController;

  const CustomTextField({
    Key? key,
    this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.showToggleIcon = false,
    required this.onChanged,
    this.validator,
    this.initialValue,
    this.maxLines,
    this.visibilityController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget buildTextField({required bool obscure}) {
      return TextFormField(
        maxLines: maxLines ?? 1,
        initialValue: initialValue,
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? AppColors.darkHintTextColor
                    : AppColors.hintTextColor,
              ),
          filled: true,
          fillColor: isDarkMode
              ? AppColors.darkCardBackgroundColor
              : AppColors.cardBackgroundColor,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: isDarkMode
                  ? AppColors.darkBorderColor
                  : AppColors.borderColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: isDarkMode
                  ? AppColors.darkBorderColor
                  : AppColors.borderColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide:
                const BorderSide(color: AppColors.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          suffixIcon: showToggleIcon
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: isDarkMode
                        ? AppColors.darkHintTextColor
                        : AppColors.hintTextColor,
                  ),
                  onPressed: () {
                    visibilityController?.value =
                        !(visibilityController?.value ?? false);
                  },
                )
              : null,
        ),
        validator: validator,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(
              label!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 14,
                    color: isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.textColor,
                  ),
            ),
          const SizedBox(height: 4),

    
          if (showToggleIcon && visibilityController != null)
            Obx(() => buildTextField(
                obscure: !(visibilityController?.value ?? false)))
          else
            buildTextField(obscure: obscureText),
        ],
      ),
    );
  }
}
