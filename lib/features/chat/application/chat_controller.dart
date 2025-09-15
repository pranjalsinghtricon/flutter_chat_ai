// chat_controller.dart
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
      (ref) =>
          ChatController(ref.read(chatRepositoryProvider)),
);

/// Sidebar chat list controller
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
    final history = ChatHistory(
      sessionId: _currentSessionId!,
      title: initialTitle,
      updatedOn: DateTime.now(),
      isArchived: false,
    );
    await _repo.upsertHistory(history);
    state = [];
    return _currentSessionId!;
  }

  Future<void> loadSession(String sessionId) async {
    _currentSessionId = sessionId;
    state = await _repo.getMessages(sessionId);
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

    final updatedHistory = ChatHistory(
      sessionId: _currentSessionId!,
      title: _titleFrom(text),
      updatedOn: DateTime.now(),
      isArchived: false,
    );
    await _repo.upsertHistory(updatedHistory);

    // Stream from repository
    _repo.sendPromptStream(prompt: text, sessionId: _currentSessionId!).listen((chunk) async {
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
    } catch (_) {
      state = await _repo.getLocalChats();
    }
  }

  Future<void> archiveChat(String sessionId, {bool archived = true}) async {
    await _repo.archiveChat(sessionId, archived: archived);
    await loadChats();
  }

  Future<void> renameChat(String sessionId, String newTitle) async {
    await _repo.renameChat(sessionId, newTitle);
    await loadChats();
  }

  Future<void> deleteChat(String sessionId) async {
    await _repo.deleteChat(sessionId);
    await loadChats();
  }
}
