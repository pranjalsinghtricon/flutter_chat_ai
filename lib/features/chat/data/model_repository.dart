import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class ModelRepository {
  static const String boxName = "models";

  Future<List<String>> fetchModelsFromApi() async {
    final response = await http.get(Uri.parse("http://demo0405258.mockable.io/models"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)["data"];
      final List<String> displayNames = (data as List)
          .map((item) => item["display_name"] as String)
          .toList();

      final box = await Hive.openBox<String>(boxName);
      await box.clear();
      await box.addAll(displayNames);

      return displayNames;
    } else {
      throw Exception("Failed to load models");
    }
  }


  Future<List<String>> getLocalModels() async {
    final box = await Hive.openBox<String>(boxName);
    return box.values.toList();
  }
}
