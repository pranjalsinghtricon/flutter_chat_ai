import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:elysia/features/auth/service/service.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatRepository {
  static const String historyBoxName = 'chat_history';

  // ===== History =====
  Future<List<ChatHistory>> fetchChatsFromApi() async {
    final response =
    await http.get(Uri.parse('http://demo0405258.mockable.io/chat-history'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as Map<String, dynamic>;
      final List<ChatHistory> all = [];

      for (final section in [
        'today',
        'yesterday',
        'last_7_days',
        'last_30_days',
        'archived_chats'
      ]) {
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
    final key =
    box.keys.firstWhere((k) => box.get(k)!.sessionId == sessionId, orElse: () => null);

    if (key != null) {
      final current = box.get(key)!;
      await box.put(key, current.copyWith(isArchived: archived));
    }
  }

  Future<void> renameChat(String sessionId, String newTitle) async {
    final box = await Hive.openBox<ChatHistory>(historyBoxName);
    final key =
    box.keys.firstWhere((k) => box.get(k)!.sessionId == sessionId, orElse: () => null);

    if (key != null) {
      final current = box.get(key)!;
      await box.put(
          key, current.copyWith(title: newTitle, updatedOn: DateTime.now()));
    }
  }

  Future<void> deleteChat(String sessionId) async {
    final box = await Hive.openBox<ChatHistory>(historyBoxName);
    final key =
    box.keys.firstWhere((k) => box.get(k)!.sessionId == sessionId, orElse: () => null);

    if (key != null) {
      await box.delete(key);
    }

    // remove messages box
    if (Hive.isBoxOpen('messages_$sessionId')) {
      await Hive.box<Message>('messages_$sessionId').deleteFromDisk();
    } else if (await Hive.boxExists('messages_$sessionId')) {
      final b = await Hive.openBox<Message>('messages_$sessionId');
      await b.deleteFromDisk();
    }
  }

  // ===== Messages =====
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

  // ===== Streaming Chat Completion API =====
  Stream<String> sendPromptStream({
    required String prompt,
    required String sessionId,
  }) async* {
    try {
      final authService = AuthService();
      final accessToken = await authService.getAccessToken();
      if (accessToken == null) {
        yield '[Exception: Missing access token]';
        return;
      }

      final headers = {
        'accept': '*/*',
        'accept-language': 'en-US,en;q=0.9',
        'authorization': 'Bearer $accessToken',
        'content-type': 'application/json',
        'origin': 'https://elysia-qa.informa.com',
        'user-agent': 'ElysiaClient/1.0',
      };

      final body = jsonEncode({
        "appId": "e3a5c706-7a5e-4550-bbb0-db535b1eb381",
        "query": prompt,
        "model": "azure",
        "tokens": 8192,
        "creativity": "Factual",
        "personality": "Professional",
        "role": "Assistant",
        "writing_style": "Descriptive",
        "domain_expertise": "General",
        "chat_session": sessionId,
        "private_chat": false,
        "system_prompt": "",
        "concepts": [],
        "entities": [],
        "business_units": [],
        "products": [],
        "content_domains": [],
        "showSourceList": false,
        "include_search": true,
        "include_metadata": true,
        "intermediate_steps": true,
        "response_language": "English (US)",
        "default_response_language": "English (US)",
        "default_name_of_model": "gpt-4o",
        "name_of_model": "gpt-4o"
      });

      final request = http.Request(
        'POST',
        Uri.parse('https://stream-api-qa.iiris.com/v2/ai/chat/stream/completion'),
      )..headers.addAll(headers)
        ..body = body;

      final response = await request.send();

      if (response.statusCode != 200) {
        yield '[Exception: HTTP ${response.statusCode}]';
        return;
      }

      await for (final line in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (line.trim().isEmpty) continue;
        try {
          final Map<String, dynamic> decoded = jsonDecode(line) as Map<String, dynamic>;

          if (decoded['type'] == 'answer') {
            final chunk = decoded['answer'] as String?;
            if (chunk != null) {
              yield chunk;
            }
          }
        } catch (err) {
          continue;
        }

        await Future.delayed(const Duration(milliseconds: 40));
      }
    } catch (e) {
      yield '[Exception: $e]';
    }
  }
}
