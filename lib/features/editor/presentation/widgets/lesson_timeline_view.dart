import 'package:flutter/material.dart';
import '../bloc/editor_state.dart';

/// Горизонтальный Timeline View для визуализации последовательности сценок
class LessonTimelineView extends StatelessWidget {
  final List<EditableScene> scenes;
  final int? selectedSceneIndex;
  final Function(int) onSceneSelected;
  final Function(int, int) onSceneReordered;
  final Function(int) onAddSceneAt; // Изменено: теперь принимает позицию
  final bool hasUnsavedChanges;

  const LessonTimelineView({
    super.key,
    required this.scenes,
    this.selectedSceneIndex,
    required this.onSceneSelected,
    required this.onSceneReordered,
    required this.onAddSceneAt,
    this.hasUnsavedChanges = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Timeline: ${scenes.length} scenes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildTimeline(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    if (scenes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No scenes yet. Click + to add.'),
            const SizedBox(height: 8),
            _AddSceneButton(
              onPressed: () => onAddSceneAt(0),
              tooltipMessage: 'Add first scene',
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: scenes.length * 2 + 1, // карточки + кнопки между ними + кнопка в начале
      itemBuilder: (context, index) {
        // Первая позиция - кнопка "+" перед первой карточкой
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(right: 1),
            child: _AddSceneButton(
              onPressed: () => onAddSceneAt(0),
              tooltipMessage: 'Add scene at the beginning',
            ),
          );
        }

        // Нечетные индексы - карточки сценок
        if (index.isOdd) {
          final sceneIndex = (index - 1) ~/ 2;
          final scene = scenes[sceneIndex];
          final isSelected = sceneIndex == selectedSceneIndex;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: _SceneTimelineCard(
              scene: scene,
              index: sceneIndex,
              isSelected: isSelected,
              onTap: () => onSceneSelected(sceneIndex),
            ),
          );
        }

        // Четные индексы (кроме 0) - кнопки "+" между карточками и после последней
        final sceneIndex = index ~/ 2;
        final isLast = sceneIndex == scenes.length;
        return Padding(
          padding: EdgeInsets.only(
            left: 1,
            right: isLast ? 0 : 1,
          ),
          child: _AddSceneButton(
            onPressed: () => onAddSceneAt(sceneIndex),
            tooltipMessage: 'Add scene at position ${sceneIndex + 1}',
          ),
        );
      },
    );
  }
}

/// Кнопка добавления сценки в MD3 стиле
class _AddSceneButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltipMessage;

  const _AddSceneButton({
    required this.onPressed,
    required this.tooltipMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Tooltip(
        message: tooltipMessage,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFCAC4D0), // MD3 outline color (серый)
                  width: 1.5,
                ),
                color: Colors.white,
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF79747E), // MD3 on-surface-variant (серый)
                size: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Карточка сценки в Timeline
class _SceneTimelineCard extends StatelessWidget {
  final EditableScene scene;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _SceneTimelineCard({
    required this.scene,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        constraints: const BoxConstraints(
          minHeight: 30,
          maxHeight: 50,
        ),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE7E0EC) : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.purple : const Color(0xFFCAC4D0),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row: номер слева, таймер справа
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9370DB),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.timer, size: 8, color: Color(0xFF79747E)),
                const SizedBox(width: 1),
                Text(
                  '${scene.duration ?? 0}s',
                  style: const TextStyle(
                    fontSize: 8,
                    color: Color(0xFF79747E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // Dialogue text
            if (scene.dialogues['en']?.isNotEmpty == true)
              Text(
                scene.dialogues['en']!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 7,
                  color: Color(0xFF49454F),
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
