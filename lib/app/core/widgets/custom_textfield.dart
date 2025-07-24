import 'package:flutter/material.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String hintText;
  final bool obscureText;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final String? initialValue;
  final int? maxLines;
  final TextInputType? keyboardType;

  const CustomTextField({
    Key? key,
     this.label,
    required this.hintText,
    this.keyboardType = 
        TextInputType.text,
    this.obscureText = false,
    required this.onChanged,
    this.validator,
    this.initialValue,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            maxLines: maxLines ?? 1,
            initialValue: initialValue,
            obscureText: obscureText,
            keyboardType:keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: AppColors.hintTextColor),
              filled: true,
              fillColor: AppColors.cardBackgroundColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}