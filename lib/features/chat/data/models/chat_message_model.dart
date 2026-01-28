import '../../domain/entities/chat_message.dart';

/// Model for JSON serialization of chat messages
class ChatMessageModel {
  final String role;
  final String content;

  const ChatMessageModel({
    required this.role,
    required this.content,
  });

  /// Convert from domain entity
  factory ChatMessageModel.fromEntity(ChatMessage message) {
    return ChatMessageModel(
      role: message.role,
      content: message.content,
    );
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  /// Convert from JSON (API response)
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }
}
