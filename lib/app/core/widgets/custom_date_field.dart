import 'package:flutter/material.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class CustomDateField extends StatelessWidget {
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;

  const CustomDateField({
    Key? key,
    this.initialDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primaryColor,
                  onPrimary: Colors.white,
                  surface: AppColors.cardBackgroundColor,
                  onSurface: AppColors.textColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
       decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                      ),
                    ],
                  ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              initialDate != null 
                ? DateFormat('dd MMM yyyy').format(initialDate!)
                : 'Select Date',
              style: TextStyle(
                color: initialDate != null ? AppColors.textColor : AppColors.hintTextColor,
              ),
            ),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }
}