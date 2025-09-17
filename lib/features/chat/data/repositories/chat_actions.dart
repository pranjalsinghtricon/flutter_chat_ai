
import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:elysia/features/auth/service/service.dart';
import 'package:http/http.dart' as http;

class ChatActionsRepository {
	/// Archives a chat session by sessionId
	Future<String> archiveChat({required String sessionId}) async {
		try {
			final authService = AuthService();
			final accessToken = await authService.getAccessToken();
			if (accessToken == null) {
				throw Exception("Missing access token");
			}

			final headers = {
				'accept': 'application/json, text/plain, */*',
				'authorization': 'Bearer $accessToken',
				'origin': 'https://elysia-qa.informa.com'
			};

			final body = jsonEncode({
				'session_id': sessionId,
			});

			final url = Uri.parse('https://stream-api-qa.iiris.com/v2/ai/chat/archive');
			final response = await http.patch(url, headers: headers, body: body);

			if (response.statusCode == 200) {
				return response.body;
			} else {
				throw Exception('Failed to archive chat: {response.statusCode}');
			}
		} catch (e, stack) {
			developer.log('❌ archiveChat error: $e', name: 'ChatActionsRepository', error: e, stackTrace: stack);
			throw Exception('Error archiving chat: $e');
		}
	}

	/// Renames a chat session title by sessionId
	Future<String> renameChat({required String sessionId, required String title}) async {
		try {
			final authService = AuthService();
			final accessToken = await authService.getAccessToken();
			if (accessToken == null) {
				throw Exception("Missing access token");
			}

			final headers = {
				'accept': 'application/json, text/plain, */*',
				'authorization': 'Bearer $accessToken',
				'origin': 'https://elysia-qa.informa.com',
				'content-type': 'application/json',
			};

			final body = jsonEncode({
				'session_id': sessionId,
				'title': title,
			});

			final url = Uri.parse('https://stream-api-qa.iiris.com/v2/ai/chat/title:rename');
			final response = await http.patch(url, headers: headers, body: body);

			if (response.statusCode == 200) {
				return response.body;
			} else {
				throw Exception('Failed to rename chat: ${response.statusCode}');
			}
		} catch (e, stack) {
			developer.log('❌ renameChat error: $e', name: 'ChatActionsRepository', error: e, stackTrace: stack);
			throw Exception('Error renaming chat: $e');
		}
	}

  Future<String> deleteChatSession({required String sessionId}) async {
    try {
      final authService = AuthService();
      final accessToken = await authService.getAccessToken();
      if (accessToken == null) {
        throw Exception("Missing access token");
      }

      final headers = {
        'accept': 'application/json, text/plain, */*',
        'authorization': 'Bearer $accessToken',
        'origin': 'https://elysia-qa.informa.com',
      };

      final url = Uri.parse(
        'https://stream-api-qa.iiris.com/v2/ai/chat/conversation/session/$sessionId',
      );
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
				return response.body;
			} else {
				throw Exception('Failed to delete chat: ${response.statusCode}');
			}
    } catch (e, stack) {
      developer.log('❌ deleteChatSession error: $e', name: 'ChatSessionService', error: e, stackTrace: stack);
      throw Exception('Error deleting chat session: $e');
    }
  }
}
