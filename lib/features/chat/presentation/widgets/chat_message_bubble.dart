import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../domain/entities/chat_message.dart';

/// Widget for displaying a chat message bubble
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  bool get isUser => message.role == 'user';
  bool get isError => message.isError;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.paddingMedium,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // Avatar for assistant
            _buildAvatar(context),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: responsive.isTablet
                    ? 500
                    : MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.all(responsive.isTablet ? 16.0 : 12.0),
              decoration: BoxDecoration(
                color: _getBubbleColor(),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role label
                  Text(
                    isUser ? 'You' : 'Assistant',
                    style: TextStyle(
                      fontSize: responsive.isTablet ? 14.0 : 12.0,
                      fontWeight: FontWeight.bold,
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.primary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Message content
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: responsive.dialogueFontSize,
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            // Avatar for user
            _buildAvatar(context),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final size = responsive.isTablet ? 40.0 : 32.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : AppColors.secondary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          isUser ? '👤' : '🦁',
          style: TextStyle(fontSize: responsive.isTablet ? 20.0 : 16.0),
        ),
      ),
    );
  }

  Color _getBubbleColor() {
    if (isError) {
      return AppColors.incorrect.withValues(alpha: 0.8);
    }
    return isUser ? AppColors.primary : Colors.white;
  }
}

/// Widget for showing "typing" indicator
class TypingIndicator extends StatefulWidget {
  final String? partialContent;

  const TypingIndicator({
    super.key,
    this.partialContent,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.paddingMedium,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar
          Container(
            width: responsive.isTablet ? 40.0 : 32.0,
            height: responsive.isTablet ? 40.0 : 32.0,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '🦁',
                style: TextStyle(fontSize: responsive.isTablet ? 20.0 : 16.0),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: responsive.isTablet
                    ? 500
                    : MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.all(responsive.isTablet ? 16.0 : 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: widget.partialContent != null &&
                      widget.partialContent!.isNotEmpty
                  ? Text(
                      widget.partialContent!,
                      style: TextStyle(
                        fontSize: responsive.dialogueFontSize,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final delay = index * 0.2;
                            final value = (_controller.value + delay) % 1.0;
                            final opacity = 0.3 + 0.7 * (1 - (value * 2 - 1).abs());
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              child: Opacity(
                                opacity: opacity,
                                child: Container(
                                  width: responsive.isTablet ? 12.0 : 8.0,
                                  height: responsive.isTablet ? 12.0 : 8.0,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
