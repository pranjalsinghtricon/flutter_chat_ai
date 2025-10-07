import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconTextOutlinedButton extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final String text;
  final VoidCallback onPressed;

  const CustomIconTextOutlinedButton({
    super.key,
    this.icon,
    this.assetPath,
    required this.text,
    required this.onPressed,
  }) : assert(
         icon != null || assetPath != null,
         'Either icon or assetPath must be provided.',
       );

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outline;
    Widget iconWidget;
    if (icon != null) {
      iconWidget = Icon(icon, size: 20, color: Colors.black87);
    } else if (assetPath != null) {
      if (assetPath!.toLowerCase().endsWith('.svg')) {
        iconWidget = SvgPicture.asset(
          assetPath!,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onSurface,
            BlendMode.srcIn,
          ),
        );
      } else {
        iconWidget = Image.asset(assetPath!, width: 20, height: 20);
      }
    } else {
      iconWidget = const SizedBox(width: 20, height: 20);
    }

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        alignment: Alignment.centerLeft,
      ),
      icon: iconWidget,
      label: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
