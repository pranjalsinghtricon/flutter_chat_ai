import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:elysia/features/auth/service/interceptor.dart';
import 'package:elysia/utiltities/core/storage.dart';

class FeedbackRepository {
  final ApiClient _apiClient = ApiClient();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<void> submitFeedback({
    required String runId,
    required String key,
    required bool score,
    required int value,
  }) async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("Missing access token");
      }

      // Construct the feedback API URL
      const baseUrl = 'https://stream-api-qa.iiris.com/v2/ai/chat/feedback';

      final body = {
        'run_id': runId,
        'key': key,
        'score': score,
        'value': value,
      };

      developer.log("📤 Submitting feedback: ${jsonEncode(body)}", name: "FeedbackRepository");

      final response = await _apiClient.dio.post(
        baseUrl,
        data: jsonEncode(body),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log("✅ Feedback submitted successfully", name: "FeedbackRepository");
      } else {
        throw Exception('Failed to submit feedback: ${response.statusCode}');
      }
    } catch (e) {
      developer.log("❌ Failed to submit feedback: $e", name: "FeedbackRepository", error: e);
      throw Exception('Failed to submit feedback: $e');
    }
  }

  /// Submit feedback comment using run_id
  Future<void> submitFeedbackComment({
    required String runId,
    required String key,
    required bool score,
    required int value,
    required String comment,
  }) async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("Missing access token");
      }

      const baseUrl = 'https://stream-api-qa.iiris.com/v2/ai/chat/feedback';

      final body = {
        'run_id': runId,
        'key': key,
        'score': score,
        'value': value,
        'comment': comment,
      };

      developer.log("📤 Submitting feedback comment: ${jsonEncode(body)}", name: "FeedbackRepository");

      final response = await _apiClient.dio.post(
        baseUrl,
        data: jsonEncode(body),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log("✅ Feedback comment submitted successfully", name: "FeedbackRepository");
      } else {
        throw Exception('Failed to submit feedback comment: ${response.statusCode}');
      }
    } catch (e) {
      developer.log("❌ Failed to submit feedback comment: $e", name: "FeedbackRepository", error: e);
      throw Exception('Failed to submit feedback comment: $e');
    }
  }
}