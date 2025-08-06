import 'package:flutter/material.dart';

class CustomDropdownItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onSelected;

  CustomDropdownItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onSelected,
  });
}
