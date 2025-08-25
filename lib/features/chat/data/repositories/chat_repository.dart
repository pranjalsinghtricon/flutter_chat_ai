import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatRepository {
  static const String historyBoxName = 'chat_history';

  // ===== History (list) =====
  Future<List<ChatHistory>> fetchChatsFromApi() async {
    final response = await http.get(Uri.parse('http://demo0405258.mockable.io/chat-history'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as Map<String, dynamic>;

      final List<ChatHistory> all = [];
      for (final section in ['today', 'yesterday', 'last_7_days', 'last_30_days', 'archived_chats']) {
        final list = (data[section] as List?) ?? [];
        for (final item in list) {
          all.add(ChatHistory.fromJson(item as Map<String, dynamic>));
        }
      }

      final box = await Hive.openBox<ChatHistory>(historyBoxName);
      await box.clear();
      await box.addAll(all);
      return all;
    }
    throw Exception('Failed to load chats');
  }

  Future<List<ChatHistory>> getLocalChats() async {
    final box = await Hive.openBox<ChatHistory>(historyBoxName);
    return box.values.toList();
  }

  Future<ChatHistory> upsertHistory(ChatHistory chat) async {
    final box = await Hive.openBox<ChatHistory>(historyBoxName);
    final existingKey = box.keys.firstWhere(
          (k) => box.get(k)!.sessionId == chat.sessionId,
      orElse: () => null,
    );
    if (existingKey != null) {
      await box.put(existingKey, chat);
    } else {
      await box.add(chat);
    }
    return chat;
  }

  Future<void> archiveChat(String sessionId, {bool archived = true}) async {
    final box = await Hive.openBox<ChatHistory>(historyBoxName);
    final key = box.keys.firstWhere((k) => box.get(k)!.sessionId == sessionId, orElse: () => null);
    if (key != null) {
      final current = box.get(key)!;
      await box.put(key, current.copyWith(isArchived: archived));
    }
  }

  Future<void> renameChat(String sessionId, String newTitle) async {
    final box = await Hive.openBox<ChatHistory>(historyBoxName);
    final key = box.keys.firstWhere((k) => box.get(k)!.sessionId == sessionId, orElse: () => null);
    if (key != null) {
      final current = box.get(key)!;
      await box.put(key, current.copyWith(title: newTitle, updatedOn: DateTime.now()));
    }
  }

  Future<void> deleteChat(String sessionId) async {
    final box = await Hive.openBox<ChatHistory>(historyBoxName);
    final key = box.keys.firstWhere((k) => box.get(k)!.sessionId == sessionId, orElse: () => null);
    if (key != null) {
      await box.delete(key);
    }
    // also remove messages box for this session
    if (Hive.isBoxOpen('messages_$sessionId')) {
      await Hive.box<Message>('messages_$sessionId').deleteFromDisk();
    } else if (await Hive.boxExists('messages_$sessionId')) {
      final b = await Hive.openBox<Message>('messages_$sessionId');
      await b.deleteFromDisk();
    }
  }

  // ===== Messages (per-session) =====
  Future<Box<Message>> _openMessagesBox(String sessionId) async {
    return Hive.isBoxOpen('messages_$sessionId')
        ? Hive.box<Message>('messages_$sessionId')
        : await Hive.openBox<Message>('messages_$sessionId');
  }

  Future<List<Message>> getMessages(String sessionId) async {
    final box = await _openMessagesBox(sessionId);
    return box.values.toList();
  }

  Future<void> addMessage(Message m) async {
    final box = await _openMessagesBox(m.sessionId);
    await box.add(m);
  }

  Future<void> replaceMessages(String sessionId, List<Message> all) async {
    final box = await _openMessagesBox(sessionId);
    await box.clear();
    await box.addAll(all);
  }
}