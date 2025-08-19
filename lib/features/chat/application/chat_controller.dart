// lib/features/chat/application/chat_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/message_model.dart';
import '../../../core/services/api_service.dart';

// Provider
final chatControllerProvider =
StateNotifierProvider<ChatController, List<Message>>(
      (ref) => ChatController(ref.watch(apiServiceProvider)),
);

// Controller
class ChatController extends StateNotifier<List<Message>> {
  final ApiService _apiService;

  ChatController(this._apiService) : super([]);

  /// Send user message + stream AI response
  void sendMessage(String content) {
    final userMessage = Message(
      id: const Uuid().v4(),
      content: content,
      isUser: true,
    );
    state = [...state, userMessage];

    final botMessage = Message(
      id: const Uuid().v4(),
      content: "",
      isUser: false,
    );
    state = [...state, botMessage];

    _apiService.sendPromptStream(content).listen((chunk) {
      // Append chunk to last AI message
      final updatedMessages = [...state];
      final lastIndex = updatedMessages.length - 1;
      updatedMessages[lastIndex] = updatedMessages[lastIndex]
          .copyWith(content: updatedMessages[lastIndex].content + chunk);
      state = updatedMessages;
    });
  }

  /// Reset the chat to an empty state (fresh Welcome screen)
  void resetChat() {
    state = [];
  }
}
