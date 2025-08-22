import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/common_ui_components/buttons/custom_svg_icon_button.dart';
import 'package:flutter_chat_ai/core/constants/color_constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShowFeedbackCard extends StatelessWidget {
  final VoidCallback onClose;

  const ShowFeedbackCard({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Feedback",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                  splashRadius: 18,
                ),
              ],
            ),
             Row(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 Align(
                   alignment: Alignment.centerLeft,
                   child: SvgPicture.asset(
                     'assets/logo/icon-elysia-brain.svg',
                     width: 25,
                     height: 25,
                   ),
                 ),
                 SizedBox(width: 8), // Space between icon and text
                 Expanded(
                   child: Text(
                     "Your feedback is much appreciated, "
                         "why have you chosen this rating?",
                     style: TextStyle(
                       fontSize: 13,
                       color: Colors.black87,
                     ),
                   ),
                 ),
               ],
             ),
            SizedBox(height: 12),

            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Type your feedback here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                isDense: true,
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConst.primaryColor,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text("Submit", style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
