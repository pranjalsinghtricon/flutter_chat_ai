import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:elysia/features/auth/service/service.dart';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatRepository {
  // ===== History (API only, no Hive) =====
  Future<List<ChatHistory>> fetchChatsFromApi() async {
    try {
      final authService = AuthService();
      final accessToken = await authService.getAccessToken();
      if (accessToken == null) {
        throw Exception("Missing access token");
      }

      // Decode JWT to get sub
      final parts = accessToken.split('.');
      if (parts.length != 3) throw Exception("Invalid JWT token");
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final sub = jsonDecode(payload)['sub'] as String;

      final headers = {
        'accept': 'application/json, text/plain, */*',
        'authorization': 'Bearer $accessToken',
        'origin': 'https://elysia-qa.informa.com',
      };

      final url = Uri.parse(
        'https://stream-api-qa.iiris.com/v2/ai/chat/users/$sub/conversations?timezone=Asia/Calcutta',
      );

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] as Map<String, dynamic>;

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
        return all;
      } else {
        throw Exception('Failed to load chats: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('❌ fetchChatsFromApi error: $e',
          name: 'ChatRepository', error: e, stackTrace: stack);
      throw Exception('Error fetching chats: $e');
    }
  }

  // ===== Messages still stored locally =====
  Future<List<Message>> getMessages(String sessionId) async {
    // keep Hive for messages
    return [];
  }

  Future<void> addMessage(Message m) async {
    // keep Hive for messages
  }

  Future<void> replaceMessages(String sessionId, List<Message> all) async {
    // keep Hive for messages
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

      await for (final line in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (line.trim().isEmpty) continue;
        try {
          final Map<String, dynamic> decoded =
          jsonDecode(line) as Map<String, dynamic>;
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
