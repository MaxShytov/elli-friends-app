import 'package:equatable/equatable.dart';

/// Base class for chat events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize chat with system prompt
class ChatStarted extends ChatEvent {
  const ChatStarted();
}

/// Send a message to the AI
class SendMessage extends ChatEvent {
  final String text;

  const SendMessage(this.text);

  @override
  List<Object?> get props => [text];
}

/// Received a chunk from streaming response
class MessageChunkReceived extends ChatEvent {
  final String chunk;

  const MessageChunkReceived(this.chunk);

  @override
  List<Object?> get props => [chunk];
}

/// Streaming response completed
class MessageCompleted extends ChatEvent {
  const MessageCompleted();
}

/// Error occurred during streaming
class MessageError extends ChatEvent {
  final String error;

  const MessageError(this.error);

  @override
  List<Object?> get props => [error];
}

/// Clear chat history
class ClearChat extends ChatEvent {
  const ClearChat();
}

/// Speak the last assistant message
class SpeakLastMessage extends ChatEvent {
  const SpeakLastMessage();
}
