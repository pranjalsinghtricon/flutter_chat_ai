import 'package:elysia/common_ui_components/cards/custom_ai_response_card.dart';
import 'package:elysia/common_ui_components/cards/custom_user_query_card.dart';
import 'package:elysia/features/chat/data/models/message_model.dart';
import 'package:elysia/utiltities/consts/error_messages.dart';
import 'package:elysia/common_ui_components/error_messages/response_error.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isLast;
  final bool showPrivacyStatement;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isLast,
    this.showPrivacyStatement = false,
  }) : super(key: key);

  Future<void> _launchUrl() async {
    final url = Uri.parse(
      'https://portal.informa.com/sites/compliance/document/303301/Elysia-Notice-and-Acceptable-Use-Policy',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildMessageWidget() {
    if (message.isUser) {
      return CustomUserQueryCard(message: message.content);
    } else if (message.content == ErrorMessages.SOMETHING_WENT_WRONG) {
      return ResponseError(message: message.content);
    } else {
      return CustomAiResponseCard(
        message: message,
        isStreaming: false,
        onMessageUpdated: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMessageWidget(),

        // Privacy statement - only show at the end of the last AI message
        if (showPrivacyStatement)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    children: [
                      const TextSpan(
                        text: 'Elysia responses may be inaccurate. Know more about how your data is processed ',
                      ),
                      TextSpan(
                        text: 'here',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = _launchUrl,
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }
}