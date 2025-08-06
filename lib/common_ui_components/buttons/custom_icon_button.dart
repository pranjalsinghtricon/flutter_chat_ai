import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? svgAsset;
  final Color? svgColor;
  final Color? backgroundColor;
  final String toolTip;
  final bool isDense;

  const CustomIconButton({
    Key? key,
    this.onPressed,
    this.icon,
    this.svgAsset,
    this.svgColor,
    this.backgroundColor,
    required this.toolTip,
    this.isDense = false,
  })  : assert(icon != null || svgAsset != null, 'Provide either icon or svgAsset'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget displayedIcon = svgAsset != null
        ? SvgPicture.asset(
      svgAsset!,
      color: svgColor,
      width: 20,
      height: 20,
    )
        : Icon(icon, size: 20, color: svgColor);

    return Tooltip(
      message: toolTip,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: isDense ? const BoxConstraints() : null,
        onPressed: onPressed,
        icon: backgroundColor == null
            ? displayedIcon
            : Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
          ),
          child: displayedIcon,
        ),
      ),
    );
  }
}
