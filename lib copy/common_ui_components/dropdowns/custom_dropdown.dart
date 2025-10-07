import 'package:elysia/common_ui_components/dropdowns/custom_dropdown_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomTextDropdown extends StatelessWidget {
  final String buttonText;
  final List<CustomDropdownItem> items;

  const CustomTextDropdown({
    Key? key,
    required this.buttonText,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 40),
      color: Theme.of(context).colorScheme.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      itemBuilder: (context) => List.generate(items.length, (index) {
        final item = items[index];
        final iconColor = Theme.of(context).colorScheme.onSurface;
        final textColor = Theme.of(context).colorScheme.secondary;

        return PopupMenuItem(
          value: index,
          child: Row(
            children: [
              if (item.icon != null)
                Icon(item.icon, color: iconColor, size: item.assetSize),
              if (item.assetPath != null)
                item.assetPath!.endsWith('.svg')
                    ? SvgPicture.asset(
                        item.assetPath!,
                        width: item.assetSize,
                        height: item.assetSize,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      )
                    : Image.asset(
                        item.assetPath!,
                        width: item.assetSize,
                        height: item.assetSize,
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
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }
}
