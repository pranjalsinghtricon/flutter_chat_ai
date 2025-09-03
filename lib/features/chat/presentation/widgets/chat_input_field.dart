import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/features/chat/application/chat_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatInputField extends ConsumerStatefulWidget {
  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  final _controller = TextEditingController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatControllerProvider.notifier).sendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Ask something...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}