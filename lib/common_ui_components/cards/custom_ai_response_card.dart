import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/common_ui_components/buttons/custom_icon_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAiResponseCard extends StatelessWidget {
  final String message;

  const CustomAiResponseCard({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Message
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomIconButton(
                  icon: Icons.info_outline,
                  svgColor: Colors.grey,
                  toolTip: 'Info',
                  onPressed: () {},
                  isDense: true,
                ),
                 Text("Share Feedback:", style: TextStyle(fontSize: 13)),

                Row(
                  children: [
                    CustomIconButton(
                      // svgAsset: 'assets/icons/like.svg',
                      icon: Icons.thumb_down_alt_outlined,
                      svgColor: Colors.grey,
                      toolTip: 'Like',
                      onPressed: () {},
                      isDense: true,
                    ),
                    CustomIconButton(
                      icon: Icons.thumb_up_alt_outlined,
                      svgColor: Colors.grey,
                      toolTip: 'Dislike',
                      onPressed: () {},
                      isDense: true,
                    ),
                    CustomIconButton(
                      icon: Icons.copy,
                      svgColor: Colors.black,
                      toolTip: 'Copy',
                      onPressed: () {},
                      isDense: true,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

