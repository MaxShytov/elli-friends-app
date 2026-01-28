import '../entities/chat_message.dart';

/// Abstract repository for chat operations
abstract class ChatRepository {
  /// Send messages and get streaming response
  /// Returns a stream of content chunks
  Stream<String> sendMessage(List<ChatMessage> messages);

  /// Get the system prompt for child-friendly AI
  String getSystemPrompt();
}
