import 'package:flutter/material.dart';

class CustomCardIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;
  final Color? iconColor;
  final Color? backgroundColor;

  const CustomCardIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.tooltip,
    this.iconColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28, // Compact size
      height: 28,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: iconColor ?? Colors.grey.shade600),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
        highlightColor: backgroundColor ?? Colors.transparent,
        splashColor: backgroundColor ?? Colors.transparent,
        splashRadius: 16,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
