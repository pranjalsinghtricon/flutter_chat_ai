import 'package:elysia/features/chat/data/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elysia/common_ui_components/buttons/custom_icon_button.dart';
import 'package:elysia/common_ui_components/markdown/custom_markdown_renderer.dart';
import 'package:elysia/features/chat/presentation/widgets/show_feedback_card.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAiResponseCard extends StatefulWidget {
  final Message message;
  final bool isGenerating;
  final ValueChanged<Message>? onMessageUpdated;

  const CustomAiResponseCard({
    super.key,
    required this.message,
    required this.isGenerating,
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
    Clipboard.setData(ClipboardData(text: widget.message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Copied to clipboard"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGenerating = widget.isGenerating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AssetConsts.elysiaBrainSvg,
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isGenerating
                      ? "Elyria is creating response for you..."
                      : "Elysia’s response",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isGenerating ? FontWeight.w400 : FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (!isGenerating)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: CustomMarkdownRenderer(data: widget.message.content),
          ),

        if (!isGenerating)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomIconButton(
                  icon: Icons.info_outline,
                  svgColor: Colors.grey,
                  toolTip: 'Info',
                  onPressed: () {},
                  isDense: true,
                ),
                CustomIconButton(
                  icon: Icons.thumb_up_alt_outlined,
                  svgColor: Colors.grey,
                  toolTip: 'Like',
                  onPressed: _toggleFeedback,
                  isDense: true,
                  iconSize: 18,
                ),
                CustomIconButton(
                  icon: Icons.thumb_down_alt_outlined,
                  svgColor: Colors.grey,
                  toolTip: 'Dislike',
                  onPressed: _toggleFeedback,
                  isDense: true,
                  iconSize: 18,
                ),
                CustomIconButton(
                  icon: Icons.copy,
                  svgColor: Colors.grey,
                  toolTip: 'Copy',
                  onPressed: _copyToClipboard,
                  isDense: true,
                  iconSize: 18,
                ),
              ],
            ),
          ),

        if (!isGenerating)
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 12),
            child: Text(
              "Elysia responses may be inaccurate. Know more about how your data is processed here",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center, // ✅ Center-aligns multi-line text
            ),
          ),

        /// Feedback Card (if toggled)
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
