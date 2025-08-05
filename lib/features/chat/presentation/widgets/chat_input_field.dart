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
      padding: EdgeInsets.all(8.0),
      child: Column(

        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 14.0),
                  child: const Text(
                    'Ask Elysia anything',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Row(

                  children: [

                    IconButton(
                      onPressed: () {

                      },
                      icon: const Icon(Icons.grid_view),
                      color: Colors.grey,

                      constraints: const BoxConstraints(),
                    ),

                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLength: 2000,
                        maxLines: null,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          // hintText: 'Ask Elysia anything',
                          counterText: '',
                          border: InputBorder.none,

                        ),
                      ),
                    ),

                    Text(
                      '${_controller.text.length}/2000',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),

                    // Right arrow button
                    IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.arrow_forward),
                      color: Colors.teal,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),

           SizedBox(height: 4),

          Padding(
            padding:  EdgeInsets.only(top: 5),
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