import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message_model.dart';

/// Remote data source for chat API calls
abstract class ChatRemoteDataSource {
  /// Send messages and get streaming response
  Stream<String> sendMessage(List<ChatMessageModel> messages);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  static const String _defaultEndpoint =
      'https://offline-ai-classroom.trident.software/v1/chat/completions';
  static const String _model = 'local-llm';
  static const double _temperature = 0.3;
  static const int _maxTokens = 256;

  final String endpoint;
  final http.Client _client;

  ChatRemoteDataSourceImpl({
    String? endpoint,
    http.Client? client,
  })  : endpoint = endpoint ?? _defaultEndpoint,
        _client = client ?? http.Client();

  @override
  Stream<String> sendMessage(List<ChatMessageModel> messages) async* {
    final body = jsonEncode({
      'model': _model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'temperature': _temperature,
      'max_tokens': _maxTokens,
      'stream': true,
    });

    try {
      final request = http.Request('POST', Uri.parse(endpoint));
      request.headers['Content-Type'] = 'application/json';
      request.body = body;

      final response = await _client.send(request);

      if (response.statusCode != 200) {
        throw ChatApiException(
          'API error: ${response.statusCode}',
          response.statusCode,
        );
      }

      // Parse SSE stream
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        // Split by newlines to handle multiple events in one chunk
        final lines = chunk.split('\n');

        for (final line in lines) {
          if (line.isEmpty) continue;
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();

            // Check for stream end
            if (data == '[DONE]') {
              return;
            }

            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              final choices = json['choices'] as List<dynamic>?;
              if (choices != null && choices.isNotEmpty) {
                final delta = choices[0]['delta'] as Map<String, dynamic>?;
                if (delta != null) {
                  final content = delta['content'] as String?;
                  if (content != null && content.isNotEmpty) {
                    yield content;
                  }
                }
              }
            } catch (e) {
              // Skip malformed JSON
              debugPrint('ChatRemoteDataSource: Error parsing chunk: $e');
            }
          }
        }
      }
    } catch (e) {
      if (e is ChatApiException) rethrow;
      throw ChatApiException('Connection error: $e', 0);
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Exception for chat API errors
class ChatApiException implements Exception {
  final String message;
  final int statusCode;

  ChatApiException(this.message, this.statusCode);

  @override
  String toString() => 'ChatApiException: $message (status: $statusCode)';
}
