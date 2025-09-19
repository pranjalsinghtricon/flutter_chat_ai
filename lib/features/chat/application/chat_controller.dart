import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';
import '../data/repositories/chat_repository.dart';


final chatRepositoryProvider =
Provider<ChatRepository>((ref) => ChatRepository());

/// Holds the in-memory messages for the *currently open* session.
final chatControllerProvider =
StateNotifierProvider<ChatController, List<Message>>(
      (ref) => ChatController(ref.read(chatRepositoryProvider)),
);

/// Holds the list of chat histories (sessions).
final chatHistoryProvider =
    StateNotifierProvider<ChatHistoryController, ChatSections>(
  (ref) => ChatHistoryController(ref.read(chatRepositoryProvider)),
);

class ChatController extends StateNotifier<List<Message>> {
  bool forceNewChat = false;
  final ChatRepository _repo;
  String? _currentSessionId;
  String? get currentSessionId => _currentSessionId;

  ChatController(this._repo) : super([]);

  Future<String> startNewChat({String initialTitle = 'New Conversation'}) async {
    _currentSessionId = const Uuid().v4();

    // We no longer upsert history locally → history is managed by API
    // But still initialize messages
    _currentSessionId = const Uuid().v4();
    forceNewChat = true;
    state = [];
    return _currentSessionId!;
  }

  Future<void> loadSession(String sessionId) async {
    _currentSessionId = sessionId;
    final messages = await _repo.getMessages(sessionId);
    state = messages;
  }

  void resetChatViewOnly() {
    state = [];
  }

  Future<void> sendMessage(String content, WidgetRef ref) async {
    final text = content.trim();
    if (text.isEmpty) return;

    bool isNewChat = _currentSessionId == null || forceNewChat;
    _currentSessionId ??= await startNewChat(initialTitle: _titleFrom(text));
    forceNewChat = false;

    final userMsg = Message(
      id: const Uuid().v4(),
      sessionId: _currentSessionId!,
      content: text,
      isUser: true,
      createdAt: DateTime.now(),
    );
    state = [...state, userMsg];
    await _repo.addMessage(userMsg);

    final botId = const Uuid().v4();
    var botMsg = Message(
      id: botId,
      sessionId: _currentSessionId!,
      content: '',
      isUser: false,
      createdAt: DateTime.now(),
    );
    state = [...state, botMsg];
    await _repo.addMessage(botMsg);

    bool chatAddedToToday = false;
    // Stream response from API
    _repo
        .sendPromptStream(prompt: text, sessionId: _currentSessionId!)
        .listen((chunk) async {
      // Check for metadata chunk
      if (chunk.startsWith('[METADATA]')) {
        final metadataJson = chunk.substring(10);
        final metadata = jsonDecode(metadataJson);
        final title = metadata['title'];
        if (title != null && title.toString().trim().isNotEmpty) {
          ref.read(chatHistoryProvider.notifier).updateTitle(_currentSessionId!, title);
        }
        return;
      }

      botMsg = botMsg.copyWith(content: botMsg.content + chunk);
      final copy = [...state];
      final lastIndex = copy.lastIndexWhere((m) => m.id == botId);
      if (lastIndex != -1) {
        copy[lastIndex] = botMsg;
        state = copy;
      }
      await _repo.replaceMessages(_currentSessionId!, state);
      // Add new chat to today only after first non-empty, non-metadata chunk
      if (isNewChat && !chatAddedToToday && !chunk.startsWith('[METADATA]') && chunk.trim().isNotEmpty) {
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
    });
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
    } catch (e) {
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
      archived: chatToArchive != null ? [chatToArchive!, ...state.archived] : state.archived,
    );
  }

  void updateTitle(String sessionId, String newTitle) {
    state = _mapChats(
      (chat) => chat.sessionId == sessionId
          ? chat.copyWith(title: newTitle)
          : chat,
    );
  }

  void deleteChat(String sessionId) {
    state = _mapChats(
      (chat) => chat.sessionId == sessionId ? null : chat,
      removeNulls: true,
    );
  }

  ChatSections _mapChats(ChatHistory? Function(ChatHistory) transform,
      {bool removeNulls = false}) {
    List<ChatHistory> apply(List<ChatHistory> list) {
      final mapped = list.map(transform).toList();
      return removeNulls ? mapped.whereType<ChatHistory>().toList() : mapped.cast<ChatHistory>();
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
