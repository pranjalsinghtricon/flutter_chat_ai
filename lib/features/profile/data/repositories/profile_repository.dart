import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileRepository {
  final String baseUrl;

  ProfileRepository({required this.baseUrl});

  Future<String?> fetchFullName(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v2/ai/profile/self'),
      headers: {'accept': 'application/json', 'authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List<dynamic>;
      if (data.isNotEmpty) {
        return data[0]['doc']['full_name'] as String?;
      }
    }
    return null;
  }
}
