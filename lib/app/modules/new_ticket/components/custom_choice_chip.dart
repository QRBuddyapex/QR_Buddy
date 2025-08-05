
import 'package:flutter/material.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

class CustomChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const CustomChoiceChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: AppColors.primaryColor.withOpacity(0.1),
        backgroundColor: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: selected
                  ? AppColors.primaryColor
                  : (isDarkMode ? AppColors.darkTextColor : AppColors.textColor),
            ),
      ),
    );
  }
}
