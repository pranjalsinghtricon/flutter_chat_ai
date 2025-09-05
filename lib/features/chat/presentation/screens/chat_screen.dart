import 'package:flutter/material.dart';
import 'package:elysia/features/chat/application/chat_controller.dart';
import 'package:elysia/features/chat/presentation/screens/private_chat.dart';
import 'package:elysia/features/chat/presentation/screens/welcome_message_screen.dart';
import 'package:elysia/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:elysia/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.isPrivate = false});
  final bool isPrivate;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatControllerProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque, // ensures taps are detected anywhere
          onTap: () => FocusScope.of(context).unfocus(), //dismiss keyboard
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    if (messages.isEmpty && !widget.isPrivate)
                      const WelcomeMessageScreen(),
                    if (messages.isEmpty && widget.isPrivate)
                      const PrivateChatScreen(),
                    if (messages.isNotEmpty)
                      ...messages.map(
                            (msg) => MessageBubble(message: msg),
                      ),
                  ],
                ),
              ),
              const ChatInputField(),
            ],
          ),
        ),
      ),
    );
  }
}
