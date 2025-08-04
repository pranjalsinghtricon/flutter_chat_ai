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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  maxLength: 2000,
                  maxLines: null,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    hintText: 'Ask Elysia anything',
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                Row(
                  children: [
                    // Left clickable icon
                    IconButton(
                      onPressed: () {
                        // Your custom action (e.g. open quick prompts)
                      },
                      icon: const Icon(Icons.grid_view),
                      color: Colors.grey,
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(),
                    ),

                    // Text field
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLength: 2000,
                        maxLines: null,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Ask Elysia anything',
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    // Right arrow button
                    IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.arrow_forward),
                      color: Colors.teal, // adjust to match your app theme
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Character counter below input
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              '${_controller.text.length}/2000',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              'Elysia responses may be inaccurate. Know more about how your data is processed here.',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey
              ),
            ),
          )
        ],
      ),
    );

  }
}