import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppbarIconButton extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const CustomAppbarIconButton({
    Key? key,
    required this.assetPath,
    required this.size,
    required this.iconColor,
    required this.backgroundColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: SvgPicture.asset(
            assetPath,
            width: size,
            height: size,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
