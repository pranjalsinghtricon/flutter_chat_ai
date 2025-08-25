import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/features/chat/application/chat_controller.dart';
import 'package:flutter_chat_ai/features/chat/presentation/screens/private_chat.dart';
import 'package:flutter_chat_ai/features/chat/presentation/screens/welcome_message_screen.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/message_bubble.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_ai/features/chat/data/models/message_model.dart';


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

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? (widget.isPrivate ? const PrivateChatScreen() : const WelcomeMessageScreen())
                : ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) => MessageBubble(message: messages[index]),
            ),
          ),
          const ChatInputField(),
        ],
      ),
    );
  }
}