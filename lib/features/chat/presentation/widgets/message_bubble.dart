import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/common_ui_components/cards/custom_ai_response_card.dart';
import 'package:flutter_chat_ai/data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.content,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      return CustomAiResponseCard(message: message.content);
    }
  }
}
