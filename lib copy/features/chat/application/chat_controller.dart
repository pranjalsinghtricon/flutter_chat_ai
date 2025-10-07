import 'package:elysia/providers/private_chat_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';
import '../data/repositories/chat_repository.dart';
import 'package:elysia/utiltities/consts/error_messages.dart';
import 'package:elysia/utiltities/core/model_map.dart';
import 'dart:developer' as developer;

// Update the provider to use StateNotifierProvider
final chatRepositoryProvider = StateNotifierProvider<ChatRepository, ChatState>(
      (ref) => ChatRepository(ref),
);

/// Holds the in-memory messages for the *currently open* session.
final chatControllerProvider =
StateNotifierProvider<ChatController, List<Message>>(
      (ref) => ChatController(ref),
);

/// Holds the list of chat histories (sessions).
final chatHistoryProvider =
StateNotifierProvider<ChatHistoryController, ChatSections>(
      (ref) => ChatHistoryController(ref.read(chatRepositoryProvider.notifier)),
);

class ChatController extends StateNotifier<List<Message>> {
  bool forceNewChat = false;
  final Ref _ref;
  String? _currentSessionId;
  String? _readAloudLanguage;
  String? _responseModel;

  String? get currentSessionId => _currentSessionId;
  String? get readAloudLanguage => _readAloudLanguage;
  String? get responseModel => _responseModel;

  ChatController(this._ref) : super([]);

  ChatRepository get _repo => _ref.read(chatRepositoryProvider.notifier);

  Future<String> startNewChat({
    String initialTitle = 'New Conversation',
  }) async {
    _currentSessionId = const Uuid().v4();
    forceNewChat = true;
    state = [];
    developer.log(
      "🚀 Started new chat with session: $_currentSessionId",
      name: "ChatController",
    );
    return _currentSessionId!;
  }

  Future<void> loadSession(String sessionId) async {
    _currentSessionId = sessionId;
    developer.log("📂 Loading session: $sessionId", name: "ChatController");
    try {
      final messages = await _repo.getMessages(sessionId);
      state = messages;

      // Log run_id status for debugging
      final aiMessages = messages.where((m) => !m.isUser).toList();
      final messagesWithRunId = aiMessages.where((m) => m.runId != null).length;
      developer.log(
        "📊 Loaded ${messages.length} messages (${aiMessages.length} AI responses, $messagesWithRunId with run_id)",
        name: "ChatController",
      );
    } catch (e) {
      developer.log(
        "❌ Failed to load session $sessionId: $e",
        name: "ChatController",
        error: e,
      );
      // If session loading fails, start fresh
      state = [];
    }
  }

  void resetChatViewOnly() {
    state = [];
    _currentSessionId = null;
    forceNewChat = false;
  }

  // Method to completely clear all chat data (for sign out)
  void clearAllChatData() {
    state = [];
    _currentSessionId = null;
    forceNewChat = false;
  }

