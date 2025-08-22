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

  final double iconSize;

  final Size? tapTargetSize;

  final EdgeInsetsGeometry padding;

  final EdgeInsetsGeometry backgroundPadding;

  const CustomIconButton({
    super.key,
    this.onPressed,
    this.icon,
    this.svgAsset,
    this.svgColor,
    this.backgroundColor,
    required this.toolTip,
    this.isDense = false,
    this.iconSize = 20,
    this.tapTargetSize,
    this.padding = EdgeInsets.zero,
    this.backgroundPadding = EdgeInsets.zero,
  }) : assert(icon != null || svgAsset != null, 'Provide either icon or svgAsset');

  @override
  Widget build(BuildContext context) {
    final Widget displayedIcon = svgAsset != null
        ? SvgPicture.asset(
      svgAsset!,
      color: svgColor,
      width: iconSize,
      height: iconSize,
    )
        : Icon(icon, size: iconSize, color: svgColor);

    final BoxConstraints constraints = isDense
        ? BoxConstraints.tightFor(
      width: (tapTargetSize?.width ?? iconSize),
      height: (tapTargetSize?.height ?? iconSize),
    )
        : const BoxConstraints(minWidth: 12, minHeight: 12); // Material default

    return Tooltip(
      message: toolTip,
      child: IconButton(
        onPressed: onPressed,
        padding: padding, // zero by default
        constraints: constraints,
        splashRadius: isDense ? (iconSize * 0.7) : null,
        visualDensity: isDense
            ? const VisualDensity(horizontal: -4, vertical: -4)
            : VisualDensity.standard,
        icon: backgroundColor == null
            ? displayedIcon
            : Container(
          padding: backgroundPadding, // zero by default
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
