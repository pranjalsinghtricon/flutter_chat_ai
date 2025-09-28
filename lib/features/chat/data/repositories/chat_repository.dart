import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:elysia/providers/private_chat_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add this import
import 'package:elysia/features/auth/service/interceptor.dart'; // ApiClient
import 'package:elysia/utiltities/consts/api_endpoints.dart'; // APIEndpoints
import 'package:elysia/utiltities/core/storage.dart';
import 'package:elysia/utiltities/data-time/timezone.dart';
import 'package:elysia/utiltities/jwt-token/decodeJWT.dart';
import '../../../../utiltities/core/storage.dart';
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

// Make ChatRepository a StateNotifier to make isStreaming reactive
class ChatRepository extends StateNotifier<ChatState> {
  final TokenStorage _tokenStorage = TokenStorage();
  final UserPreferencesStorage _userPreferencesStorage = UserPreferencesStorage();
  final ApiClient _apiClient = ApiClient();
  final JWTDecoder _jwtDecoder = JWTDecoder();
  final Ref _ref;

  ChatRepository(this._ref) : super(const ChatState());

  // Getters for backward compatibility
  bool get isStreaming => state.isStreaming;
  String? get streamingMessageId => state.streamingMessageId;

  // Private method to update streaming state
  void _setStreaming(bool streaming, {String? messageId}) {
    state = state.copyWith(
      isStreaming: streaming,
      streamingMessageId: messageId,
    );
  }

