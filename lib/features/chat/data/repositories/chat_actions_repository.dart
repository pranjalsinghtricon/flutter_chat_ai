import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:elysia/features/auth/service/interceptor.dart'; // ApiClient
import 'package:elysia/utiltities/core/storage.dart'; // TokenStorage

class ChatActionsRepository {
	final ApiClient _apiClient = ApiClient();
	final TokenStorage _tokenStorage = TokenStorage();

	Future<String> archiveChat({required String sessionId}) async {
		try {
			final body = jsonEncode({'session_id': sessionId});
			final url = 'https://stream-api-qa.iiris.com/v2/ai/chat/archive';
			final response = await _apiClient.dio.patch(url, data: body);
			return response.data is String ? response.data : jsonEncode(response.data);
		} catch (e, stack) {
			developer.log('❌ archiveChat error: $e', name: 'ChatActionsRepository', error: e, stackTrace: stack);
			throw Exception('Error in archiveChat: $e');
		}
	}

	Future<String> renameChat({required String sessionId, required String title}) async {
		try {
			final url = 'https://stream-api-qa.iiris.com/v2/ai/chat/title:rename';
			final body = jsonEncode({'session_id': sessionId, 'title': title});
			final response = await _apiClient.dio.patch(url, data: body);
			if (response.statusCode == 200) {
				return response.data is String ? response.data : jsonEncode(response.data);
			} else {
				throw Exception('Failed to rename chat: ${response.statusCode}');
			}
		} catch (e, stack) {
			developer.log('❌ renameChat error: $e', name: 'ChatActionsRepository', error: e, stackTrace: stack);
			throw Exception('Error in renameChat: $e');
		}
	}

	Future<String> deleteChatSession({required String sessionId}) async {
		try {
			final url = 'https://stream-api-qa.iiris.com/v2/ai/chat/conversation/session/$sessionId';
			final response = await _apiClient.dio.delete(url);
			return response.data is String ? response.data : jsonEncode(response.data);
		} catch (e, stack) {
			developer.log('❌ deleteChatSession error: $e', name: 'ChatActionsRepository', error: e, stackTrace: stack);
			throw Exception('Error in deleteChatSession: $e');
		}
	}
}
