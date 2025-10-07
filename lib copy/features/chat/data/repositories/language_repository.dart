import 'package:elysia/features/auth/service/api_client.dart';
import 'package:elysia/utiltities/core/storage.dart';
import 'package:elysia/utiltities/consts/api_endpoints.dart';

class LanguageRepository {
  final ApiClient _apiClient = ApiClient();

  /// Fetch languages from the new API using the interceptor
  Future<List<String>> fetchLanguagesFromApi() async {
    try {
      final url = APIEndpoints.getLanguages;
      final response = await _apiClient.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        final languages = (data["data"] ?? data) as List;
        final UserPreferencesStorage _userPreferencesStorage =
            UserPreferencesStorage();
        final langList = languages.map((e) => e.toString()).toList();
        await _userPreferencesStorage.saveSupportedLanguages(langList);
        return langList;
      } else {
        return <String>[];
      }
    } catch (e) {
      return <String>[];
    }
  }
}
