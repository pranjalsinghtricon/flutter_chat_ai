import 'package:flutter/material.dart';

class CustomPopover {
  static OverlayEntry? _entry;

  static void show({
    required BuildContext context,
    required TapDownDetails tapDownDetails,
    required List<Widget> children,
    double width = 200,
    double verticalOffset = 6,
  }) {
    // First remove any existing entry
    hide();

    final RenderBox overlayBox = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset globalPosition = tapDownDetails.globalPosition;

    _entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 🔴 Background tap detector
          Positioned.fill(
            child: GestureDetector(
              onTap: hide,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
          ),

          // 🟢 Popover
          Positioned(
            top: globalPosition.dy + verticalOffset,
            left: globalPosition.dx - width + 40, // Adjust for right alignment
            child: Material(
              color: Colors.white,
              elevation: 6,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
