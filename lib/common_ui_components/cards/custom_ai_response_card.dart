import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/common_ui_components/buttons/custom_icon_button.dart';
import 'package:flutter_chat_ai/data/models/message_model.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/show_feedback_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAiResponseCard extends StatefulWidget {
  final Message message;
  final ValueChanged<Message>? onMessageUpdated;

  const CustomAiResponseCard({
    super.key,
    required this.message,
    this.onMessageUpdated,
  });

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

  void _copyToClipboard() {
    // Example: You can use clipboard API
    // Clipboard.setData(ClipboardData(text: widget.message.content));
    debugPrint("Copied: ${widget.message.content}");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26, width: 1),
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
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
                      child: SvgPicture.asset(
                        'assets/logo/Elysia-logo.svg',
                        width: 25,
                        height: 25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.message.content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          svgColor: Colors.grey,
                          toolTip: 'Copy',
                          onPressed: _copyToClipboard,
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
