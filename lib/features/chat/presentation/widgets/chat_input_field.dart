import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_helper.dart';

/// Widget for chat input field with send button
class ChatInputField extends StatefulWidget {
  final Function(String) onSend;
  final bool enabled;

  const ChatInputField({
    super.key,
    required this.onSend,
    this.enabled = true,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;

    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Container(
      padding: EdgeInsets.all(responsive.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Text field
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: responsive.isTablet ? 600 : double.infinity,
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  minLines: 1,
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: responsive.dialogueFontSize,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: responsive.dialogueFontSize,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: responsive.paddingMedium,
                      vertical: responsive.isTablet ? 16.0 : 12.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLarge,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLarge,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: responsive.isTablet ? 16.0 : 12.0),

            // Send button
            Material(
              color: widget.enabled ? AppColors.primary : Colors.grey[300],
              borderRadius: BorderRadius.circular(
                responsive.isTablet ? 28.0 : 24.0,
              ),
              child: InkWell(
                onTap: widget.enabled ? _send : null,
                borderRadius: BorderRadius.circular(
                  responsive.isTablet ? 28.0 : 24.0,
                ),
                child: Container(
                  width: responsive.isTablet ? 56.0 : 48.0,
                  height: responsive.isTablet ? 56.0 : 48.0,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: responsive.isTablet ? 28.0 : 24.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
