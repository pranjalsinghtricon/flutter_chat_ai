import 'dart:async';
import 'dart:convert';

class ApiService {
  final String _baseUrl = 'http://demo0405258.mockable.io/chat-ai/conversation4';

  /// Mock streaming endpoint. `sessionId` is accepted so you can wire it
  /// to a real backend later without changing callers.
  Stream<String> sendPromptStream(String prompt, {required String sessionId}) async* {
    try {
      final response = await Future.any([
        // Using GET to a mock URL; swap to your POST with body {prompt, sessionId}
        // when a real backend is ready.
        _fakeHttpGet(_baseUrl),
        Future.delayed(const Duration(seconds: 30), () => throw TimeoutException('timeout')),
      ]);

      final lines = const LineSplitter().convert(response);
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          final Map<String, dynamic> decoded = jsonDecode(line) as Map<String, dynamic>;
          final String? type = decoded['type'] as String?;
          if (type == 'answer') {
            final chunk = decoded['answer'] as String?;
            if (chunk != null) yield chunk;
          }
        } catch (_) {
          continue;
        }
        await Future.delayed(const Duration(milliseconds: 40));
      }
    } catch (e) {
      yield '[Exception: $e]';
    }
  }

  // Pretend GET that returns the mockable body as string
  Future<String> _fakeHttpGet(String url) async {
    // NOTE: Replace with `http.get(Uri.parse(url)).then((r) => r.body)`
    // in a real implementation. Kept minimal here to avoid adding imports.
    throw UnimplementedError('Wire up real HTTP client here.');
  }
}
