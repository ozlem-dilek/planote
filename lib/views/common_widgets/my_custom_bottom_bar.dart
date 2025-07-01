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
    final ThemeData theme = Theme.of(context);
    bool isSelected = currentIndex == itemIndex;

    Color iconColor = isSelected
        ? theme.colorScheme.primary
        : theme.iconTheme.color?.withOpacity(0.7) ?? theme.colorScheme.onSurface.withOpacity(0.7);

    Color labelColor = isSelected
        ? theme.colorScheme.primary
        : theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurface.withOpacity(0.9);

    FontWeight labelFontWeight = isSelected ? FontWeight.bold : FontWeight.normal;
    double iconSize = 24;
    double labelFontSize = 11;

    if (isSelected && item.hasLabel) {
      // Seçili ve etiketli item için AppColors'tan gelen özel bir renk kullanabiliriz (opsiyonel)
      // veya tema birincil rengini koruyabiliriz. Önceki gibi AppColors.primary kullanılıyordu.
      // Şimdilik tema birincil rengini kullanalım.
      // iconColor = AppColors.primary; // Eğer özel bir seçili renk isteniyorsa
      // labelColor = AppColors.primary;
    }


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
    final ThemeData theme = Theme.of(context);
    return Material(
      elevation: 8.0,
      color: theme.bottomAppBarTheme.color ?? theme.colorScheme.surface,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            if (index < items.length) {
              return _buildBarItem(context, items[index], index);
            }
            return const SizedBox.shrink();
          }),
        ),
      ),
    );
  }
}