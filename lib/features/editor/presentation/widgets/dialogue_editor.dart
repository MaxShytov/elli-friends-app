import 'package:flutter/material.dart';

/// Widget for editing dialogue text with multi-language support
class DialogueEditor extends StatefulWidget {
  final int sceneIndex;
  final Map<String, String> dialogues;
  final void Function(String languageCode, String text) onDialogueChanged;
  final void Function(String sourceLanguage) onTranslate;
  final void Function(int position) onSplit;

  const DialogueEditor({
    super.key,
    required this.sceneIndex,
    required this.dialogues,
    required this.onDialogueChanged,
    required this.onTranslate,
    required this.onSplit,
  });

  @override
  State<DialogueEditor> createState() => _DialogueEditorState();
}

class _DialogueEditorState extends State<DialogueEditor> {
  String _selectedLanguage = 'en';
  late TextEditingController _textController;

  static const languages = [
    ('en', 'English', '🇬🇧'),
    ('ru', 'Russian', '🇷🇺'),
    ('fr', 'French', '🇫🇷'),
    ('de', 'German', '🇩🇪'),
    ('it', 'Italian', '🇮🇹'),
    ('my', 'Burmese', '🇲🇲'),
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.dialogues[_selectedLanguage] ?? '',
    );
  }

  @override
  void didUpdateWidget(DialogueEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dialogues != oldWidget.dialogues) {
      _textController.text = widget.dialogues[_selectedLanguage] ?? '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onLanguageChanged(String language) {
    setState(() {
      _selectedLanguage = language;
      _textController.text = widget.dialogues[language] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: languages.map((lang) {
                final isSelected = _selectedLanguage == lang.$1;
                final hasContent = (widget.dialogues[lang.$1] ?? '').isNotEmpty;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => _onLanguageChanged(lang.$1),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.purple
                            : hasContent
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.purple
                              : hasContent
                                  ? Colors.green
                                  : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(lang.$3),
                          const SizedBox(width: 4),
                          Text(
                            lang.$1.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (hasContent && !isSelected) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.green,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Text editor
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Enter dialogue for ${_getLanguageName(_selectedLanguage)}...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.05),
              ),
              onChanged: (value) {
                widget.onDialogueChanged(_selectedLanguage, value);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              // Translate button
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.translate),
                  label: const Text('Auto-translate'),
                  onPressed: () {
                    _showTranslateDialog(context);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Split button
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.content_cut),
                  label: const Text('Split here'),
                  onPressed: _textController.text.isNotEmpty
                      ? () => _showSplitDialog(context)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Character count
          Text(
            '${_textController.text.length} characters',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    return languages.firstWhere((l) => l.$1 == code, orElse: () => (code, code, '')).$2;
  }

  void _showTranslateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Auto-translate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will translate the dialogue from the selected language to all other languages using Claude API.',
            ),
            const SizedBox(height: 16),
            Text(
              'Source language: ${_getLanguageName(_selectedLanguage)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: Existing translations will be overwritten.',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.translate),
            label: const Text('Translate'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.onTranslate(_selectedLanguage);
            },
          ),
        ],
      ),
    );
  }

  void _showSplitDialog(BuildContext context) {
    final text = _textController.text;
    final cursorPos = _textController.selection.baseOffset;

    // Find a good split position (at cursor or at nearest space/period)
    int splitPos = cursorPos > 0 && cursorPos < text.length
        ? cursorPos
        : text.length ~/ 2;

    // Try to find a natural break point
    if (splitPos > 0 && splitPos < text.length) {
      // Look for period, question mark, or exclamation near cursor
      final nearbyBreak = text.indexOf(RegExp(r'[.!?]\s'), splitPos - 20);
      if (nearbyBreak > 0 && nearbyBreak < splitPos + 20) {
        splitPos = nearbyBreak + 2;
      }
    }

    final firstPart = text.substring(0, splitPos).trim();
    final secondPart = text.substring(splitPos).trim();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Split Scene'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will split the scene into two parts:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Part 1:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    firstPart.length > 100
                        ? '${firstPart.substring(0, 100)}...'
                        : firstPart,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Part 2:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    secondPart.length > 100
                        ? '${secondPart.substring(0, 100)}...'
                        : secondPart,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.content_cut),
            label: const Text('Split'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.onSplit(splitPos);
            },
          ),
        ],
      ),
    );
  }
}
