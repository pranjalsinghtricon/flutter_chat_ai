import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/features/chat/application/chat_controller.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Aria")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                return MessageBubble(message: msg);
              },
            ),
          ),
          ChatInputField(),
        ],
      ),
    );
  }
}
