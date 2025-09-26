import 'dart:convert';
import 'package:elysia/features/auth/service/interceptor.dart';
import 'package:elysia/utiltities/consts/api_endpoints.dart';
import 'package:elysia/utiltities/core/storage.dart';
import 'package:elysia/utiltities/jwt-token/decodeJWT.dart';

class UserPreferencesRepository {
  final ApiClient _apiClient = ApiClient();
  final JWTDecoder _jwtDecoder = JWTDecoder();
  final TokenStorage _tokenStorage = TokenStorage();
  final UserPreferencesStorage _userPreferencesStorage = UserPreferencesStorage();

  /// Fetch user preferences from the new API using the interceptor
  Future<Map<String, dynamic>> fetchUserPreferencesFromApi() async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        throw Exception("Access token is missing");
      }
      final userId = await _jwtDecoder.getUserId(token);
      final url = "${APIEndpoints.getUserPreferences}/$userId/default";
      final response = await _apiClient.dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        await _userPreferencesStorage.savePreferredLanguage(data["response_language"]);
        await _userPreferencesStorage.savePreferredModel(data["name_of_model"]);
        return data is Map<String, dynamic> ? data : <String, dynamic>{};
      } else {
        return <String, dynamic>{};
      }
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  Future<Map<String, dynamic>> updateUserPreferencesFromApi({
    required String nameOfModel,
    required String responseLanguage,
  }) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        throw Exception("Access token is missing");
      }
      final userId = await _jwtDecoder.getUserId(token);
      final url = "${APIEndpoints.updateUserPreferences}/$userId/default";
      final body = {
        "name_of_model": nameOfModel,
        "response_language": responseLanguage,
      };
      final response = await _apiClient.dio.put(
        url,
        data: jsonEncode(body));
      if (response.statusCode == 200) {
        final data = response.data;
        await _userPreferencesStorage.savePreferredLanguage(responseLanguage);
        await _userPreferencesStorage.savePreferredModel(nameOfModel);
        return data is Map<String, dynamic> ? data : <String, dynamic>{};
      } else {
        return <String, dynamic>{};
      }
    } catch (e) {
      return <String, dynamic>{};
    }
  }
}
