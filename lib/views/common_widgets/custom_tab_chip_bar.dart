import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomTabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final BorderRadius? borderRadius;
  final Color? activeCategoryColor;

  const CustomTabChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.fontSize = 13,
    this.borderRadius,
    this.activeCategoryColor,
  });

  @override
  Widget build(BuildContext context) {
    Color effectiveBackgroundColor;
    Color effectiveTextColor;
    Color effectiveBorderColor;
    final FontWeight selectedFontWeight = FontWeight.bold;
    final FontWeight unselectedFontWeight = FontWeight.w500;

    if (isSelected) {
      if (activeCategoryColor != null) {
        effectiveBackgroundColor = activeCategoryColor!.withOpacity(0.15);
        effectiveTextColor = activeCategoryColor!;
        effectiveBorderColor = activeCategoryColor!;
      } else {
        effectiveBackgroundColor = AppColors.primary.withOpacity(0.12);
        effectiveTextColor = AppColors.primary;
        effectiveBorderColor = AppColors.primary;
      }
    } else {
      effectiveBackgroundColor = AppColors.chipBarBackground.withOpacity(0.5);
      effectiveTextColor = AppColors.secondaryText;
      effectiveBorderColor = AppColors.secondaryText.withOpacity(0.4);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          border: Border.all(
            color: effectiveBorderColor,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: effectiveTextColor,
            fontWeight: isSelected ? selectedFontWeight : unselectedFontWeight,
            fontSize: fontSize,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}