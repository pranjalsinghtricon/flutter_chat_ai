import 'package:flutter/material.dart';

class InfoTooltip {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context, String message, {Offset? tapPosition}) {
    // Hide if already showing
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      hide();
      return;
    }

    final overlay = Overlay.of(context);

    // Default position if tapPosition not provided
    final Offset position = tapPosition ?? Offset(100, 100);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Dismiss when tapping outside
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: hide,
              child: Container(color: Colors.transparent),
            ),
          ),

          // Tooltip positioned near the tap
          Positioned(
            left: position.dx + 6, // slightly right of the tap
            top: position.dy - 4,  // slightly above
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(maxWidth: 220),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 6,
                      color: Colors.black26,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
