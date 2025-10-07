import 'package:elysia/features/auth/service/api_client.dart';
import 'package:elysia/features/chat/data/models/saved_prompt_model.dart';
import 'package:elysia/utiltities/consts/api_endpoints.dart';
import 'package:elysia/utiltities/core/storage.dart';
import 'package:elysia/utiltities/jwt-token/decodeJWT.dart';
import 'dart:developer' as developer;

class SavedPromptRepository {
  final TokenStorage _tokenStorage = TokenStorage();
  final JWTDecoder _jwtDecoder = JWTDecoder();
  final ApiClient _apiClient = ApiClient();

  Future<List<SavedPrompt>> fetchSavedPrompts() async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("Missing access token");
      }

      final userId = await _jwtDecoder.getUserId(accessToken);
      final url = '${APIEndpoints.savedPrompts}/$userId/prompts';

      developer.log("🔍 Fetching saved prompts for user: $userId",
          name: "SavedPromptRepository");

      final response = await _apiClient.dio.get(url);
      // final response = await _apiClient.get(url);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final prompts = data.map((e) => SavedPrompt.fromJson(e)).toList();
        developer.log("✅ Fetched ${prompts.length} saved prompts",
            name: "SavedPromptRepository");
        return prompts;
      } else {
        throw Exception('Failed to load saved prompts: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log("❌ Error fetching saved prompts: $e",
          name: "SavedPromptRepository",
          error: e,
          stackTrace: stack
      );
      rethrow;
    }
  }

  Future<void> savePrompt(String prompt) async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("Missing access token");
      }

      final userId = await _jwtDecoder.getUserId(accessToken);
      final url = '${APIEndpoints.savedPrompts}/$userId/prompts';

      // final response = await _apiClient.post(
      final response = await _apiClient.dio.post(
        url,
        data: {'prompt': prompt},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save prompt: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log("❌ Error saving prompt: $e",
          name: "SavedPromptRepository",
          error: e,
          stackTrace: stack
      );
      rethrow;
    }
  }

  Future<void> deletePrompt(int promptId) async {
    try {
      // Use the existing deleteSavedPrompt endpoint
      final url = '${APIEndpoints.deleteSavedPrompt}/$promptId';

      developer.log("🗑️ Deleting prompt with ID: $promptId at URL: $url",
          name: "SavedPromptRepository");

      // final response = await _apiClient.delete(url);
      final response = await _apiClient.dio.delete(url);

      developer.log("✅ Delete response: ${response.statusCode}",
          name: "SavedPromptRepository");

      if (response.statusCode != 200) {
        throw Exception('Failed to delete prompt: ${response.statusCode}');
      }

    } catch (e, stack) {
      developer.log("❌ Error deleting prompt: $e",
          name: "SavedPromptRepository",
          error: e,
          stackTrace: stack
      );
      rethrow;
    }
  }
}