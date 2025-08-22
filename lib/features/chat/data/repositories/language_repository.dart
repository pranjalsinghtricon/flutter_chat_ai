import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';

class LanguageRepository {
  static const String boxName = "languages";

  Future<List<String>> fetchLanguagesFromApi() async {
    final response = await http.get(Uri.parse("http://demo0405258.mockable.io/languages"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)["data"];
      final languages = List<String>.from(data);

      final box = await Hive.openBox<String>(boxName);
      await box.clear();
      await box.addAll(languages);

      return languages;
    } else {
      throw Exception("Failed to load languages");
    }
  }

  Future<List<String>> getLocalLanguages() async {
    final box = await Hive.openBox<String>(boxName);
    return box.values.toList();
  }


}
