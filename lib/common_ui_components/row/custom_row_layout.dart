import 'package:flutter/material.dart';

class CustomRowLayout extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap; // for clickable rows (like Opt-In / Social)

  const CustomRowLayout({
    Key? key,
    required this.label,
    required this.value,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  // color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        // color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onTap != null)
                    const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
