// lib/features/chat/application/chat_controller.dart
import 'package:flutter_chat_ai/data/models/chat_model/message_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/api_service.dart';
import '../data/repositories/chat_repository.dart';
import '../data/models/chat_model.dart';


// Provider for messages in the current chat session
final chatControllerProvider =
StateNotifierProvider<ChatController, List<Message>>(
      (ref) => ChatController(ref.watch(apiServiceProvider)),
);

// Provider for conversation history (sidebar)
final chatHistoryProvider =
StateNotifierProvider<ChatHistoryController, List<ChatHistory>>(
      (ref) => ChatHistoryController(ChatRepository()),
);


class ChatController extends StateNotifier<List<Message>> {
  final ApiService _apiService;

  ChatController(this._apiService) : super([]);

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
      updatedMessages[lastIndex] = updatedMessages[lastIndex].copyWith(
        content: updatedMessages[lastIndex].content + chunk,
      );
      state = updatedMessages;
    });
  }

  /// Reset the chat to an empty state (fresh Welcome screen)
  void resetChat() {
    state = [];
  }
}


class ChatHistoryController extends StateNotifier<List<ChatHistory>> {
  final ChatRepository _repository;

  ChatHistoryController(this._repository) : super([]) {
    loadChats();
  }

  /// Load from API or local Hive
  Future<void> loadChats() async {
    try {
      final chats = await _repository.fetchChatsFromApi();
      state = chats;
    } catch (_) {
      final localChats = await _repository.getLocalChats();
      state = localChats;
    }
  }

  /// Add a new chat (when user clicks "New Chat")
  Future<void> addNewChat(String title) async {
    final chat = ChatHistory(
      sessionId: const Uuid().v4(),
      title: title,
      updatedOn: DateTime.now(),
    );
    await _repository.addChat(chat);
    state = [...state, chat];
  }
}
