import 'package:equatable/equatable.dart';

/// Chat message entity
class ChatMessage extends Equatable {
  final String id;
  final String role; // 'user' | 'assistant' | 'system'
  final String content;
  final DateTime timestamp;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isError = false,
  });

  /// Create a user message
  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  /// Create an assistant message
  factory ChatMessage.assistant(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  /// Create a system message
  factory ChatMessage.system(String content) {
    return ChatMessage(
      id: 'system',
      role: 'system',
      content: content,
      timestamp: DateTime.now(),
    );
  }

  /// Create an error message
  factory ChatMessage.error(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      content: content,
      timestamp: DateTime.now(),
      isError: true,
    );
  }

  /// Copy with new content (for streaming updates)
  ChatMessage copyWith({String? content}) {
    return ChatMessage(
      id: id,
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
      isError: isError,
    );
  }

  @override
  List<Object?> get props => [id, role, content, timestamp, isError];
}
