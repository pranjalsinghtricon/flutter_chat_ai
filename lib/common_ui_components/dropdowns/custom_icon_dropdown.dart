import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom_dropdown_item.dart';

class CustomIconDropdown extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String? assetPath;
  final double assetSize;
  final List<CustomDropdownItem> items;

  const CustomIconDropdown({
    Key? key,
    this.icon,
    this.iconColor,
    this.assetPath,
    this.assetSize = 24,
    required this.items,
  })  : assert(icon != null || assetPath != null,
  'You must provide either icon or assetPath for the dropdown trigger'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                )
                    : Image.asset(
                  item.assetPath!,
                  width: item.assetSize,
                  height: item.assetSize,
                )
              else
                Icon(item.icon, color: item.iconColor),

              const SizedBox(width: 10),
              Text(item.label),
            ],
          ),
        );
      }),
      onSelected: (index) {
        items[index].onSelected();
      },
      child: IconButton(
        icon: assetPath != null
            ? (assetPath!.endsWith('.svg')
            ? SvgPicture.asset(
          assetPath!,
          width: assetSize,
          height: assetSize,
        )
            : Image.asset(
          assetPath!,
          width: assetSize,
          height: assetSize,
        ))
            : Icon(icon, color: iconColor, size: assetSize),
        onPressed: null,
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
