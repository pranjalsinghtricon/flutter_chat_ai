import 'dart:convert';

class JWTDecoder {
  Future<String> getUserId(String accessToken) async {
    final parts = accessToken.split('.');
    if (parts.length != 3) throw Exception("Invalid JWT token");
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    return jsonDecode(payload)['sub'] as String;
  }
}
