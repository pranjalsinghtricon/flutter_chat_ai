import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:elysia/utiltities/core/storage.dart'; // TokenStorage
import 'package:http/http.dart' as http;

class ChatActionsRepository {
	final TokenStorage _tokenStorage = TokenStorage();

	Future<String> archiveChat({required String sessionId}) async {
		return _withAuthHeaders((headers) async {
			final body = jsonEncode({'session_id': sessionId});
			final url = Uri.parse('https://stream-api-qa.iiris.com/v2/ai/chat/archive');
			final response = await http.patch(url, headers: headers, body: body);

			if (response.statusCode == 200) {
				return response.body;
			} else {
				throw Exception('Failed to archive chat: ${response.statusCode}');
			}
		}, 'archiveChat');
	}

	Future<String> renameChat({required String sessionId, required String title}) async {
		return _withAuthHeaders((headers) async {
			final body = jsonEncode({'session_id': sessionId, 'title': title});
			final url = Uri.parse('https://stream-api-qa.iiris.com/v2/ai/chat/title:rename');
			final response = await http.patch(url, headers: headers, body: body);

			if (response.statusCode == 200) {
				return response.body;
			} else {
				throw Exception('Failed to rename chat: ${response.statusCode}');
			}
		}, 'renameChat');
	}

	Future<String> deleteChatSession({required String sessionId}) async {
		return _withAuthHeaders((headers) async {
			final url = Uri.parse(
				'https://stream-api-qa.iiris.com/v2/ai/chat/conversation/session/$sessionId',
			);
			final response = await http.delete(url, headers: headers);

			if (response.statusCode == 200) {
				return response.body;
			} else {
				throw Exception('Failed to delete chat: ${response.statusCode}');
			}
		}, 'deleteChatSession');
	}

	/// 🔑 Private helper that automatically injects auth headers
	Future<String> _withAuthHeaders(
			Future<String> Function(Map<String, String> headers) action,
			String actionName,
			) async {
		try {
			final accessToken = await _tokenStorage.getAccessToken();
			if (accessToken == null) throw Exception("Missing access token");

			final headers = {
				'accept': 'application/json, text/plain, */*',
				'authorization': 'Bearer $accessToken',
				'origin': 'https://elysia-qa.informa.com',
				'content-type': 'application/json',
			};

			return await action(headers);
		} catch (e, stack) {
			developer.log('❌ $actionName error: $e',
					name: 'ChatActionsRepository', error: e, stackTrace: stack);
			throw Exception('Error in $actionName: $e');
		}
	}
}
