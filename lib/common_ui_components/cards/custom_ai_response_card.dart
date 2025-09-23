import 'package:elysia/common_ui_components/buttons/custom_card_icon_button.dart';
import 'package:elysia/common_ui_components/cards/simple-brain-loader.dart';
import 'package:elysia/features/chat/application/chat_controller.dart';
import 'package:elysia/features/chat/data/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elysia/common_ui_components/buttons/custom_icon_button.dart';
import 'package:elysia/common_ui_components/markdown/custom_markdown_renderer.dart';
import 'package:elysia/features/chat/presentation/widgets/show_feedback_card.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomAiResponseCard extends ConsumerStatefulWidget {
  final Message message;
  final bool isStreaming; // This parameter can be removed now
  final ValueChanged<Message>? onMessageUpdated;

  const CustomAiResponseCard({
    super.key,
    required this.message,
    required this.isStreaming,
    this.onMessageUpdated,
  });

  @override
  ConsumerState<CustomAiResponseCard> createState() => _CustomAiResponseCardState();
}

class _CustomAiResponseCardState extends ConsumerState<CustomAiResponseCard> {
  Future<void> _launchUrl() async {
    final url = Uri.parse(
      'https://login.microsoftonline.com/2567d566-604c-408a-8a60-55d0dc9d9d6b/oauth2/authorize?...',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

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
    final chatState = ref.watch(chatRepositoryProvider);

    // Check if THIS specific message is currently streaming
    final isThisMessageStreaming = chatState.isStreaming &&
        chatState.streamingMessageId == widget.message.id;

    // Show as empty and streaming if this message is being streamed and has no content yet
    final isCurrentlyStreaming = isThisMessageStreaming && widget.message.content.isEmpty;

    // Show feedback buttons only when:
    // 1. NOT currently streaming any message
    // 2. This message has content
    // 3. This message is not from user
    final shouldShowFeedbackButtons = !chatState.isStreaming &&
        widget.message.content.isNotEmpty &&
        !widget.message.isUser;

    debugPrint("📡 ===== Message ID: ${widget.message.id} =====");
    debugPrint("📡 ===== isCurrentlyStreaming: $isCurrentlyStreaming =====");
    debugPrint("📡 ===== isThisMessageStreaming: $isThisMessageStreaming =====");
    debugPrint("📡 ===== shouldShowFeedbackButtons: $shouldShowFeedbackButtons =====");
    debugPrint("📡 ===== streamingMessageId: ${chatState.streamingMessageId} =====");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isCurrentlyStreaming || isThisMessageStreaming
                  ?       const SimpleBrainLoader(
                size: 12, // Slightly larger to accommodate the circle
                showCircle: true,
              )
                  : SvgPicture.asset(
                AssetConsts.elysiaBrainSvg,
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  (isCurrentlyStreaming || isThisMessageStreaming)
                      ? "Elysia is generating response..."
                      : "Elysia's response",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: (isCurrentlyStreaming || isThisMessageStreaming)
                        ? FontWeight.w400
                        : FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Show content when available
        if (widget.message.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: CustomMarkdownRenderer(data: widget.message.content),
          ),

        if (shouldShowFeedbackButtons)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomCardIconButton(
                  onPressed: _copyToClipboard,
                  icon: Icons.content_copy_outlined,
                  tooltip: 'Copy',
                ),
                CustomCardIconButton(
                  onPressed: _toggleFeedback,
                  icon: Icons.thumb_up_outlined,
                  tooltip: 'Like',
                ),
                CustomCardIconButton(
                  onPressed: _toggleFeedback,
                  icon: Icons.thumb_down_outlined,
                  tooltip: 'Dislike',
                ),
                CustomCardIconButton(
                  onPressed: () {/* Info action */},
                  icon: Icons.info_outline,
                  tooltip: 'Info',
                ),
                CustomCardIconButton(
                  onPressed: () {/* Sound action */},
                  icon: Icons.volume_up_outlined,
                  tooltip: 'Read aloud',
                ),
              ],
            ),
          ),


        // Centered disclaimer message - only show when feedback buttons are shown
        // if (shouldShowFeedbackButtons)
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //     child: Center(
        //       child: Text(
        //         "Elysia responses may be inaccurate. Know more about how your data is processed here",
        //         textAlign: TextAlign.center,
        //         style: TextStyle(
        //           fontSize: 12,
        //           color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        //         ),
        //       ),
        //     ),
        //   ),

        // Show feedback card when toggled
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