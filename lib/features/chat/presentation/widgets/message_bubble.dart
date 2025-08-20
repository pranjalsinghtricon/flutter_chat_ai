import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/common_ui_components/cards/custom_ai_response_card.dart';
import 'package:flutter_chat_ai/data/models/chat_model/message_model.dart';
import 'package:flutter_chat_ai/common_ui_components/cards/custom_user_query_card.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return CustomUserQueryCard(
        initials: "AR",
        message: message.content,
      );
    } else {
      return CustomAiResponseCard(
        message: message,
        onMessageUpdated: (updatedMessage) {
          // Optional: handle updates if needed, e.g., for streaming
          // You can call setState in parent or update provider state here
          debugPrint("Updated message: ${updatedMessage.content}");
        },
      );
    }
  }
}
