import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_field.dart';

/// Main chat page
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc()..add(const ChatStarted()),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const Text('🦁 ', style: TextStyle(fontSize: 24)),
            Text(
              'Chat',
              style: TextStyle(
                fontSize: responsive.titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Clear chat button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear chat',
            onPressed: () {
              _showClearConfirmation(context);
            },
          ),
          // Speak last message button
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatLoaded && !state.isStreaming) {
                final hasAssistantMessage = state.messages
                    .any((m) => m.role == 'assistant' && !m.isError);
                if (hasAssistantMessage) {
                  return IconButton(
                    icon: const Icon(Icons.volume_up),
                    tooltip: 'Speak last message',
                    onPressed: () {
                      context.read<ChatBloc>().add(const SpeakLastMessage());
                    },
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is ChatInitial) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state is ChatLoaded) {
                  final visibleMessages = state.visibleMessages;

                  if (visibleMessages.isEmpty && !state.isStreaming) {
                    return _buildEmptyState(context, responsive);
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      vertical: responsive.paddingMedium,
                    ),
                    itemCount: visibleMessages.length +
                        (state.isStreaming ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < visibleMessages.length) {
                        return ChatMessageBubble(
                          message: visibleMessages[index],
                        );
                      }
                      // Typing indicator
                      return TypingIndicator(
                        partialContent: state.streamingContent,
                      );
                    },
                  );
                }

                if (state is ChatError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.incorrect,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: responsive.dialogueFontSize,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Input field
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final isStreaming =
                  state is ChatLoaded && state.isStreaming;
              return ChatInputField(
                onSend: (text) {
                  context.read<ChatBloc>().add(SendMessage(text));
                },
                enabled: !isStreaming,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ResponsiveHelper responsive) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🦁',
              style: TextStyle(
                fontSize: responsive.isTablet ? 80.0 : 64.0,
              ),
            ),
            SizedBox(height: responsive.paddingMedium),
            Text(
              'Hi! I\'m your friendly assistant.',
              style: TextStyle(
                fontSize: responsive.titleFontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.paddingMedium),
            Text(
              'Ask me anything and I\'ll try to help!',
              style: TextStyle(
                fontSize: responsive.dialogueFontSize,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Chat?'),
        content: const Text(
          'This will delete all messages. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ChatBloc>().add(const ClearChat());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.incorrect,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
