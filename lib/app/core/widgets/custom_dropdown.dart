
import 'package:flutter/material.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const CustomDropdownField({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final validValue = items.contains(value) ? value : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: validValue,
            isExpanded: true,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                      ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? AppColors.darkHintTextColor : AppColors.hintTextColor,
                    overflow: TextOverflow.ellipsis,
                  ),
              filled: true,
              fillColor: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: isDarkMode ? AppColors.darkBorderColor : AppColors.borderColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: isDarkMode ? AppColors.darkBorderColor : AppColors.borderColor,
                ),
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
