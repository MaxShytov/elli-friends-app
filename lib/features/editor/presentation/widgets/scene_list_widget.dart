import 'package:flutter/material.dart';

import '../bloc/editor_state.dart';

/// Widget displaying a reorderable list of scenes
class SceneListWidget extends StatelessWidget {
  final List<EditableScene> scenes;
  final void Function(int index) onSceneTap;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index) onDelete;
  final void Function(int index) onDuplicate;

  const SceneListWidget({
    super.key,
    required this.scenes,
    required this.onSceneTap,
    required this.onReorder,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: scenes.length,
      onReorder: (oldIndex, newIndex) {
        // Adjust for ReorderableListView's quirk
        if (newIndex > oldIndex) newIndex--;
        onReorder(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final scene = scenes[index];
        return _SceneCard(
          key: ValueKey('scene_$index'),
          index: index,
          scene: scene,
          onTap: () => onSceneTap(index),
          onDelete: () => onDelete(index),
          onDuplicate: () => onDuplicate(index),
        );
      },
    );
  }
}

class _SceneCard extends StatelessWidget {
  final int index;
  final EditableScene scene;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const _SceneCard({
    super.key,
    required this.index,
    required this.scene,
    required this.onTap,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final dialogue = scene.getDialogue('en');
    final hasDialogue = dialogue.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      elevation: scene.isModified ? 3 : 1,
      color: scene.isModified ? Colors.orange.shade50 : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Drag handle
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.drag_handle, color: Colors.grey),
                ),
              ),
              // Scene number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getSceneColor(),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Scene content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Character info
                    Row(
                      children: [
                        _CharacterBadge(
                          character: scene.character,
                          emotion: scene.emotion,
                        ),
                        if (scene.secondCharacter != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.add, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          _CharacterBadge(
                            character: scene.secondCharacter,
                            emotion: scene.secondEmotion,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Dialogue preview
                    Text(
                      hasDialogue
                          ? (dialogue.length > 60
                              ? '${dialogue.substring(0, 60)}...'
                              : dialogue)
                          : '(No dialogue)',
                      style: TextStyle(
                        fontSize: 13,
                        color: hasDialogue ? Colors.black87 : Colors.grey,
                        fontStyle: hasDialogue ? FontStyle.normal : FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Tags
                    Wrap(
                      spacing: 4,
                      children: [
                        if (scene.transitionType != null)
                          _TagChip(
                            label: scene.transitionType!,
                            color: Colors.blue,
                          ),
                        if (scene.isQuestion)
                          const _TagChip(
                            label: 'Question',
                            color: Colors.orange,
                          ),
                        if (scene.isPause)
                          const _TagChip(
                            label: 'Pause',
                            color: Colors.grey,
                          ),
                        if (scene.animals != null && scene.animals!.isNotEmpty)
                          _TagChip(
                            label: '${scene.animals!.length} animals',
                            color: Colors.green,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onTap();
                      break;
                    case 'duplicate':
                      onDuplicate();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 20),
                        SizedBox(width: 8),
                        Text('Duplicate'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSceneColor() {
    if (scene.isQuestion) return Colors.orange;
    if (scene.isPause) return Colors.grey;
    return Colors.purple;
  }
}

class _CharacterBadge extends StatelessWidget {
  final String? character;
  final String? emotion;

  const _CharacterBadge({
    this.character,
    this.emotion,
  });

  @override
  Widget build(BuildContext context) {
    if (character == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getCharacterColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getCharacterColor().withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getCharacterEmoji(),
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            character!,
            style: TextStyle(
              fontSize: 12,
              color: _getCharacterColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (emotion != null) ...[
            const SizedBox(width: 4),
            Text(
              '(${emotion!})',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getCharacterColor() {
    switch (character?.toLowerCase()) {
      case 'orson':
        return Colors.orange;
      case 'merv':
        return Colors.purple;
      case 'elli':
        return Colors.pink;
      case 'bono':
        return Colors.blue;
      case 'hippo':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getCharacterEmoji() {
    switch (character?.toLowerCase()) {
      case 'orson':
        return '🦁';
      case 'merv':
        return '🧙';
      case 'elli':
        return '🐘';
      case 'bono':
        return '🐘';
      case 'hippo':
        return '🦛';
      default:
        return '👤';
    }
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
