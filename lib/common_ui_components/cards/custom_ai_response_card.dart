import 'package:elysia/common_ui_components/buttons/custom_card_icon_button.dart';
import 'package:elysia/common_ui_components/cards/simple-brain-loader.dart';
import 'package:elysia/features/chat/application/chat_controller.dart';
import 'package:elysia/features/chat/data/models/message_model.dart';
import 'package:elysia/features/chat/data/repositories/feedback_repository.dart';
import 'package:flutter/material.dart';

import 'package:elysia/providers/audio_playback_provider.dart';
import 'package:flutter/services.dart';
import 'package:elysia/common_ui_components/buttons/custom_icon_button.dart';
import 'package:elysia/common_ui_components/markdown/custom_markdown_renderer.dart';
import 'package:elysia/features/chat/presentation/widgets/show_feedback_card.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/utiltities/core/storage.dart';

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
  final FeedbackRepository _feedbackRepository = FeedbackRepository();

  bool _showFeedback = false;
  String? _selectedFeedback; // "thumbs_up" or "thumbs_down"
  bool _isSubmittingFeedback = false;

  Future<void> _launchUrl() async {
    final url = Uri.parse(
      'https://login.microsoftonline.com/2567d566-604c-408a-8a60-55d0dc9d9d6b/oauth2/authorize?...',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

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

  Future<void> _handleFeedback(String feedbackType) async {
    if (widget.message.runId == null || widget.message.runId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to submit feedback: Missing run ID"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingFeedback = true;
      _selectedFeedback = feedbackType;
      _showFeedback = true;
    });

    try {
      // Submit initial feedback (like/dislike)
      await _feedbackRepository.submitFeedback(
        runId: widget.message.runId!,
        key: feedbackType,
        score: true,
        value: 1,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${feedbackType == 'thumbs_up' ? 'Like' : 'Dislike'} submitted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print( "$e ==================  outside click like or dislike"  );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit feedback: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmittingFeedback = false;
      });
    }
  }

  Future<void> _submitFeedbackComment(String comment) async {
    if (widget.message.runId == null ||
        widget.message.runId!.isEmpty ||
        _selectedFeedback == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to submit comment: Missing required data"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingFeedback = true;
    });

    try {
      await _feedbackRepository.submitFeedbackComment(
        runId: widget.message.runId!,
        key: _selectedFeedback!,
        score: true,
        value: 1,
        comment: comment,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Feedback comment submitted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _showFeedback = false;
        _selectedFeedback = null;
      });
    } catch (e) {
      print("Feedback comment repository error: $e ========== == == == == = ========");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit comment: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmittingFeedback = false;
      });
    }
  }

  Future<void> _handleReadAloud(String text) async {
    final audioNotifier = ref.read(audioPlaybackProvider.notifier);
    final lang = widget.message.readAloudLanguage.toString();
    final languageToLocale = {
      'English (UK)': 'en-GB',
      'English (US)': 'en-US',
      'Portuguese': 'pt-PT',
      'Simplified Chinese': 'zh-CN',
      'Spanish': 'es-ES',
      'Turkish': 'tr-TR',
      'Arabic': 'ar-SA',
      'Japanese': 'ja-JP',
      'German': 'de-DE',
      'French': 'fr-FR',
      'Dutch': 'nl-NL',
    };
    final locale = languageToLocale[lang].toString();
    final voices = await audioNotifier.state.tts.getVoices;
    final filtered = voices.where((voice) =>
      (voice['gender']?.toLowerCase() == 'female') &&
      (voice['locale']?.toLowerCase() == locale.toLowerCase())
    ).toList();
    final selectedVoice = filtered.isNotEmpty ? {
      "name": filtered.first['name'],
      "locale": filtered.first['locale'],
    } : null;

    final messageId = widget.message.runId ?? widget.message.id;
    final audioState = ref.read(audioPlaybackProvider);
    if (audioState.isPlaying && audioState.messageId == messageId) {
      await audioNotifier.stop();
      return;
    }
    await audioNotifier.play(messageId, text, locale, selectedVoice);
    // Force rebuild so background color updates immediately
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatRepositoryProvider);

    final isThisMessageStreaming = chatState.isStreaming &&
        chatState.streamingMessageId == widget.message.runId;

    final isCurrentlyStreaming = isThisMessageStreaming && widget.message.content.isEmpty;

    final shouldShowFeedbackButtons = !isThisMessageStreaming &&
        widget.message.content.isNotEmpty &&
        !widget.message.isUser;

    final audioState = ref.watch(audioPlaybackProvider);
    final messageId = widget.message.runId ?? widget.message.id;
    final isThisAudioPlaying = audioState.isPlaying && audioState.messageId == messageId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isCurrentlyStreaming || isThisMessageStreaming
                  ? const SimpleBrainLoader(
                size: 14,
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
                    fontSize: 14,
                    fontWeight: (isCurrentlyStreaming || isThisMessageStreaming)
                        ? FontWeight.w400
                        : FontWeight.w400,
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

        // Feedback buttons
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
                  // onPressed: _isSubmittingFeedback ? () {} : () => _handleFeedback('thumbs_up'),
                  onPressed: (){},
                  icon: _selectedFeedback == 'thumbs_up'
                      ? Icons.thumb_up
                      : Icons.thumb_up_outlined,
                  tooltip: 'Like',
                ),
                CustomCardIconButton(
                  // onPressed: _isSubmittingFeedback ? () {} : () => _handleFeedback('thumbs_down'),
                  onPressed: (){},
                  icon: _selectedFeedback == 'thumbs_down'
                      ? Icons.thumb_down
                      : Icons.thumb_down_outlined,
                  tooltip: 'Dislike',
                ),
                CustomCardIconButton(
                  onPressed: () {/* Info action */},
                  icon: Icons.info_outline,
                  tooltip: 'Info',
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final audioState = ref.watch(audioPlaybackProvider);
                    final messageId = widget.message.runId ?? widget.message.id;
                    final isThisAudioPlaying = audioState.isPlaying && audioState.messageId == messageId;
                    return Container(
                      decoration: BoxDecoration(
                        color: isThisAudioPlaying ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: CustomCardIconButton(
                        onPressed: () => _handleReadAloud(widget.message.content),
                        icon: Icons.volume_up_outlined,
                        tooltip: isThisAudioPlaying ? 'Stop audio' : 'Read aloud',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

        // Show feedback card when toggled
        if (_showFeedback)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ShowFeedbackCard(
              onClose: () {
                setState(() {
                  _showFeedback = false;
                  _selectedFeedback = null;
                });
              },
              onSubmit: _submitFeedbackComment,
              isLoading: _isSubmittingFeedback,
            ),
          ),
      ],
    );
  }
}