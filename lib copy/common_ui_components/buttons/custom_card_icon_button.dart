import 'package:flutter/material.dart';
import 'package:elysia/common_ui_components/tooltip/info_tooltip.dart';

class CustomCardIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? iconColor;
  final Color? backgroundColor;

  const CustomCardIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.iconColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (TapDownDetails details) {
          if (tooltip != null) {
            InfoTooltip.show(
              context,
              tooltip!,
              tapPosition: details.globalPosition,
            );
          }
        },
        onTap: onPressed,
        child: Container(
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: iconColor ?? Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}