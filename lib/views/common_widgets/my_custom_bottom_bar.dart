import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomBottomBarItemData {
  final IconData iconData;
  final String? label;
  final bool hasLabel;

  CustomBottomBarItemData({
    required this.iconData,
    this.label,
    this.hasLabel = true,
  });
}

class MyCustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CustomBottomBarItemData> items;

  const MyCustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  Widget _buildBarItem(BuildContext context, CustomBottomBarItemData item, int itemIndex) {
    bool isSelected = currentIndex == itemIndex;


    Color iconColor = isSelected ? AppColors.primary : AppColors.secondaryText.withOpacity(0.7);
    Color labelColor = isSelected ? AppColors.primary : AppColors.secondaryText.withOpacity(0.9);
    FontWeight labelFontWeight = isSelected ? FontWeight.bold : FontWeight.normal;
    double iconSize = 24;
    double labelFontSize = 11;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(itemIndex),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.iconData,
                color: iconColor,
                size: iconSize,
              ),
              if (item.hasLabel && item.label != null && item.label!.isNotEmpty)
                const SizedBox(height: 3),
              if (item.hasLabel && item.label != null && item.label!.isNotEmpty)
                Text(
                  item.label!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: labelFontSize,
                    fontWeight: labelFontWeight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8.0,
      color: AppColors.cardBackground, // Veya AppColors.customBottomBarBackground
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            return _buildBarItem(context, items[index], index);
          }),
        ),
      ),
    );
  }
}