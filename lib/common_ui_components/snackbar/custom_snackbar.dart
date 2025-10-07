import 'package:flutter/material.dart';

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  required IconData icon,
  int durationInSeconds = 5,
}) {
  // Find the overlay
  final overlay = Overlay.of(context);

  final entry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) => Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          ),
          child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    ),
  ),
  );

  // Insert the overlay entry
  overlay.insert(entry);

  // Remove after duration with fade-out animation
  Future.delayed(Duration(seconds: durationInSeconds - 1), () {
    if (entry.mounted) {
      entry.remove();
    }
  });
}
