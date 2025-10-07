import 'package:flutter/material.dart';

class CustomDropdownItem {
  final IconData? icon;
  final Color? iconColor;
  final String? assetPath;
  final double assetSize;
  final String label;
  final VoidCallback onSelected;

  CustomDropdownItem({
    this.icon,
    this.iconColor,
    this.assetPath,
    this.assetSize = 20,
    required this.label,
    required this.onSelected,
  }) : assert(
         icon != null || assetPath != null,
         'You must provide either an icon or an assetPath',
       );
}
