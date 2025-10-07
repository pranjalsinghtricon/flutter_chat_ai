import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:elysia/features/auth/service/api_client.dart'; // ApiClient
import 'package:elysia/utiltities/core/storage.dart'; // TokenStorage
import 'package:elysia/utiltities/consts/api_endpoints.dart'; // APIEndpoints

class ChatActionsRepository {
  final ApiClient _apiClient = ApiClient();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<String> archiveChat({required String sessionId}) async {
    try {
      final body = jsonEncode({'session_id': sessionId});
      final url = APIEndpoints.archiveChat;
      final response = await _apiClient.patch(url, data: body);
      return response.data is String
          ? response.data
          : jsonEncode(response.data);
    } catch (e, stack) {
      developer.log(
        '❌ archiveChat error: $e',
        name: 'ChatActionsRepository',
        error: e,
        stackTrace: stack,
      );
      throw Exception('Error in archiveChat: $e');
    }
  }

  Future<String> renameChat({
    required String sessionId,
    required String title,
  }) async {
    try {
      final url = APIEndpoints.renameChat;
      final body = jsonEncode({'session_id': sessionId, 'title': title});
      final response = await _apiClient.patch(url, data: body);
      if (response.statusCode == 200) {
        return response.data is String
            ? response.data
            : jsonEncode(response.data);
      } else {
        throw Exception('Failed to rename chat: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log(
        '❌ renameChat error: $e',
        name: 'ChatActionsRepository',
        error: e,
        stackTrace: stack,
      );
      throw Exception('Error in renameChat: $e');
    }
  }

  Future<String> deleteChatSession({required String sessionId}) async {
    try {
      final url = '${APIEndpoints.deleteChatSession}/$sessionId';
      final response = await _apiClient.delete(url);
      return response.data is String
          ? response.data
          : jsonEncode(response.data);
    } catch (e, stack) {
      developer.log(
        '❌ deleteChatSession error: $e',
        name: 'ChatActionsRepository',
        error: e,
        stackTrace: stack,
      );
      throw Exception('Error in deleteChatSession: $e');
    }
  }
}
