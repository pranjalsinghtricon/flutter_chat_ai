import 'package:elysia/features/auth/service/api_client.dart';
import 'package:elysia/utiltities/core/storage.dart';
import 'package:elysia/utiltities/consts/api_endpoints.dart';

import 'package:elysia/features/auth/service/api_client.dart';
import 'package:elysia/utiltities/core/storage.dart';
import 'package:elysia/utiltities/consts/api_endpoints.dart';

class AiModelRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> fetchModelsFromApi() async {
    try {
      final url = APIEndpoints.getModels;
      final response = await _apiClient.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        final models = (data["data"] as List)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        final UserPreferencesStorage _userPreferencesStorage =
            UserPreferencesStorage();
        await _userPreferencesStorage.saveSupportedModels(models);

        return models;
      } else {
        return <Map<String, dynamic>>[];
      }
    } catch (e) {
      print("Error fetching models: $e");
      return <Map<String, dynamic>>[];
    }
  }
}
