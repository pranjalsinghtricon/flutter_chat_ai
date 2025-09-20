import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../../../utiltities/core/storage.dart'; // ✅ TokenStorage
import '../../../../utiltities/data-time/timezone.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatSections {
  final List<ChatHistory> today;
  final List<ChatHistory> yesterday;
  final List<ChatHistory> last7;
  final List<ChatHistory> last30;
  final List<ChatHistory> archived;

  ChatSections({
    required this.today,
    required this.yesterday,
    required this.last7,
    required this.last30,
    required this.archived,
  });

  factory ChatSections.empty() => ChatSections(
    today: [],
    yesterday: [],
    last7: [],
    last30: [],
    archived: [],
  );
}

class SamplePrompt {
  final String prompt;
  final int promptId;

  SamplePrompt({required this.prompt, required this.promptId});

  factory SamplePrompt.fromJson(Map<String, dynamic> json) {
    return SamplePrompt(
      prompt: json['prompt'] as String,
      promptId: json['prompt_id'] as int,
    );
  }
}

class ChatRepository {
  final TokenStorage _tokenStorage = TokenStorage();

  /// ✅ Streaming state flag
  bool isStreaming = false;

  /// ✅ NEW: Fetch sample prompts from API
  Future<List<String>> fetchSamplePrompts() async {
    return _withAuthHeaders((headers) async {
      final url = Uri.parse('https://stream-api-qa.iiris.com/v2/ai/chat/prompts/sample');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] as List<dynamic>;

        // Extract just the prompt text from each item
        return data.map((item) => item['prompt'] as String).toList();
      } else {
        developer.log('❌ Failed to fetch sample prompts: ${response.statusCode}', name: 'ChatRepository');
        // Return fallback prompts if API fails
        return [
          "Draft email to suppliers about new payment terms",
          "Suggest tools and techniques for monitoring projects",
          "Suggest tools and techniques",
          "Generate catchy journal titles",
        ];
      }
    }, 'fetchSamplePrompts');
  }

  /// === Fetch chat list grouped by sections ===
  Future<ChatSections> fetchChatsFromApi() async {
    return _withAuthHeaders((headers) async {
      final accessToken = headers['authorization']!.replaceFirst('Bearer ', '');
      final userId = _decodeUserId(accessToken);
      final timezone = await getLocalTimezone();

      final url = Uri.parse(
        'https://stream-api-qa.iiris.com/v2/ai/chat/users/$userId/conversations?timezone=$timezone',
      );

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] as Map<String, dynamic>;

        return ChatSections(
          today: (data['today'] as List? ?? [])
              .map((e) => ChatHistory.fromJson(e))
              .toList(),
          yesterday: (data['yesterday'] as List? ?? [])
              .map((e) => ChatHistory.fromJson(e))
              .toList(),
          last7: (data['last_7_days'] as List? ?? [])
              .map((e) => ChatHistory.fromJson(e))
              .toList(),
          last30: (data['last_30_days'] as List? ?? [])
              .map((e) => ChatHistory.fromJson(e))
              .toList(),
          archived: (data['archived_chats'] as List? ?? [])
              .map((e) => ChatHistory.fromJson(e))
              .toList(),
        );
      } else {
        throw Exception('Failed to load chats: ${response.statusCode}');
      }
    }, 'fetchChatsFromApi');
  }

  /// === Fetch messages for a given session ===
  Future<List<Message>> getMessages(String sessionId) async {
    return _withAuthHeaders((headers) async {
      final url =
      Uri.parse('https://stream-api-qa.iiris.com/v2/ai/chat/session/$sessionId');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<Message> result = [];
        final dataList = body['data'] as List? ?? [];

        for (final session in dataList) {
          final historyList = session['history'] as List? ?? [];
          for (final history in historyList) {
            final inputList = history['input'] as List? ?? [];
            final outputList = history['output'] as List? ?? [];
            final inputText = inputList.isNotEmpty ? (inputList[0]['text'] ?? "") : "";
            final outputText = outputList.isNotEmpty ? (outputList[0]['text'] ?? "") : "";
            final createdAt = history['createdAt'] != null
                ? DateTime.tryParse(history['createdAt'].toString()) ?? DateTime.now()
                : DateTime.now();

            // User message
            if (inputText.isNotEmpty) {
              result.add(Message(
                id: inputList.isNotEmpty && inputList[0]['id'] != null
                    ? inputList[0]['id'] as String
                    : '',
                sessionId: sessionId,
                content: inputText,
                isUser: true,
                createdAt: createdAt,
              ));
            }

            // AI message
            if (outputText.isNotEmpty) {
              result.add(Message(
                id: outputList.isNotEmpty && outputList[0]['id'] != null
                    ? outputList[0]['id'] as String
                    : '',
                sessionId: sessionId,
                content: outputText,
                isUser: false,
                createdAt: createdAt,
              ));
            }
          }
        }

        return result;
      } else if (response.statusCode == 404) {
        // ✅ No messages found yet → return empty list instead of crashing
        developer.log("ℹ No messages yet for session $sessionId",
            name: "ChatRepository");
        return [];
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    }, 'getMessages');
  }

  Future<void> addMessage(Message m) async {
    // TODO: Hive local storage
  }

  Future<void> replaceMessages(String sessionId, List<Message> all) async {
    // TODO: Hive local storage
  }

  /// === Streaming chat completion API ===
  Stream<String> sendPromptStream({
    required String prompt,
    required String sessionId,
  }) async* {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
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
      )
        ..headers.addAll(headers)
        ..body = body;

      final response = await request.send();

      if (response.statusCode != 200) {
        yield '[Exception: HTTP ${response.statusCode}]';
        return;
      }

      /// ✅ Mark streaming started
      isStreaming = true;

      try {
        developer.log('===========1 ${isStreaming}',
          name: 'ChatRepository', );
        await for (final line in response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
          if (line.trim().isEmpty) continue;

          developer.log('===========2 ${isStreaming}',
            name: 'ChatRepository', );
          try {
            final Map<String, dynamic> decoded =
            jsonDecode(line) as Map<String, dynamic>;

            if (decoded['type'] == 'answer') {
              developer.log('===========3 ${isStreaming}',
                name: 'ChatRepository', );
              final chunk = decoded['answer'] as String?;
              developer.log('===========4 ${isStreaming}',
                name: 'ChatRepository', );
              if (chunk != null) {
                yield chunk;
              }
            } else if (decoded['type'] == 'metadata') {
              developer.log('===========5 ${isStreaming}',
                name: 'ChatRepository', );
              yield '[METADATA]${jsonEncode(decoded['metadata'])}';
            }
          } catch (_) {
            continue;
          }

          await Future.delayed(const Duration(milliseconds: 40));
        }
      } finally {
        /// ✅ Always mark streaming ended
        isStreaming = false;
      }
    } catch (e) {
      isStreaming = false; // reset on error too
      yield '[Exception: $e]';
    }
  }

  /// === Helper: wrap calls with headers + error handling ===
  Future<T> _withAuthHeaders<T>(
      Future<T> Function(Map<String, String> headers) action,
      String actionName,
      ) async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null) throw Exception("Missing access token");

      final headers = {
        'accept': 'application/json, text/plain, */*',
        'authorization': 'Bearer $accessToken',
        'origin': 'https://elysia-qa.informa.com',
        'user-agent': 'ElysiaClient/1.0',
      };

      return await action(headers);
    } catch (e, stack) {
      developer.log('❌ $actionName error: $e',
          name: 'ChatRepository', error: e, stackTrace: stack);
      throw Exception('Error in $actionName: $e');
    }
  }

  /// === Helper: extract userId from JWT ===
  String _decodeUserId(String accessToken) {
    final parts = accessToken.split('.');
    if (parts.length != 3) throw Exception("Invalid JWT token");

    final payload =
    utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload)['sub'] as String;
  }
}