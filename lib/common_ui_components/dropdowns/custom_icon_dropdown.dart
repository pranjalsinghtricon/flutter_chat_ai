import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom_dropdown_item.dart';

class CustomIconDropdown extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final double assetSize;
  final List<CustomDropdownItem> items;

  const CustomIconDropdown({
    Key? key,
    this.icon,
    this.assetPath,
    this.assetSize = 24,
    required this.items,
  }) : assert(
         icon != null || assetPath != null,
         'You must provide either icon or assetPath for the dropdown trigger',
       ),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;
    final textColor = Theme.of(context).colorScheme.secondary;

    return PopupMenuButton<int>(
      color: Theme.of(context).colorScheme.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => List.generate(items.length, (index) {
        final item = items[index];
        return PopupMenuItem(
          value: index,
          child: Row(
            children: [
              if (item.assetPath != null)
                item.assetPath!.endsWith('.svg')
                    ? SvgPicture.asset(
                        item.assetPath!,
                        width: item.assetSize,
                        height: item.assetSize,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSurface,
                          BlendMode.srcIn,
                        ),
                      )
                    : Image.asset(
                        item.assetPath!,
                        width: item.assetSize,
                        height: item.assetSize,
                      )
              else if (item.icon != null)
                Icon(
                  item.icon,
                  size: item.assetSize,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              const SizedBox(width: 10),
              Text(
                item.label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }),
      onSelected: (index) => items[index].onSelected(),
      child: assetPath != null
          ? (assetPath!.endsWith('.svg')
                ? SvgPicture.asset(
                    assetPath!,
                    width: assetSize,
                    height: assetSize,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  )
                : Image.asset(assetPath!, width: assetSize, height: assetSize))
          : Icon(icon, color: iconColor, size: assetSize),
    );
  }
}
