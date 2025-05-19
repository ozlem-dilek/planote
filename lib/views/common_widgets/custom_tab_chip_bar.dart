import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomTabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final BorderRadius? borderRadius;

  const CustomTabChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.fontSize = 13,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Color selectedBackgroundColor = AppColors.calendarChipSelectedText.withOpacity(0.12);
    final Color selectedTextColor = AppColors.calendarChipSelectedText;
    final Color selectedBorderColor = AppColors.calendarChipSelectedText;

    final Color unselectedBackgroundColor = AppColors.chipBarBackground.withOpacity(0.5);
    final Color unselectedTextColor = AppColors.calendarChipUnselectedText;
    final Color unselectedBorderColor = AppColors.secondaryText.withOpacity(0.4);

    final FontWeight selectedFontWeight = FontWeight.bold;
    final FontWeight unselectedFontWeight = FontWeight.w500;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? selectedBackgroundColor : unselectedBackgroundColor,
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedBorderColor : unselectedBorderColor,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? selectedTextColor : unselectedTextColor,
            fontWeight: isSelected ? selectedFontWeight : unselectedFontWeight,
            fontSize: fontSize,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}