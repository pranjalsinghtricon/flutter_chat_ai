import 'package:elysia/common_ui_components/buttons/custom_icon_button.dart';
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
      contentPadding: padding ?? const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 16),
      content: SizedBox(
        width: MediaQuery.of(context).size.width / 1.1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                CustomIconButton(
                  icon: Icons.close,
                  svgColor: Colors.black87,
                  toolTip: 'Close',
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                  isDense: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
