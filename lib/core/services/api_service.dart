import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  final String _baseUrl =
      "http://demo0405258.mockable.io/chat-ai/conversation4";
  // "http://demo0405258.mockable.io/chat-ai/conversation3";
  // "http://demo0405258.mockable.io/chat-ai/conversation2";
  // "http://demo0405258.mockable.io/chat-ai/conversation4";

  Stream<String> sendPromptStream(String prompt) async* {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final lines = const LineSplitter().convert(response.body);

        for (final line in lines) {
          if (line.trim().isEmpty) continue;

          try {
            final Map<String, dynamic> decoded =
            jsonDecode(line) as Map<String, dynamic>;

            final String? type = decoded["type"] as String?;
            if (type == null) continue;

            if (type == "answer") {
              final String? chunk = decoded["answer"] as String?;
              if (chunk != null) {
                yield chunk;
              }
            }
            // metadata and unknown types are ignored safely
          } catch (_) {
            // Skip invalid JSON lines silently
            continue;
          }

          await Future.delayed(const Duration(milliseconds: 50));
        }
      } else {
        yield "[Error: ${response.statusCode}]";
      }
    } catch (e) {
      yield "[Exception: $e]";
    }
  }
}