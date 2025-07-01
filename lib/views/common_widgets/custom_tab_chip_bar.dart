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
    final ThemeData theme = Theme.of(context);
    Color effectiveBackgroundColor;
    Color effectiveTextColor;
    Color effectiveBorderColor;
    final FontWeight selectedFontWeight = FontWeight.bold;
    final FontWeight unselectedFontWeight = FontWeight.w500;

    if (isSelected) {
      if (activeCategoryColor != null) {
        effectiveBackgroundColor = activeCategoryColor!.withOpacity(0.20);
        effectiveTextColor = activeCategoryColor!;
        effectiveBorderColor = activeCategoryColor!;
      } else {
        effectiveBackgroundColor = theme.colorScheme.primary.withOpacity(0.15);
        effectiveTextColor = theme.colorScheme.primary;
        effectiveBorderColor = theme.colorScheme.primary;
      }
    } else {
      effectiveBackgroundColor = theme.chipTheme.backgroundColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.5);
      effectiveTextColor = theme.chipTheme.labelStyle?.color ?? theme.colorScheme.onSurfaceVariant;
      effectiveBorderColor = theme.colorScheme.outline.withOpacity(0.5);
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
            width: isSelected ? 1.5 : 1.2,
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