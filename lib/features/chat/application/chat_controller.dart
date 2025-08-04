// lib/features/chat/application/chat_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/message_model.dart';
import '../../../core/services/api_service.dart';

// Provider
final chatControllerProvider = StateNotifierProvider<ChatController, List<Message>>(
      (ref) => ChatController(ref.watch(apiServiceProvider)),
);

// Controller
class ChatController extends StateNotifier<List<Message>> {
  final ApiService _apiService;

  ChatController(this._apiService) : super([]);

  void sendMessage(String content) async {
    final userMessage = Message(
      id: const Uuid().v4(),
      content: content,
      isUser: true,
    );

    // Add user message to state
    state = [...state, userMessage];

    try {
      final botResponse = await _apiService.sendPrompt(content);

      final botMessage = Message(
        id: const Uuid().v4(),
        content: botResponse,
        isUser: false,
      );

      // Add bot response to state
      state = [...state, botMessage];
    } catch (e) {
      final errorMessage = Message(
        id: const Uuid().v4(),
        content: 'Error: ${e.toString()}',
        isUser: false,
      );

      state = [...state, errorMessage];
    }
  }
}
