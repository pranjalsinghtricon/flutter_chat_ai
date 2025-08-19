import 'package:flutter/material.dart';

class PlainAlertDialog extends StatelessWidget {
  const PlainAlertDialog({
    Key? key,
    required this.title,
    required this.child,
    this.padding,
    this.onClose,
  }) : super(key: key);

  final String title;
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      contentPadding: padding ?? const EdgeInsets.all(16),
      content: SizedBox(
        width: MediaQuery.of(context).size.width / 1.1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 Title + Close (X)
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child, // 🔹 Dynamic body
          ],
        ),
      ),
    );
  }
}
