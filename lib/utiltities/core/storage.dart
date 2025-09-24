import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class TokenStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> clearAccessToken() async {
    await _storage.delete(key: 'access_token');
  }

  Future<void> clearAllStorage() async {
    await _storage.deleteAll();
  }
}


class UserPreferencesStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> savePreferredLanguage(String language) async {
    await _storage.write(key: 'response_language', value: language);
  }

  Future<String?> getPreferredLanguage() async {
    return await _storage.read(key: 'response_language');
  }

  Future<void> clearPreferredLanguage() async {
    await _storage.delete(key: 'response_language');
  }

  Future<void> savePreferredModel(String model) async {
    await _storage.write(key: 'name_of_model', value: model);
  }

  Future<String?> getPreferredModel() async {
    return await _storage.read(key: 'name_of_model');
  }

  Future<void> clearPreferredModel() async {
    await _storage.delete(key: 'name_of_model');
  }

  Future<void> saveSupportedLanguages(List<String> languages) async {
    // Store as JSON string
    await _storage.write(key: 'language_list', value: jsonEncode(languages));
  }

  Future<List<String>?> getSupportedLanguages() async {
    final value = await _storage.read(key: 'language_list');
    return value == null ? null : List<String>.from(jsonDecode(value));
  }

  Future<void> clearSupportedLanguages() async {
    await _storage.delete(key: 'language_list');
  }
}

