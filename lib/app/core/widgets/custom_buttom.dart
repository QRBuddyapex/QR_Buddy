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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final vPadding = height * 0.02;
    final buttonWidth = widget.width ?? (width * 0.4);
    final buttonHeight = widget.height ?? (height * 0.06);
    final borderRadius = width * 0.075;
    final fontSize = width * 0.04;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vPadding),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color ?? AppColors.primaryColor,
          foregroundColor: isDarkMode ? AppColors.darkTextColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          minimumSize: Size(buttonWidth, buttonHeight),
        ),
        onPressed: widget.onPressed,
        child: Text(
          widget.text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.darkTextColor : Colors.white,
              ),
        ),
      ),
    );
  }
}