  /// === Fetch chat list grouped by sections ===
  Future<ChatSections> fetchChatsFromApi() async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) throw Exception("Missing access token");
      final userId = await _jwtDecoder.getUserId(accessToken);
      final timezone = await getLocalTimezone();
      final url = '${APIEndpoints.chatHistory}/$userId/conversations?timezone=$timezone';
      final response = await _apiClient.dio.get(url);
      if (response.statusCode == 200) {
        final body = response.data is String ? jsonDecode(response.data) : response.data;
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
    } catch (e, stack) {
      developer.log('❌ fetchChatsFromApi error: $e', name: 'ChatRepository', error: e, stackTrace: stack);
      throw Exception('Error in fetchChatsFromApi: $e');
    }
  }

  /// === Fetch messages for a given session (UPDATED TO EXTRACT RUN_ID) ===
  Future<List<Message>> getMessages(String sessionId) async {
    try {
      final url = '${APIEndpoints.chatSessionMessages}/$sessionId';
      final response = await _apiClient.dio.get(url);
      if (response.statusCode == 200) {
        final body = response.data is String ? jsonDecode(response.data) : response.data;
        final List<Message> result = [];
        final dataList = body['data'] as List? ?? [];

        for (final session in dataList) {
          final historyList = session['history'] as List? ?? [];
          for (final history in historyList) {
            final inputList = history['input'] as List? ?? [];
            final outputList = history['output'] as List? ?? [];
            final readAloudLanguage = history['response_language'] as String?;
            final inputText = inputList.isNotEmpty ? (inputList[0]['text'] ?? "") : "";
            final outputText = outputList.isNotEmpty ? (outputList[0]['text'] ?? "") : "";

            // 🔥 EXTRACT RUN_ID FROM HISTORY
            final runId = history['run_id'] as String?;

            final createdAt = history['createdAt'] != null
                ? DateTime.tryParse(history['createdAt'].toString()) ?? DateTime.now()
                : DateTime.now();

            // User message
            if (inputText.isNotEmpty) {
              result.add(Message(
                id: '',
                sessionId: sessionId,
                content: inputText,
                isUser: true,
                createdAt: createdAt,
                runId: runId, 
                readAloudLanguage: readAloudLanguage,
              ));
            }

            // AI message with run_id
            if (outputText.isNotEmpty) {
              result.add(Message(
                id: '',
                sessionId: sessionId,
                content: outputText,
                isUser: false,
                createdAt: createdAt,
                runId: runId,
                readAloudLanguage: readAloudLanguage,
              ));
            }
          }
        }

        developer.log("✅ Loaded ${result.length} messages with run_ids for session: $sessionId", name: "ChatRepository");
        return result;
      } else if (response.statusCode == 404) {
        // ✅ No messages found yet → return empty list instead of crashing
        developer.log("ℹ️ No messages yet for session $sessionId", name: "ChatRepository");
        return [];
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('❌ getMessages error: $e', name: 'ChatRepository', error: e, stackTrace: stack);
      throw Exception('Error in getMessages: $e');
    }
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
    String? messageId, // Add messageId parameter
  }) async* {
    try {
      final response_language = await _userPreferencesStorage.getPreferredLanguage();
      final isPrivate = _ref.read(privateChatProvider);

      final url = APIEndpoints.chatStreamCompletion;
      final body = {
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
        "private_chat": isPrivate,
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
        "response_language": response_language ?? "English (US)",
        "default_response_language": response_language ?? "English (US)",
        "default_name_of_model": "gpt-4o",
        "name_of_model": "gpt-4o"
      };

      // 🚀 Log request body
      developer.log("📤 Sending request body: ${jsonEncode(body)}", name: "ChatRepository");

      /// ✅ Mark streaming started with message ID
      _setStreaming(true, messageId: messageId);
      String fullResponse = "";

      try {
        final response = await _apiClient.dio.post(
          url,
          data: jsonEncode(body),
          options: Options(responseType: ResponseType.stream),
        );

        developer.log("✅ Streaming started", name: "ChatRepository");

        final stream = response.data.stream.cast<List<int>>().transform(utf8.decoder).transform(const LineSplitter());
        await for (final line in stream) {
          if (line.trim().isEmpty) continue;

          // 👀 Log raw API response line
          developer.log("📥 RAW LINE: $line", name: "ChatRepository");

          try {
            final Map<String, dynamic> decoded = jsonDecode(line) as Map<String, dynamic>;

            developer.log("🔎 Decoded JSON: $decoded", name: "ChatRepository");

            if (decoded['type'] == 'answer') {
              final chunk = decoded['answer'] as String?;
              if (chunk != null) {
                developer.log("✂️ ANSWER CHUNK: $chunk", name: "ChatRepository");
                fullResponse += chunk;
                yield chunk;
              }
            } else if (decoded['type'] == 'metadata') {
              final metadata = jsonEncode(decoded['metadata']);
              developer.log("📊 METADATA: $metadata", name: "ChatRepository");
              yield '[METADATA]${jsonEncode(decoded['metadata'])}';
            }
          } catch (err) {
            developer.log("⚠️ Failed to decode line: $line", name: "ChatRepository", error: err);
            continue;
          }

          await Future.delayed(const Duration(milliseconds: 40));
        }
      } finally {
        _setStreaming(false, messageId: null);
        developer.log("🏁 Streaming ended. FULL RESPONSE: $fullResponse", name: "ChatRepository");
      }
    } catch (e) {
      _setStreaming(false, messageId: null);
      developer.log("💥 Exception in sendPromptStream: $e", name: "ChatRepository", error: e);
      yield '[Exception: $e]';
    }
  }

  // 🔥 UPDATED METHOD TO PROPERLY EXTRACT RUN_ID FROM METADATA
  Stream<Map<String, dynamic>> sendPromptStreamWithRunId({
    required String prompt,
    required String sessionId,
    String? messageId,
  }) async* {
    final isPrivate = _ref.read(privateChatProvider);
    try {
      final response_language = await _userPreferencesStorage.getPreferredLanguage();
      final url = APIEndpoints.chatStreamCompletion;
      final body = {
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
        "private_chat": isPrivate,
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
        "response_language": response_language ?? "English (US)",
        "default_response_language": response_language ?? "English (US)",
        "default_name_of_model": "gpt-4o",
        "name_of_model": "gpt-4o"
      };
      
      developer.log("📤 Sending request body: ${jsonEncode(body)}", name: "ChatRepository");

      _setStreaming(true, messageId: messageId);
      String? extractedRunId;

      try {
        final response = await _apiClient.dio.post(
          url,
          data: jsonEncode(body),
          options: Options(responseType: ResponseType.stream),
        );

        developer.log("✅ Streaming started", name: "ChatRepository");

        final stream = response.data.stream.cast<List<int>>().transform(utf8.decoder).transform(const LineSplitter());
        await for (final line in stream) {
          if (line.trim().isEmpty) continue;

          developer.log("📥 RAW LINE: $line", name: "ChatRepository");

          try {
            final Map<String, dynamic> decoded = jsonDecode(line) as Map<String, dynamic>;

            if (decoded['type'] == 'answer') {
              final chunk = decoded['answer'] as String?;
              if (chunk != null) {
                developer.log("✂️ ANSWER CHUNK: $chunk", name: "ChatRepository");
                yield {
                  'type': 'answer',
                  'chunk': chunk,
                  'run_id': extractedRunId,
                };
              }
            } else if (decoded['type'] == 'metadata') {
              developer.log("📊 METADATA: ${decoded['metadata']}", name: "ChatRepository");

              // 🔥 EXTRACT RUN_ID FROM METADATA
              final metadata = decoded['metadata'] as Map<String, dynamic>;
              if (metadata.containsKey('run_id') && extractedRunId == null) {
                extractedRunId = metadata['run_id'] as String?;
                developer.log("🆔 Extracted run_id from metadata: $extractedRunId", name: "ChatRepository");

                // Yield run_id as soon as we get it
                if (extractedRunId != null) {
                  yield {
                    'type': 'run_id',
                    'run_id': extractedRunId,
                  };
                }
              }

              yield {
                'type': 'metadata',
                'metadata': metadata,
                'run_id': extractedRunId,
              };
            }
          } catch (err) {
            developer.log("⚠️ Failed to decode line: $line", name: "ChatRepository", error: err);
            continue;
          }

          await Future.delayed(const Duration(milliseconds: 40));
        }
      } finally {
        _setStreaming(false, messageId: null);
        developer.log("🏁 Streaming ended with run_id: $extractedRunId", name: "ChatRepository");
      }
    } catch (e) {
      _setStreaming(false, messageId: null);
      developer.log("💥 Exception in sendPromptStreamWithRunId: $e", name: "ChatRepository", error: e);
      yield {
        'type': 'error',
        'error': e.toString(),
      };
    }
  }
}

// Add ChatState class
class ChatState {
  final bool isStreaming;
  final String? streamingMessageId;

  const ChatState({
    this.isStreaming = false,
    this.streamingMessageId,
  });

  ChatState copyWith({
    bool? isStreaming,
    String? streamingMessageId,
  }) {
    return ChatState(
      isStreaming: isStreaming ?? this.isStreaming,
      streamingMessageId: streamingMessageId,
    );
  }
}