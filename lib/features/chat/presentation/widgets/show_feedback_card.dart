import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/common_ui_components/buttons/custom_svg_icon_button.dart';

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header Row (Title + Close Button)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 4, top: 8, bottom: 4),
              child: Row(
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
            ),

            /// Divider
            // Divider(height: 1, color: Colors.grey.shade300),

            /// Feedback Text
             Padding(
              padding: EdgeInsets.all(2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSvgIconButton(
                    assetPath: 'assets/logo/Elysia-brain.svg',
                    size: 30, // Smaller size like in screenshot
                    // backgroundColor: Colors.white,
                    onPressed: () {
                      print("Elysia logo clicked!");
                    }, // No action needed for this
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
            ),


            /// Feedback Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Type your feedback here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// Submit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
