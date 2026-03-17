// lib/services/claude_service.dart
//
// Week 1: This file is a STUB — it exists so the project compiles cleanly.
// Week 2: Fill in the real HTTP logic here.

import 'package:http/http.dart' as http;
import 'dart:convert';

class ClaudeService {
  // ── Replace with your real key in Week 2 ──────────────────────────────────
  // IMPORTANT: Never commit an API key to version control.
  // Use a .env file or Flutter's --dart-define flag in production.
  static const String _apiKey = 'YOUR_CLAUDE_API_KEY_HERE';

  static const String _endpoint = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-sonnet-4-20250514';

  /// Sends a user message to the Claude API and returns the AI's reply.
  ///
  /// [userMessage] — the text the user typed
  /// [systemPrompt] — optional persona/system instruction (Week 3)
  ///
  /// Throws a [ClaudeException] on non-200 responses.
  Future<String> sendMessage(
      String userMessage, {
        String systemPrompt = 'You are a helpful AI assistant.',
      }) async {
    // ── Week 1 stub — remove when implementing in Week 2 ──────────────────
    throw UnimplementedError(
      'ClaudeService.sendMessage() is not yet implemented. '
          'Complete Week 2 to wire this up.',
    );

    // ── Week 2 implementation skeleton (uncomment & fill in) ──────────────
    /*
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'system': systemPrompt,
          'messages': [
            {'role': 'user', 'content': userMessage},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] as String;
      } else {
        final error = jsonDecode(response.body);
        throw ClaudeException(
          'API error ${response.statusCode}: ${error['error']['message']}',
        );
      }
    } on http.ClientException catch (e) {
      throw ClaudeException('Network error: $e');
    }
    */
  }
}

/// Custom exception so the UI can show friendly error messages.
class ClaudeException implements Exception {
  final String message;
  const ClaudeException(this.message);

  @override
  String toString() => 'ClaudeException: $message';
}