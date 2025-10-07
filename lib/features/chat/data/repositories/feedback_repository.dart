import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:elysia/features/auth/service/api_client.dart';
import 'package:elysia/utiltities/core/storage.dart';
import 'package:elysia/utiltities/consts/api_endpoints.dart';

class FeedbackRepository {
  final ApiClient _apiClient = ApiClient();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<String> submitFeedback({
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
      final url = APIEndpoints.feedback;

      final body = {
        'run_id': runId,
        'key': key,
        'score': score,
        'value': value,
      };

      developer.log(
        "📤 Submitting feedback: ${jsonEncode(body)}",
        name: "FeedbackRepository",
      );

      final response = await _apiClient.post(url,data: jsonEncode(body));

       String feedbackId = response.data['data']['feedback_id'];

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log(
          "✅ Feedback submitted successfully",
          name: "FeedbackRepository",
        );
        return feedbackId;
      } else {
        throw Exception('Failed to submit feedback: ${response.statusCode}');
      }
    } catch (e) {
      developer.log(
        "❌ Failed to submit feedback: $e",
        name: "FeedbackRepository",
        error: e,
      );
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

      final url = APIEndpoints.feedbackComment;

      final body = {
        'run_id': runId,
        'key': key,
        'score': score,
        'value': value,
        'comment': comment,
      };

      developer.log(
        "📤 Submitting feedback comment: ${jsonEncode(body)}",
        name: "FeedbackRepository",
      );

      final response = await _apiClient.post(url,data: jsonEncode(body));

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log(
          "✅ Feedback comment submitted successfully",
          name: "FeedbackRepository",
        );
      } else {
        throw Exception(
          'Failed to submit feedback comment: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log(
        "❌ Failed to submit feedback comment: $e",
        name: "FeedbackRepository",
        error: e,
      );
      throw Exception('Failed to submit feedback comment: $e');
    }
  }
}
