import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
