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
    // Check if this specific message is currently streaming
    final chatRepository = ref.watch(chatRepositoryProvider);
    final isCurrentlyStreaming = chatRepository.isStreaming && widget.message.content.isEmpty;

    debugPrint("📡 =====  isCurrentlyStreaming in MessageBubble: $isCurrentlyStreaming ====");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isCurrentlyStreaming
                  ? SvgPicture.asset(
          AssetConsts.elysiaBrainLoaderSvg,
            width: 22,
            height: 22,
          )
                  : SvgPicture.asset(
                AssetConsts.elysiaBrainLoaderSvg,
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCurrentlyStreaming
                      ? "Elysia is generating response..."
                      : "Elysia's response",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    isCurrentlyStreaming ? FontWeight.w400 : FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (!isCurrentlyStreaming && widget.message.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: CustomMarkdownRenderer(data: widget.message.content),
          ),

        if (isCurrentlyStreaming && widget.message.content.isNotEmpty)
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