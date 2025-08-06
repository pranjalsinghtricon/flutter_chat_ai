import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/common_ui_components/dropdowns/custom_dropdown_item.dart';

class CustomTextDropdown extends StatelessWidget {
  final String buttonText;
  final List<CustomDropdownItem> items;

   CustomTextDropdown({
    Key? key,
    required this.buttonText,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 40),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),

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
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
