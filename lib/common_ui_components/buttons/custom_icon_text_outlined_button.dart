import 'package:flutter/material.dart';

class CustomIconTextOutlinedButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const CustomIconTextOutlinedButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.black26),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        alignment: Alignment.centerLeft,
      ),
      icon: Icon(icon, size: 20, color: Colors.black87),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
