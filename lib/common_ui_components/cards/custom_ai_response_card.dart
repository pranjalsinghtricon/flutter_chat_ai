import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/common_ui_components/buttons/custom_icon_button.dart';
import 'package:flutter_chat_ai/common_ui_components/buttons/custom_svg_icon_button.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/show_feedback_card.dart';

class CustomAiResponseCard extends StatefulWidget {
  final String message;

  const CustomAiResponseCard({Key? key, required this.message})
      : super(key: key);

  @override
  State<CustomAiResponseCard> createState() => _CustomAiResponseCardState();
}

class _CustomAiResponseCardState extends State<CustomAiResponseCard> {
  bool _showFeedback = false;

  void _toggleFeedback() {
    setState(() {
      _showFeedback = !_showFeedback;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Main AI Response Container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.teal, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomSvgIconButton(
                        assetPath: 'assets/logo/Elysia-logo.svg',
                        size: 25,
                        iconColor: Colors.blue,
                        backgroundColor: Colors.white,
                        tooltip: "Open Elysia",
                        onPressed: () {
                          print("Elysia logo clicked!");
                        },
                      ),
                    ),
                    Text(
                      widget.message,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              /// Divider
              Container(
                height: 1,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),

              /// Footer Row
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomIconButton(
                      icon: Icons.info_outline,
                      svgColor: Colors.grey,
                      toolTip: 'Info',
                      onPressed: () {},
                      isDense: true,
                    ),
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Text(
                            "Share Feedback:",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        CustomIconButton(
                          icon: Icons.thumb_up_alt_outlined,
                          svgColor: Colors.grey,
                          toolTip: 'Like',
                          onPressed: _toggleFeedback,
                          isDense: true,
                        ),
                        CustomIconButton(
                          icon: Icons.thumb_down_alt_outlined,
                          svgColor: Colors.grey,
                          toolTip: 'Dislike',
                          onPressed: _toggleFeedback,
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
              ),
            ],
          ),
        ),

        /// Separate Feedback Card below the container
        if (_showFeedback)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ShowFeedbackCard(
              onClose: () {
                setState(() {
                  _showFeedback = false;
                });
              },
            ),
          ),
      ],
    );
  }
}
