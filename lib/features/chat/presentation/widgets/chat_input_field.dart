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
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.grid_view, color: Colors.grey),
              ),
              // Text field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLength: 2000,
                          maxLines: null,
                          onChanged: (_) {
                            setState(() {});
                          },
                          onSubmitted: (_) => _send(),
                          decoration: const InputDecoration(
                            hintText: 'Ask Elysia anything',
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward, color: Colors.grey.shade700),
                        onPressed: _send,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Character count
          Padding(
            padding: const EdgeInsets.only(left: 36.0),
            child: Text(
              '${_controller.text.length}/2000',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );

  }
}