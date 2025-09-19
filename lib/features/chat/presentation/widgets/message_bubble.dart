import 'package:elysia/features/chat/data/models/message_model.dart';
import 'package:elysia/features/chat/data/repositories/chat_repository.dart';
import 'package:flutter/material.dart';
import '../../../../common_ui_components/cards/custom_ai_response_card.dart';
import '../../../../common_ui_components/cards/custom_user_query_card.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isLast;

  const MessageBubble({
    required this.message,
    required this.isLast,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return CustomUserQueryCard(
        message: message.content,
      );
    }
    final chatRepo = ChatRepository();

    return CustomAiResponseCard(
      message: message,
      isStreaming: chatRepo.isStreaming,
      onMessageUpdated: (_) {},
    );
  }
}
