import 'package:elysia/common_ui_components/buttons/custom_card_icon_button.dart';
import 'package:elysia/common_ui_components/cards/simple-brain-loader.dart';
import 'package:elysia/features/chat/application/chat_controller.dart';
import 'package:elysia/features/chat/data/models/message_model.dart';
import 'package:elysia/features/chat/data/repositories/feedback_repository.dart';
import 'package:elysia/common_ui_components/snackbar/custom_snackbar.dart';
import 'package:flutter/material.dart';

import 'package:elysia/providers/audio_playback_provider.dart';
import 'package:flutter/services.dart';
import 'package:elysia/common_ui_components/markdown/custom_markdown_renderer.dart';
import 'package:elysia/utiltities/consts/color_constants.dart';
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
  ConsumerState<CustomAiResponseCard> createState() =>
      _CustomAiResponseCardState();
}

class _CustomAiResponseCardState extends ConsumerState<CustomAiResponseCard> {
  final FeedbackRepository _feedbackRepository = FeedbackRepository();

  bool _showFeedback = false;
  String? _selectedFeedback;
  bool _isSubmittingFeedback = false;
  String _feedbackId = '';

  Future<void> _launchUrl() async {
    final url = Uri.parse(
      'https://login.microsoftonline.com/2567d566-604c-408a-8a60-55d0dc9d9d6b/oauth2/authorize?...',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  void initState() {
    super.initState();

    // Initialize selected feedback if message already has feedback
    if (widget.message.feedback != null) {
      if (widget.message.feedback == 'thumbs_up' ||
          widget.message.feedback == 'thumbs_down') {
        _selectedFeedback = widget.message.feedback;
      }
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.message.content));
    Future.delayed(Duration.zero, () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        showCustomSnackBar(
          context: context,
          message: 'Copied to clipboard',
          icon: Icons.content_copy,
          durationInSeconds: 2,
        );
      }
    });
  }

  Future<void> _handleFeedback(String feedbackType) async {
    if (widget.message.runId == null || widget.message.runId!.isEmpty) {
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          showCustomSnackBar(
            context: context,
            message: 'Unable to submit feedback: Missing run ID',
            icon: Icons.error_outline,
          );
        }
      });
      return;
    }

    setState(() {
      _isSubmittingFeedback = true;
      _selectedFeedback = feedbackType;    
    });

    try {
      setState(() {
        if(_selectedFeedback != null && _selectedFeedback!.isNotEmpty){
          _openFeedbackBottomSheet();
        }      
      });

      // Submit initial feedback (like/dislike)
      _feedbackId = await _feedbackRepository.submitFeedback(
        runId: widget.message.runId!,
        key: feedbackType,
        score: true,
        value: 1,
      );

      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          showCustomSnackBar(
            context: context,
            message: "${feedbackType == 'thumbs_up' ? 'Like' : 'Dislike'} submitted successfully",
            icon: feedbackType == 'thumbs_up' ? Icons.thumb_up_outlined : Icons.thumb_down_outlined,
          );
        }
      });
    } catch (e) {
      print("$e ==================  outside click like or dislike");
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          showCustomSnackBar(
            context: context,
            message: "Failed to submit feedback, Please try again!",
            icon: Icons.error_outline,
          );
        }
      });
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
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          showCustomSnackBar(
            context: context,
            message: "Unable to submit comment: Missing required data",
            icon: Icons.error_outline,
          );
        }
      });
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

      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          showCustomSnackBar(
            context: context,
            message: "Feedback comment submitted successfully",
            icon: Icons.comment_outlined,
          );
        }
      });

      setState(() {
        _selectedFeedback = _selectedFeedback!.isNotEmpty ? _selectedFeedback : '';
      });
    } catch (e) {
      print(
        "Feedback comment repository error: $e ",
      );
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          showCustomSnackBar(
            context: context,
            message: "Failed to submit comment, Please try again!",
            icon: Icons.error_outline,
          );
        }
      });
    } finally {
      setState(() {
        _isSubmittingFeedback = false;
      });
    }
  }

  void _openFeedbackBottomSheet() {
    final TextEditingController controller = TextEditingController();
    final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        controller.addListener(() {
          isButtonEnabled.value = controller.text.trim().isNotEmpty;
        });

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Help us improve - what made you choose this rating?",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(
                          color: Color(0xFFDDDDDD),
                          width: 1,
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: ColorConst.primaryBlack),
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: isButtonEnabled,
                    builder: (context, enabled, _) {
                      return FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: ColorConst.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: enabled
                            ? () {
                                _submitFeedbackComment(controller.text);
                                Navigator.pop(context);
                              }
                            : null, // disables the button
                        child: const Text("Submit"),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
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
      'Arabic': 'ar',
      'Japanese': 'ja-JP',
      'German': 'de-DE',
      'French': 'fr-FR',
      'Dutch': 'nl-NL',
    };
    final locale = languageToLocale[lang].toString();
    final voices = await audioNotifier.state.tts.getVoices;
    final filtered = voices
        .where(
          (voice) =>
              (voice['gender']?.toLowerCase() == 'female') &&
              (voice['locale']?.toLowerCase() == locale.toLowerCase()),
        )
        .toList();
    final selectedVoice = filtered.isNotEmpty
        ? {"name": filtered.first['name'], "locale": filtered.first['locale']}
        : null;

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
    // final chatState = ref.watch(chatRepositoryProvider);

    final isGeneratingResponse = widget.message.isGenerating;

    final shouldShowFeedbackButtons =
        !isGeneratingResponse &&
            widget.message.content.isNotEmpty &&
            !widget.message.isUser;

    final audioState = ref.watch(audioPlaybackProvider);
    final messageId = widget.message.runId ?? widget.message.id;
    // final isThisAudioPlaying =
    //     audioState.isPlaying && audioState.messageId == messageId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isGeneratingResponse
                  ? const SimpleBrainLoader(size: 14, showCircle: true)
                  : SvgPicture.asset(
                AssetConsts.elysiaBrainSvg,
                width: 22,
                height: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isGeneratingResponse
                      ? "Elysia is generating response..."
                      : "",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),

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
                  // tooltip: '',
                ),
                CustomCardIconButton(
                  onPressed: _isSubmittingFeedback
                      ? () {}
                      : () => _handleFeedback(
                          _selectedFeedback == 'thumbs_up'
                              ? ''
                              : 'thumbs_up'),
                  icon: _selectedFeedback == 'thumbs_up'
                      ? Icons.thumb_up
                      : Icons.thumb_up_outlined,
                  // tooltip: '',
                ),
                CustomCardIconButton(
                  onPressed: _isSubmittingFeedback
                      ? () {}
                      : () => _handleFeedback(
                          _selectedFeedback == 'thumbs_down'
                              ? ''
                              : 'thumbs_down'),
                  icon: _selectedFeedback == 'thumbs_down'
                      ? Icons.thumb_down
                      : Icons.thumb_down_outlined,
                  // tooltip: '',
                ),
                CustomCardIconButton(
                  onPressed: () {},
                  icon: Icons.info_outline,
                  tooltip: "Response generated using ${widget.message.responseModel} and ${widget.message.readAloudLanguage} language.",
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final audioState = ref.watch(audioPlaybackProvider);
                    final messageId = widget.message.runId ?? widget.message.id;
                    final isThisAudioPlaying =
                        audioState.isPlaying &&
                            audioState.messageId == messageId;
                    return Container(
                      decoration: BoxDecoration(
                        color: isThisAudioPlaying
                            ? Colors.blue.withValues(alpha: 0.2)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: CustomCardIconButton(
                        onPressed: () =>
                            _handleReadAloud(widget.message.content),
                        icon: Icons.volume_up_outlined,
                        // tooltip: isThisAudioPlaying
                        //     ? ''
                        //     : '',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
