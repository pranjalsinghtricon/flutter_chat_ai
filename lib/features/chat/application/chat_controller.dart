import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';
import '../data/repositories/chat_repository.dart';


// Ensure ChatRepository is defined in ../data/repositories/chat_repository.dart
final chatRepositoryProvider =
Provider<ChatRepository>((ref) => ChatRepository());

/// Holds the in-memory messages for the *currently open* session.
final chatControllerProvider =
StateNotifierProvider<ChatController, List<Message>>(
      (ref) => ChatController(ref.read(chatRepositoryProvider)),
);

/// Holds the list of chat histories (sessions).
final chatHistoryProvider =
StateNotifierProvider<ChatHistoryController, List<ChatHistory>>(
      (ref) => ChatHistoryController(ref.read(chatRepositoryProvider)),
);

class ChatController extends StateNotifier<List<Message>> {
  final ChatRepository _repo;
  String? _currentSessionId;
  String? get currentSessionId => _currentSessionId;

  ChatController(this._repo) : super([]);

  Future<String> startNewChat({String initialTitle = 'New Conversation'}) async {
    _currentSessionId = const Uuid().v4();

    // We no longer upsert history locally → history is managed by API
    // But still initialize messages
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

  Future<void> sendMessage(String content) async {
    final text = content.trim();
    if (text.isEmpty) return;

    _currentSessionId ??= await startNewChat(initialTitle: _titleFrom(text));

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

    // Stream response from API
    _repo
        .sendPromptStream(prompt: text, sessionId: _currentSessionId!)
        .listen((chunk) async {
      botMsg = botMsg.copyWith(content: botMsg.content + chunk);
      final copy = [...state];
      final lastIndex = copy.lastIndexWhere((m) => m.id == botId);
      if (lastIndex != -1) {
        copy[lastIndex] = botMsg;
        state = copy;
      }
      await _repo.replaceMessages(_currentSessionId!, state);
    });
  }

  String _titleFrom(String text) {
    final t = text.replaceAll('\n', ' ').trim();
    return t.length <= 40 ? t : '${t.substring(0, 37)}...';
  }
}

class ChatHistoryController extends StateNotifier<List<ChatHistory>> {
  final ChatRepository _repo;
  ChatHistoryController(this._repo) : super([]) {
    loadChats();
  }

  Future<void> loadChats() async {
    try {
      state = await _repo.fetchChatsFromApi();
    } catch (e) {
      state = [];
    }
  }

  // Archive/rename/delete were Hive-based → now they should be handled via API
  // If backend doesn’t yet support, we just update local state temporarily
  Future<void> archiveChat(String sessionId, {bool archived = true}) async {
    // TODO: Replace with API call when available
    state = state
        .map((c) =>
    c.sessionId == sessionId ? c.copyWith(isArchived: archived) : c)
        .toList();
  }

  Future<void> renameChat(String sessionId, String newTitle) async {
    // TODO: Replace with API call when available
    state = state
        .map((c) =>
    c.sessionId == sessionId ? c.copyWith(title: newTitle) : c)
        .toList();
  }

  Future<void> deleteChat(String sessionId) async {
    // TODO: Replace with API call when available
    state = state.where((c) => c.sessionId != sessionId).toList();
  }
}
