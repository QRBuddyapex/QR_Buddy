
import 'package:flutter/material.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double? height;
  final double? width;
  final Color? color;

  const CustomButton({
    Key? key,
    this.height,
    this.color,
    this.width,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color ?? AppColors.primaryColor,
          foregroundColor: isDarkMode ? AppColors.darkTextColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: Size(widget.width ?? 150, widget.height ?? 50),
        ),
        onPressed: widget.onPressed,
        child: Text(
          widget.text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.darkTextColor : Colors.white,
              ),
        ),
      ),
    );
  }
}
