import 'dart:convert';
import 'dart:async';
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

  // ===== Streaming Chat Completion API =====
  Stream<String> sendPromptStream({
    required String prompt,
    required String sessionId,
  }) async* {
    try {
      final headers = {
        'accept': '*/*',
        'accept-language': 'en-US,en;q=0.9',
        'authorization': 'Bearer eyJraWQiOiJPWkdTbHBoWmh6ZkUwN09MWVJGa2lcL0lCdXJWR3hYWnJ6SXVEc2diUDJhZz0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIyOGFkZTExOC1jMGJmLTQyMzktYWVlNi01Y2VkMGVkN2RhMGUiLCJjb2duaXRvOmdyb3VwcyI6WyIqXC9hdWRpZW5jZVwvKiIsImV1LXdlc3QtMV9nZTFSTUZyZjZfQXp1cmUtU1NPIl0sImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC5ldS13ZXN0LTEuYW1hem9uYXdzLmNvbVwvZXUtd2VzdC0xX2dlMVJNRnJmNiIsInZlcnNpb24iOjIsImNsaWVudF9pZCI6IjU5OWUwcjlpYWR2YTY0bnY3Z3NuY3ZrMnNrIiwib3JpZ2luX2p0aSI6ImIyZGYyZDE1LTA2ZWItNGFhNi04MWM2LWQ5NTBhMTEwOGM0YyIsInRva2VuX3VzZSI6ImFjY2VzcyIsInNjb3BlIjoib3BlbmlkIGlyaXMuYXBpc1wvYWkgZW1haWwiLCJhdXRoX3RpbWUiOjE3NTczMTY4MTIsImV4cCI6MTc1NzMyNzYxMiwiaWF0IjoxNzU3MzI0MDEyLCJqdGkiOiJhOGU1OGYxZC04MTYyLTQ4NDktYjI2OC1mZjdiMGEzMDAwM2MiLCJ1c2VybmFtZSI6IkF6dXJlLVNTT19QcmFuamFsLlNpbmdoQGluZm9ybWEuY29tIn0.JVcJ6O-m2DalU28RqyEorUUrWH3b38mtjQbU9BqbKrdWxN3oipsIpW2o-D3O0EksHw4ahL2W7smboTCEfYvAbToCz6XTGRxWWb3ZoeHj-Gs0S_y35orudrGlz_8MY3gujOZ4n3FhnHsor9IEEj5ytcMGzSddHyuRi4cTfzywnT18NctXCqbHuun9Lg3DNodwuBQ_EXBd7j9xLnAOT4bJ1TizJmOoowTuA7F-Zm5CK3hNuyse8AnZLPaZmXSWkMQF9i7DaMymTEDu2RTz1Gbtq-HrJZkEqAyoaRfpmWiPFoPHhIIRmbiQL2Mh5Dky3X12eFgK7GR-1TUWclZLHeOw7w',
        'content-type': 'application/json',
        'origin': 'https://elysia-qa.informa.com',
        'priority': 'u=1, i',
        'sec-ch-ua': '"Chromium";v="140", "Not=A?Brand";v="24", "Google Chrome";v="140"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
        'sec-fetch-dest': 'empty',
        'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'cross-site',
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
      };

      final body = jsonEncode({
        "appId": "e3a5c706-7a5e-4550-bbb0-db535b1eb381",
        "query": prompt,
        "model": "aws",
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
        "default_name_of_model": "us.anthropic.claude-sonnet-4-20250514-v1:0",
        "name_of_model": "us.anthropic.claude-sonnet-4-20250514-v1:0"
      });

      final request = http.Request(
        'POST',
        Uri.parse('https://stream-api-qa.iiris.com/v2/ai/chat/stream/completion'),
      )
        ..headers.addAll(headers)
        ..body = body;

      final response = await request.send();

      if (response.statusCode != 200) {
        yield '[Exception: HTTP ${response.statusCode}]';
        return;
      }

      // Stream the response as lines
      await for (final line in response.stream.transform(Utf8Decoder()).transform(const LineSplitter())) {
        if (line.trim().isEmpty) continue;
        try {
          final Map<String, dynamic> decoded = jsonDecode(line) as Map<String, dynamic>;
          final String? type = decoded['type'] as String?;
          if (type == 'answer') {
            final chunk = decoded['answer'] as String?;
            if (chunk != null) yield chunk;
          }
        } catch (_) {
          continue;
        }
        await Future.delayed(const Duration(milliseconds: 40));
      }
    } catch (e) {
      yield '[Exception: $e]';
    }
  }
}
