import 'package:flutter/material.dart';
import 'custom_dropdown_item.dart'; // adjust the path based on your folder structure

class CustomIconDropdown extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final List<CustomDropdownItem> items;

  const CustomIconDropdown({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      // offset: const Offset(0, -140), // opens above the button (adjust as needed)
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
        icon: Icon(icon, color: iconColor),
        onPressed: null, // PopupMenuButton handles onPressed internally
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
      ),
    );
  }
}