  // 🔥 ENHANCED sendMessage WITH IMPROVED RUN_ID HANDLING
  Future<void> sendMessage(String content, WidgetRef ref) async {
    final text = content.trim();
    if (text.isEmpty) return;

    bool isNewChat = _currentSessionId == null || forceNewChat;
    _currentSessionId ??= await startNewChat(initialTitle: _titleFrom(text));
    forceNewChat = false;

    developer.log(
      "💬 Sending message to session: $_currentSessionId",
      name: "ChatController",
    );

    final isPrivate = ref.read(privateChatProvider);
    final userMsg = Message(
      id: const Uuid().v4(),
      sessionId: _currentSessionId!,
      content: text,
      isUser: true,
      createdAt: DateTime.now(),
      runId: null,
      readAloudLanguage: null,
      responseModel: null,
      isPrivate: isPrivate,
    );

    state = [...state, userMsg];
    await _repo.addMessage(userMsg);

    final botId = const Uuid().v4();

    // 🔥 CREATE BOT MESSAGE WITH isGenerating = true
    var botMsg = Message(
      id: botId,
      sessionId: _currentSessionId!,
      content: '', // Empty content initially
      isUser: false,
      createdAt: DateTime.now(),
      readAloudLanguage: null,
      responseModel: null,
      runId: null,
      isPrivate: isPrivate,
      isGenerating: true, // 🔥 SET TO TRUE IMMEDIATELY
    );

    // Add the bot message with loading state
    state = [...state, botMsg];
    await _repo.addMessage(botMsg);

    bool chatAddedToToday = false;
    String? currentRunId;

    developer.log(
      "🚀 Starting stream for message: $botId",
      name: "ChatController",
    );

    _repo
        .sendPromptStreamWithRunId(
      prompt: text,
      sessionId: _currentSessionId!,
      messageId: botId,
    )
        .listen(
          (data) async {
        final type = data['type'] as String;

        if (type == 'error') {
          developer.log(
            "❌ Stream error: ${data['error']}",
            name: "ChatController",
          );
          final errorMsg = Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sessionId: _currentSessionId!,
            content: ErrorMessages.SOMETHING_WENT_WRONG,
            isUser: false,
            createdAt: DateTime.now(),
            runId: currentRunId,
            isGenerating: false, // 🔥 Stop generating on error
          );
          final updatedMessages = [...state];
          final botMessageIndex = updatedMessages.lastIndexWhere((m) => m.id == botId);
          if (botMessageIndex != -1) {
            updatedMessages[botMessageIndex] = errorMsg;
            state = updatedMessages;
          } else {
            state = [...state, errorMsg];
          }
          return;
        }

        if (type == 'run_id') {
          currentRunId = data['run_id'] as String?;
          developer.log(
            "🆔 Received run_id: $currentRunId for message: $botId",
            name: "ChatController",
          );

          // Update with run_id but keep isGenerating = true
          botMsg = botMsg.copyWith(runId: currentRunId);
          final messagesWithRunId = [...state];
          final runIdMessageIndex = messagesWithRunId.lastIndexWhere((m) => m.id == botId);
          if (runIdMessageIndex != -1) {
            messagesWithRunId[runIdMessageIndex] = botMsg;
            state = messagesWithRunId;
            developer.log(
              "✅ Updated message $botId with run_id: $currentRunId",
              name: "ChatController",
            );
          }
          return;
        }

        if (type == 'answer') {
          final chunk = data['chunk'] as String;

          // Update content but keep isGenerating = true
          botMsg = botMsg.copyWith(
            content: botMsg.content + chunk,
            runId: currentRunId ?? botMsg.runId,
            // isGenerating stays true until we get metadata
          );

          final updatedMessages = [...state];
          final botMessageIndex = updatedMessages.lastIndexWhere((m) => m.id == botId);
          if (botMessageIndex != -1) {
            updatedMessages[botMessageIndex] = botMsg;
            state = updatedMessages;
          }

          await _repo.replaceMessages(_currentSessionId!, state);

          if (isNewChat && !chatAddedToToday && chunk.trim().isNotEmpty &&!isPrivate) {
            chatAddedToToday = true;
            final chatHistory = ChatHistory(
              sessionId: _currentSessionId!,
              title: 'New Chat',
              updatedOn: DateTime.now(),
              isArchived: false,
            );

            final notifier = ref.read(chatHistoryProvider.notifier);
            notifier.state = ChatSections(
              today: [chatHistory, ...notifier.state.today],
              yesterday: notifier.state.yesterday,
              last7: notifier.state.last7,
              last30: notifier.state.last30,
              archived: notifier.state.archived,
            );
          }
          return;
        }

        if (type == 'metadata') {
          final metadata = data['metadata'] as Map<String, dynamic>;
          final title = metadata['title'];
          final readAloudLanguage = metadata['response_language'];
          final responseModel = ModelUtils.getDisplayName(metadata['name_of_model']);

          if (title != null && title.toString().trim().isNotEmpty) {
            ref
                .read(chatHistoryProvider.notifier)
                .updateTitle(_currentSessionId!, title);
          }

          botMsg = botMsg.copyWith(
            readAloudLanguage: readAloudLanguage,
            responseModel: responseModel,
            isGenerating: false,
          );

          final updatedMessages = [...state];
          final botMessageIndex = updatedMessages.lastIndexWhere((m) => m.id == botId);
          if (botMessageIndex != -1) {
            updatedMessages[botMessageIndex] = botMsg;
            state = updatedMessages;
          }

          if (readAloudLanguage != null) {
            _readAloudLanguage = readAloudLanguage;
          }

          if (responseModel != null) {
            _responseModel = responseModel;
          }

          developer.log(
            "📊 Received metadata for run_id: $currentRunId, stopped generating",
            name: "ChatController",
          );
          return;
        }
      },
      onError: (error) {
        developer.log(
          "💥 Stream error: $error",
          name: "ChatController",
          error: error,
        );
        // Stop generating on error
        final messagesWithGeneratingStopped = [...state];
        final botMessageIndex = messagesWithGeneratingStopped.lastIndexWhere((m) => m.id == botId);
        if (botMessageIndex != -1) {
          messagesWithGeneratingStopped[botMessageIndex] =
              messagesWithGeneratingStopped[botMessageIndex].copyWith(isGenerating: false);
          state = messagesWithGeneratingStopped;
        }
      },
      onDone: () {
        developer.log(
          "🏁 Stream completed for message: $botId with run_id: $currentRunId",
          name: "ChatController",
        );

        // Ensure isGenerating is false when stream completes
        final messagesWithGeneratingStopped = [...state];
        final botMessageIndex = messagesWithGeneratingStopped.lastIndexWhere((m) => m.id == botId);
        if (botMessageIndex != -1 && messagesWithGeneratingStopped[botMessageIndex].isGenerating) {
          messagesWithGeneratingStopped[botMessageIndex] =
              messagesWithGeneratingStopped[botMessageIndex].copyWith(isGenerating: false);
          state = messagesWithGeneratingStopped;
        }

        // Final validation for run_id
        final finalMessage = state.firstWhere(
              (m) => m.id == botId,
          orElse: () => botMsg,
        );
        if (finalMessage.runId == null && currentRunId != null) {
          developer.log(
            "⚠️ Final message missing run_id, applying: $currentRunId",
            name: "ChatController",
          );
          final messagesWithRunId = [...state];
          final runIdMessageIndex = messagesWithRunId.lastIndexWhere((m) => m.id == botId);
          if (runIdMessageIndex != -1) {
            messagesWithRunId[runIdMessageIndex] = finalMessage.copyWith(runId: currentRunId);
            state = messagesWithRunId;
          }
        }
      },
    );
  }

  String _titleFrom(String text) {
    final t = text.replaceAll('\n', ' ').trim();
    return t.length <= 40 ? t : '${t.substring(0, 37)}...';
  }
}

