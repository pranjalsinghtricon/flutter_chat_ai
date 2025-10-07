import 'package:elysia/features/chat/presentation/widgets/app_shortcut.dart';
import 'package:elysia/features/chat/presentation/widgets/custom_horizontal_scrollanble_card.dart';
import 'package:flutter/material.dart';
import 'package:elysia/features/chat/application/chat_controller.dart';
import 'package:elysia/features/chat/presentation/screens/private_chat.dart';
import 'package:elysia/features/chat/presentation/screens/welcome_message_screen.dart';
import 'package:elysia/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:elysia/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.isPrivate = false});
  final bool isPrivate;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  bool _isInputFocused = false;
  bool _showScrollDownArrow = false;

  @override
  void initState() {
    super.initState();
    // Clear the input field when the chat screen is opened
    _inputController.clear();
    _inputController.addListener(() {
      setState(() {});
    });

    _inputFocusNode.addListener(() {
      setState(() {
        _isInputFocused = _inputFocusNode.hasFocus;
      });
    });

    // Listen to scroll changes to show/hide down arrow
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final threshold = 100.0; // Show arrow when 100px from bottom

      setState(() {
        _showScrollDownArrow = (maxScroll - currentScroll) > threshold;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatControllerProvider);
    final chatState = ref.watch(
      chatRepositoryProvider,
    ); // Watch ChatState instead
    final isStreaming = chatState.isStreaming;

    Future<void> _handleSendMessage() async {
      final text = _inputController.text.trim();
      if (text.isEmpty) return;

      await ref.read(chatControllerProvider.notifier).sendMessage(text, ref);
      _inputController.clear();

      // Scroll to bottom when user sends a message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      children: [
                        // const PrivateChatIndicator(),
                        if (messages.isEmpty && !widget.isPrivate)
                          WelcomeMessageScreen(),
                        if (messages.isEmpty && widget.isPrivate)
                          PrivateChatScreen(),
                        if (messages.isNotEmpty)
                          ...messages.asMap().entries.map((entry) {
                            final index = entry.key;
                            final msg = entry.value;
                            final isLast = index == messages.length - 1;

                            return MessageBubble(
                              message: msg,
                              isLast: isLast,
                              showPrivacyStatement:
                                  isLast && !isStreaming && !msg.isUser,
                            );
                          }),
                      ],
                    ),
                  ),
                  if (messages.isEmpty)
                    if (!_isInputFocused) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            // AppShortcut(
                            //   icon: AssetConsts.iconAiImages,
                            //   label: "AI Images",
                            // ),
                            // AppShortcut(
                            //   icon: AssetConsts.iconAiImages,
                            //   label: "PapagAlo",
                            // ),
                            // AppShortcut(
                            //   icon: AssetConsts.iconCareerCoach,
                            //   label: "Career Coach",
                            // ),
                            // AppShortcut(
                            //   icon: AssetConsts.iconMoreApp,
                            //   label: "More Apps",
                            // ),
                          ],
                        ),
                      ),
                      if (!widget.isPrivate)
                        CustomHorizontalScrollableCard(ref: ref),
                    ]
                    else if (!widget.isPrivate)
                      CustomHorizontalScrollableCard(ref: ref),
                  ChatInputField(
                    controller: _inputController,
                    focusNode: _inputFocusNode,
                    onSend: _handleSendMessage,
                  ),
                ],
              ),

              // Floating scroll down arrow - show when user scrolls up AND there's content below
              if (_showScrollDownArrow && messages.isNotEmpty)
                Positioned(
                  bottom: 100,
                  right: 20,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.black87,
                    onPressed: _scrollToBottom,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
