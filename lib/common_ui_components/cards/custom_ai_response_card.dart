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
  final bool isStreaming;
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
  bool _hasReceivedMetadata = false; // Track if we've received metadata (streaming complete)

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
    final chatRepository = ref.watch(chatRepositoryProvider);
    final isCurrentlyStreaming = chatRepository.isStreaming && widget.message.content.isEmpty;

    // Check if this is the last message and streaming has finished
    final isStreamingForThisMessage = chatRepository.isStreaming &&
        widget.message.content.isNotEmpty &&
        !widget.message.isUser;

    // Show feedback when streaming is complete and message has content
    final shouldShowFeedbackButtons = !chatRepository.isStreaming &&
        widget.message.content.isNotEmpty &&
        !widget.message.isUser;

    debugPrint("📡 =====  isCurrentlyStreaming in MessageBubble: $isCurrentlyStreaming ====");
    debugPrint("📡 =====  shouldShowFeedbackButtons: $shouldShowFeedbackButtons ====");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isCurrentlyStreaming || isStreamingForThisMessage
                  ? SvgPicture.asset(
                AssetConsts.elysiaBrainLoaderSvg,
                width: 22,
                height: 22,
              )
                  : SvgPicture.asset(
                AssetConsts.elysiaBrainSvg,
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  (isCurrentlyStreaming || isStreamingForThisMessage)
                      ? "Elysia is generating response..."
                      : "Elysia's response",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: (isCurrentlyStreaming || isStreamingForThisMessage)
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

        // Show feedback buttons only when streaming is completely done
        if (shouldShowFeedbackButtons)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                CustomIconButton(
                  svgAsset: AssetConsts.iconCopy,
                  toolTip: 'Copy',
                  onPressed: _copyToClipboard,
                ),
                const SizedBox(width: 8),
                CustomIconButton(
                  svgAsset: AssetConsts.iconLike,
                  toolTip: 'Like',
                  onPressed: _toggleFeedback,
                ),
                const SizedBox(width: 8),
                CustomIconButton(
                  svgAsset: AssetConsts.iconDislike,
                  toolTip: 'Dislike',
                  onPressed: _toggleFeedback,
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