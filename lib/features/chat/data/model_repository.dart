import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../data/models/chat_model.dart';

class ModelRepository {
  static const String boxName = "models";

  Future<List<String>> fetchModelsFromApi() async {
    final response = await http.get(Uri.parse("http://demo0405258.mockable.io/models"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)["data"];
      final models = List<String>.from(data);

      final box = await Hive.openBox<String>(boxName);
      await box.clear();
      await box.addAll(models);

      return models;
    } else {
      throw Exception("Failed to load models");
    }
  }

  Future<List<String>> getLocalModels() async {
    final box = await Hive.openBox<String>(boxName);
    return box.values.toList();
  }
}
