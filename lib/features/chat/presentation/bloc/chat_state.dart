import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

/// Base class for chat states
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state before chat is started
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Chat is loaded with messages
class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isStreaming;
  final String? streamingContent;

  const ChatLoaded({
    required this.messages,
    this.isStreaming = false,
    this.streamingContent,
  });

  /// Get visible messages (excluding system message)
  List<ChatMessage> get visibleMessages =>
      messages.where((m) => m.role != 'system').toList();

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    String? streamingContent,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      streamingContent: streamingContent,
    );
  }

  @override
  List<Object?> get props => [messages, isStreaming, streamingContent];
}

/// Error state
class ChatError extends ChatState {
  final String message;
  final List<ChatMessage> previousMessages;

  const ChatError({
    required this.message,
    required this.previousMessages,
  });

  @override
  List<Object?> get props => [message, previousMessages];
}