class ChatHistoryController extends StateNotifier<ChatSections> {
  final ChatRepository _repo;

  ChatHistoryController(this._repo) : super(ChatSections.empty()) {
    loadChats();
  }

  Future<void> loadChats() async {
    try {
      state = await _repo.fetchChatsFromApi();
      developer.log("✅ Loaded chat sections", name: "ChatHistoryController");
    } catch (e) {
      developer.log(
        "❌ Failed to load chats: $e",
        name: "ChatHistoryController",
        error: e,
      );
      state = ChatSections.empty();
    }
  }

  void updateArchiveStatus(String sessionId) {
    ChatHistory? chatToArchive;
    List<ChatHistory> removeAndUpdate(List<ChatHistory> list) {
      return list.where((chat) {
        if (chat.sessionId == sessionId) {
          chatToArchive = chat.copyWith(isArchived: true);
          return false; // remove from current list
        }
        return true;
      }).toList();
    }

    state = ChatSections(
      today: removeAndUpdate(state.today),
      yesterday: removeAndUpdate(state.yesterday),
      last7: removeAndUpdate(state.last7),
      last30: removeAndUpdate(state.last30),
      archived: chatToArchive != null
          ? [chatToArchive!, ...state.archived]
          : state.archived,
    );
  }

  void updateTitle(String sessionId, String newTitle) {
    state = _mapChats(
          (chat) =>
      chat.sessionId == sessionId ? chat.copyWith(title: newTitle) : chat,
    );
  }

  void deleteChat(String sessionId) {
    state = _mapChats(
          (chat) => chat.sessionId == sessionId ? null : chat,
      removeNulls: true,
    );
  }

  ChatSections _mapChats(
      ChatHistory? Function(ChatHistory) transform, {
        bool removeNulls = false,
      }) {
    List<ChatHistory> apply(List<ChatHistory> list) {
      final mapped = list.map(transform).toList();
      return removeNulls
          ? mapped.whereType<ChatHistory>().toList()
          : mapped.cast<ChatHistory>();
    }

    return ChatSections(
      today: apply(state.today),
      yesterday: apply(state.yesterday),
      last7: apply(state.last7),
      last30: apply(state.last30),
      archived: apply(state.archived),
    );
  }
}