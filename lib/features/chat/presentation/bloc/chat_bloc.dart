import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/audio_manager.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/// BLoC for managing chat state
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  final AudioManager _audioManager;
  StreamSubscription<String>? _streamSubscription;
  StringBuffer _currentResponse = StringBuffer();

  ChatBloc({
    ChatRepository? repository,
    AudioManager? audioManager,
  })  : _repository = repository ?? ChatRepositoryImpl(),
        _audioManager = audioManager ?? AudioManager(),
        super(const ChatInitial()) {
    on<ChatStarted>(_onChatStarted);
    on<SendMessage>(_onSendMessage);
    on<MessageChunkReceived>(_onMessageChunkReceived);
    on<MessageCompleted>(_onMessageCompleted);
    on<MessageError>(_onMessageError);
    on<ClearChat>(_onClearChat);
    on<SpeakLastMessage>(_onSpeakLastMessage);
  }

  void _onChatStarted(ChatStarted event, Emitter<ChatState> emit) {
    final systemMessage = ChatMessage.system(_repository.getSystemPrompt());
    emit(ChatLoaded(messages: [systemMessage]));
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;
    if (event.text.trim().isEmpty) return;

    // Cancel any existing stream
    await _streamSubscription?.cancel();
    _currentResponse.clear();

    // Add user message
    final userMessage = ChatMessage.user(event.text.trim());
    final updatedMessages = [...currentState.messages, userMessage];

    emit(ChatLoaded(
      messages: updatedMessages,
      isStreaming: true,
      streamingContent: '',
    ));

    // Start streaming
    try {
      _streamSubscription = _repository.sendMessage(updatedMessages).listen(
        (chunk) => add(MessageChunkReceived(chunk)),
        onError: (error) => add(MessageError(error.toString())),
        onDone: () => add(const MessageCompleted()),
      );
    } catch (e) {
      add(MessageError(e.toString()));
    }
  }

  void _onMessageChunkReceived(
    MessageChunkReceived event,
    Emitter<ChatState> emit,
  ) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    _currentResponse.write(event.chunk);

    emit(currentState.copyWith(
      streamingContent: _currentResponse.toString(),
    ));
  }

  void _onMessageCompleted(
    MessageCompleted event,
    Emitter<ChatState> emit,
  ) {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final responseText = _currentResponse.toString().trim();
    _currentResponse.clear();

    if (responseText.isNotEmpty) {
      final assistantMessage = ChatMessage.assistant(responseText);
      final updatedMessages = [...currentState.messages, assistantMessage];

      emit(ChatLoaded(
        messages: updatedMessages,
        isStreaming: false,
      ));

      // Auto-speak the response
      _speakText(responseText);
    } else {
      emit(currentState.copyWith(isStreaming: false));
    }
  }

  void _onMessageError(
    MessageError event,
    Emitter<ChatState> emit,
  ) {
    final currentState = state;
    _currentResponse.clear();

    List<ChatMessage> messages = [];
    if (currentState is ChatLoaded) {
      messages = currentState.messages;
    }

    // Add error message to chat
    final errorMessage = ChatMessage.error(
      'Sorry, I had trouble understanding. Please try again.',
    );

    emit(ChatLoaded(
      messages: [...messages, errorMessage],
      isStreaming: false,
    ));

    debugPrint('ChatBloc: Error - ${event.error}');
  }

  void _onClearChat(ClearChat event, Emitter<ChatState> emit) {
    _streamSubscription?.cancel();
    _currentResponse.clear();
    add(const ChatStarted());
  }

  Future<void> _onSpeakLastMessage(
    SpeakLastMessage event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final assistantMessages = currentState.messages
        .where((m) => m.role == 'assistant' && !m.isError)
        .toList();

    if (assistantMessages.isNotEmpty) {
      await _speakText(assistantMessages.last.content);
    }
  }

  Future<void> _speakText(String text) async {
    try {
      // Use existing AudioManager for TTS
      await _audioManager.speakDialogue(text, character: 'orson');
    } catch (e) {
      debugPrint('ChatBloc: TTS error - $e');
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
