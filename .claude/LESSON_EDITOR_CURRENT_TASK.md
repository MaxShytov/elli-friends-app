# Lesson Editor Enhancement - Implementation Plan

**Дата создания:** 2025-11-24
**Цель:** Реализация улучшенного редактора уроков с Timeline View, Live Preview и расширенной функциональностью

---

## Plan

### ✅ PHASE 1: Database Setup (ЗАВЕРШЕНО)

**Цель:** Создать базу данных для хранения уроков и сцен

**Реализовано:**
- ✅ Drift (SQLite) база данных
- ✅ Таблицы: Lessons, Scenes, Animals
- ✅ SeedService для инициализации тестовых данных
- ✅ Repository паттерн для доступа к БД

**Время:** ~2 дня

---

### ✅ PHASE 2: BLoC Architecture (ЗАВЕРШЕНО)

**Цель:** Реализовать state management через BLoC pattern

**Реализовано:**
- ✅ EditorBloc с событиями и состояниями
- ✅ EditorEvent: LoadLesson, AddScene, UpdateScene, DeleteScene, ReorderScenes
- ✅ EditorState: EditorInitial, EditorLessonLoaded, EditorError
- ✅ EditableScene модель для UI

**Время:** ~2 дня

---

### ✅ PHASE 3: Basic Editor UI (ЗАВЕРШЕНО)

**Цель:** Создать базовый редактор уроков с модальными окнами

**Реализовано:**
- ✅ LessonEditorPage — главная страница редактора
- ✅ SceneListWidget — список сцен с drag-and-drop
- ✅ SceneEditorDialog — модальное окно редактирования сцены с 4 вкладками:
  1. **Dialogue Tab** — редактор текста диалога с автопереводом (Claude API)
  2. **Character Tab** — выбор персонажа, анимации, эмоции
  3. **Settings Tab** — настройки перехода (auto_tts, auto_timer, button, task)
  4. **Animals Tab** — добавление животных и предметов в сцену
- ✅ Интеграция с Claude API для автоматического перевода на 7 языков

**Ограничения Phase 3:**
- ⚠️ Поддерживает только ОДИН диалог на сцену (нужно 1-3)
- ❌ Нет Timeline View
- ❌ Нет Live Preview
- ❌ Нет анимационных эффектов
- ❌ Использует модальные окна вместо Side-by-Side layout

**Время:** ~5 дней

---

### PHASE 4A: Timeline View (КРИТИЧЕСКИЙ ПРИОРИТЕТ)

#### Task 4A.1: Добавить зависимости для Timeline
**Файл:** `pubspec.yaml`

**Изменения:**
```yaml
dependencies:
  # Добавить в секцию dependencies:
  timelines_plus: ^0.1.0
  flutter_animate: ^4.3.0
```

**Порядок выполнения:**
1. Открыть `pubspec.yaml`
2. Добавить `timelines_plus: ^0.1.0` в секцию dependencies (после rive)
3. Добавить `flutter_animate: ^4.3.0` для анимационных эффектов
4. Запустить `flutter pub get`

**Проверка:**
```bash
flutter pub get
# Должно успешно загрузить зависимости без ошибок
grep "timelines_plus" pubspec.yaml
grep "flutter_animate" pubspec.yaml
```

**Тесты:**
- Нет необходимости в unit тестах для этого шага
- Проверка компиляции: `flutter analyze` не должна выдавать ошибок

---

#### Task 4A.2: Создать enum для анимационных эффектов
**Файл:** `lib/features/lessons/domain/entities/animation_effect.dart` (новый)

**Изменения:**
```dart
/// Перечисление всех анимационных эффектов для объектов и персонажей
enum AnimationEffect {
  // === БАЗОВЫЕ ЭФФЕКТЫ ПОЯВЛЕНИЯ ===
  appear,           // Мгновенное появление
  fade,             // Плавное проявление
  flyInLeft,        // Влетает слева
  flyInRight,       // Влетает справа
  flyInTop,         // Влетает сверху
  flyInBottom,      // Влетает снизу
  floatIn,          // Всплывает снизу
  split,            // Разделяется/раскрывается
  wipe,             // Стирание/проявление
  zoom,             // Увеличение от точки

  // === ЭФФЕКТНЫЕ АНИМАЦИИ ПОЯВЛЕНИЯ ===
  bounce,           // Прыгает с отскоком
  swivel,           // Поворот вокруг оси
  pinwheel,         // Вертушка
  growAndTurn,      // Увеличивается и поворачивается
  wheel,            // Появление секторами
  randomBars,       // Случайные полосы

  // === ЭФФЕКТЫ ИСЧЕЗНОВЕНИЯ ===
  disappear,        // Мгновенное исчезновение
  fadeOut,          // Плавное растворение
  flyOutLeft,       // Улетает влево
  flyOutRight,      // Улетает вправо
  flyOutTop,        // Улетает вверх
  flyOutBottom,     // Улетает вниз
  floatOut,         // Улетает вверх как шарик
  scaleOut,         // Уменьшение до точки
  dropOut,          // Падение вниз
  poof,             // Исчезновение с облачком
  spinOut,          // Исчезает с вращением

  // === АКТИВНЫЕ/IDLE АНИМАЦИИ ===
  idleBobbing,      // Легкое покачивание
  float,            // Плавание вверх-вниз
  wiggle,           // Покачивание из стороны в сторону
  pulse,            // Пульсация размера
  spin,             // Медленное вращение
  jump,             // Периодические подпрыгивания
  sway,             // Раскачивание

  // === СПЕЦИФИЧНЫЕ АНИМАЦИИ ОБЪЕКТОВ ===
  flutter,          // Бабочки - порхание крыльями
  swingDown,        // Обезьянки - спускание с деревьев
  walkSlow,         // Черепахи - медленная ходьба
  hop,              // Лягушки - прыжки
  rollIn,           // Бананы - вкатывание
  fallFromTree,     // Яблоки - падение с дерева
  waveInBreeze,     // Листья - качание на ветру
}

/// Расширение для получения рекомендованных анимаций для объектов
extension AnimationEffectRecommendations on String {
  /// Получить рекомендованную entrance анимацию для типа объекта
  AnimationEffect? getRecommendedEntranceEffect() {
    switch (this) {
      case 'butterfly': return AnimationEffect.floatIn;
      case 'monkey': return AnimationEffect.swingDown;
      case 'turtle': return AnimationEffect.walkSlow;
      case 'frog': return AnimationEffect.hop;
      case 'banana': return AnimationEffect.rollIn;
      case 'apple': return AnimationEffect.fallFromTree;
      case 'leaf': return AnimationEffect.waveInBreeze;
      default: return null;
    }
  }

  /// Получить рекомендованную active анимацию для типа объекта
  AnimationEffect? getRecommendedActiveEffect() {
    switch (this) {
      case 'butterfly': return AnimationEffect.flutter;
      case 'monkey': return null; // Используется swingDown как entrance
      case 'turtle': return AnimationEffect.walkSlow;
      case 'frog': return AnimationEffect.hop;
      case 'leaf': return AnimationEffect.waveInBreeze;
      default: return AnimationEffect.idleBobbing;
    }
  }

  /// Получить рекомендованную exit анимацию для типа объекта
  AnimationEffect? getRecommendedExitEffect() {
    switch (this) {
      case 'butterfly': return AnimationEffect.flyOutTop;
      case 'monkey': return AnimationEffect.fadeOut;
      case 'turtle': return AnimationEffect.walkSlow;
      case 'frog': return AnimationEffect.hop;
      case 'banana': return AnimationEffect.fadeOut;
      case 'apple': return AnimationEffect.fadeOut;
      case 'leaf': return AnimationEffect.fadeOut;
      default: return AnimationEffect.fadeOut;
    }
  }
}
```

**Порядок выполнения:**
1. Создать директорию `lib/features/lessons/domain/entities/` (если не существует)
2. Создать файл `animation_effect.dart`
3. Добавить код enum и расширения

**Проверка:**
```bash
flutter analyze
# Не должно быть ошибок
```

**Тесты:**
`test/unit/features/lessons/domain/entities/animation_effect_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:elli_friends_app/features/lessons/domain/entities/animation_effect.dart';

void main() {
  group('AnimationEffectRecommendations', () {
    test('butterfly должна иметь рекомендованные анимации', () {
      expect('butterfly'.getRecommendedEntranceEffect(), AnimationEffect.floatIn);
      expect('butterfly'.getRecommendedActiveEffect(), AnimationEffect.flutter);
      expect('butterfly'.getRecommendedExitEffect(), AnimationEffect.flyOutTop);
    });

    test('monkey должна иметь рекомендованные анимации', () {
      expect('monkey'.getRecommendedEntranceEffect(), AnimationEffect.swingDown);
      expect('monkey'.getRecommendedActiveEffect(), null);
      expect('monkey'.getRecommendedExitEffect(), AnimationEffect.fadeOut);
    });

    test('неизвестный тип должен возвращать null или defaults', () {
      expect('unknown'.getRecommendedEntranceEffect(), null);
      expect('unknown'.getRecommendedActiveEffect(), AnimationEffect.idleBobbing);
      expect('unknown'.getRecommendedExitEffect(), AnimationEffect.fadeOut);
    });
  });
}
```

---

#### Task 4A.3: Обновить модель Animal с анимационными эффектами
**Файл:** `lib/features/lessons/data/models/animal_model.dart`

**Изменения:**
1. Добавить импорт `import '../../domain/entities/animation_effect.dart';`
2. Добавить поля:
```dart
class AnimalModel extends Equatable {
  // ... существующие поля ...
  final AnimationEffect? entranceEffect;
  final AnimationEffect? activeEffect;
  final AnimationEffect? exitEffect;
  final double? positionX;  // Позиция X (0.0-1.0, относительно ширины экрана)
  final double? positionY;  // Позиция Y (0.0-1.0, относительно высоты экрана)

  const AnimalModel({
    // ... существующие параметры ...
    this.entranceEffect,
    this.activeEffect,
    this.exitEffect,
    this.positionX,
    this.positionY,
  });

  // Обновить copyWith метод
  // Обновить toJson/fromJson методы
  // Обновить props в Equatable
}
```

**Порядок выполнения:**
1. Открыть `lib/features/lessons/data/models/animal_model.dart`
2. Добавить импорт `animation_effect.dart`
3. Добавить новые поля в класс
4. Обновить конструктор
5. Обновить метод `copyWith` (добавить новые параметры)
6. Обновить `toJson` (сериализовать enum как строки через `.name`)
7. Обновить `fromJson` (десериализовать строки в enum)
8. Добавить новые поля в `props`

**Проверка:**
```bash
flutter analyze
# Проверить, что сериализация работает
```

**Тесты:**
`test/unit/features/lessons/data/models/animal_model_test.dart`
```dart
test('AnimalModel должен сериализовать и десериализовать анимационные эффекты', () {
  final animal = AnimalModel(
    type: 'butterfly',
    emoji: '🦋',
    count: 3,
    entranceEffect: AnimationEffect.floatIn,
    activeEffect: AnimationEffect.flutter,
    exitEffect: AnimationEffect.flyOutTop,
    positionX: 0.5,
    positionY: 0.3,
  );

  final json = animal.toJson();
  expect(json['entranceEffect'], 'floatIn');
  expect(json['activeEffect'], 'flutter');
  expect(json['exitEffect'], 'flyOutTop');
  expect(json['positionX'], 0.5);
  expect(json['positionY'], 0.3);

  final fromJson = AnimalModel.fromJson(json);
  expect(fromJson, equals(animal));
});

test('AnimalModel должен работать без анимационных эффектов (обратная совместимость)', () {
  final json = {
    'type': 'butterfly',
    'emoji': '🦋',
    'count': 3,
  };

  final animal = AnimalModel.fromJson(json);
  expect(animal.entranceEffect, null);
  expect(animal.activeEffect, null);
  expect(animal.exitEffect, null);
});
```

---

#### Task 4A.4: Обновить SceneModel для поддержки персонажных эффектов и background
**Файл:** `lib/features/lessons/data/models/scene_model.dart`

**Изменения:**
```dart
class SceneModel extends Scene {
  // Добавить новые поля:
  final AnimationEffect? characterEntranceEffect;
  final AnimationEffect? characterExitEffect;
  final AnimationEffect? secondCharacterEntranceEffect;
  final AnimationEffect? secondCharacterExitEffect;
  final String? background;  // "jungle_morning", "jungle_evening"
  final String? ambientSound; // "jungle_ambience"
  final double? ambientVolume; // 0.0 - 1.0

  // Обновить конструктор, toJson, fromJson, copyWith
}
```

**Порядок выполнения:**
1. Открыть `lib/features/lessons/data/models/scene_model.dart`
2. Добавить импорт `animation_effect.dart`
3. Добавить новые поля
4. Обновить все методы (конструктор, toJson, fromJson, copyWith, props)

**Проверка:**
```bash
flutter analyze
```

**Тесты:**
`test/unit/features/lessons/data/models/scene_model_test.dart` - добавить тесты для новых полей

---

#### Task 4A.5: Обновить EditorState для поддержки новых полей
**Файл:** `lib/features/editor/presentation/bloc/editor_state.dart`

**Изменения:**
```dart
class EditableScene extends Equatable {
  // Добавить новые поля:
  final AnimationEffect? characterEntranceEffect;
  final AnimationEffect? characterExitEffect;
  final AnimationEffect? secondCharacterEntranceEffect;
  final AnimationEffect? secondCharacterExitEffect;
  final String? background;
  final String? ambientSound;
  final double? ambientVolume;

  // Обновить конструктор и copyWith
}
```

**Порядок выполнения:**
1. Открыть `lib/features/editor/presentation/bloc/editor_state.dart`
2. Добавить импорт `animation_effect.dart`
3. Найти класс `EditableScene`
4. Добавить новые поля
5. Обновить конструктор
6. Обновить метод `copyWith`
7. Добавить в `props`

**Проверка:**
```bash
flutter analyze
```

**Тесты:**
Не требуется (состояние - простая модель данных)

---

#### Task 4A.6: Создать виджет TimelineView для отображения последовательности сценок
**Файл:** `lib/features/editor/presentation/widgets/lesson_timeline_view.dart` (новый)

**Изменения:**
Создать новый виджет с использованием `timelines_plus`:

```dart
import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';
import '../../bloc/editor_state.dart';

/// Горизонтальный Timeline View для визуализации последовательности сценок
class LessonTimelineView extends StatelessWidget {
  final List<EditableScene> scenes;
  final int? selectedSceneIndex;
  final Function(int) onSceneSelected;
  final Function(int, int) onSceneReordered;
  final VoidCallback onAddScene;

  const LessonTimelineView({
    super.key,
    required this.scenes,
    this.selectedSceneIndex,
    required this.onSceneSelected,
    required this.onSceneReordered,
    required this.onAddScene,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Timeline',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: onAddScene,
                tooltip: 'Add Scene',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildTimeline(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    if (scenes.isEmpty) {
      return Center(
        child: Text('No scenes yet. Click + to add.'),
      );
    }

    return Timeline.builder(
      itemCount: scenes.length,
      direction: Axis.horizontal,
      itemBuilder: (context, index) {
        final scene = scenes[index];
        final isSelected = index == selectedSceneIndex;

        return TimelineTile(
          nodeAlign: TimelineNodeAlign.start,
          contents: _SceneTimelineCard(
            scene: scene,
            index: index,
            isSelected: isSelected,
            onTap: () => onSceneSelected(index),
          ),
          node: TimelineNode(
            indicator: DotIndicator(
              color: _getSceneColor(scene),
              size: 24,
              child: Icon(
                _getSceneIcon(scene),
                color: Colors.white,
                size: 14,
              ),
            ),
            startConnector: index > 0 ? SolidLineConnector(
              color: Colors.grey[300],
              thickness: 2,
            ) : null,
            endConnector: index < scenes.length - 1 ? SolidLineConnector(
              color: Colors.grey[300],
              thickness: 2,
            ) : null,
          ),
        );
      },
    );
  }

  Color _getSceneColor(EditableScene scene) {
    if (scene.isQuestion) return Colors.orange;
    if (scene.isPause) return Colors.grey;
    return Colors.purple;
  }

  IconData _getSceneIcon(EditableScene scene) {
    if (scene.isQuestion) return Icons.help;
    if (scene.isPause) return Icons.pause;
    if (scene.character != null) return Icons.person;
    return Icons.panorama;
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
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple[50] : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scene ${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? Colors.purple : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            if (scene.character != null)
              Text(
                scene.character!,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            if (scene.dialogues != null && scene.dialogues!['en']?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  scene.dialogues!['en']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.timer, size: 12, color: Colors.grey),
                const SizedBox(width: 2),
                Text(
                  '${scene.duration ?? 0}s',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const Spacer(),
                Icon(
                  _getTransitionIcon(scene.transitionType),
                  size: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransitionIcon(String? transitionType) {
    switch (transitionType) {
      case 'auto_timer': return Icons.timer;
      case 'auto_tts': return Icons.record_voice_over;
      case 'button': return Icons.touch_app;
      case 'task': return Icons.quiz;
      default: return Icons.arrow_forward;
    }
  }
}
```

**Порядок выполнения:**
1. Создать файл `lib/features/editor/presentation/widgets/lesson_timeline_view.dart`
2. Скопировать код виджета
3. Проверить импорты

**Проверка:**
```bash
flutter analyze
```

**Тесты:**
`test/widget/features/editor/presentation/widgets/lesson_timeline_view_test.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elli_friends_app/features/editor/presentation/widgets/lesson_timeline_view.dart';
import 'package:elli_friends_app/features/editor/presentation/bloc/editor_state.dart';

void main() {
  group('LessonTimelineView', () {
    testWidgets('должен отображать пустое состояние', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonTimelineView(
              scenes: [],
              onSceneSelected: (_) {},
              onSceneReordered: (_, __) {},
              onAddScene: () {},
            ),
          ),
        ),
      );

      expect(find.text('No scenes yet. Click + to add.'), findsOneWidget);
    });

    testWidgets('должен отображать список сценок', (tester) async {
      final scenes = [
        EditableScene(
          databaseId: 0,
          character: 'orson',
          dialogues: {'en': 'Hello!'},
        ),
        EditableScene(
          databaseId: 1,
          character: 'merv',
          dialogues: {'en': 'Hi there!'},
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonTimelineView(
              scenes: scenes,
              onSceneSelected: (_) {},
              onSceneReordered: (_, __) {},
              onAddScene: () {},
            ),
          ),
        ),
      );

      expect(find.text('Scene 1'), findsOneWidget);
      expect(find.text('Scene 2'), findsOneWidget);
      expect(find.text('orson'), findsOneWidget);
      expect(find.text('merv'), findsOneWidget);
    });

    testWidgets('должен вызывать callback при клике на сценку', (tester) async {
      int? selectedIndex;
      final scenes = [
        EditableScene(
          databaseId: 0,
          character: 'orson',
          dialogues: {'en': 'Hello!'},
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonTimelineView(
              scenes: scenes,
              onSceneSelected: (index) => selectedIndex = index,
              onSceneReordered: (_, __) {},
              onAddScene: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Scene 1'));
      expect(selectedIndex, 0);
    });
  });
}
```

---

#### Task 4A.7: Интегрировать Timeline View в LessonEditorPage
**Файл:** `lib/features/editor/presentation/pages/lesson_editor_page.dart`

**Изменения:**
1. Добавить импорт `import '../widgets/lesson_timeline_view.dart';`
2. В методе `build` добавить Timeline View над списком сценок:

```dart
@override
Widget build(BuildContext context) {
  return BlocBuilder<EditorBloc, EditorState>(
    builder: (context, state) {
      if (state is EditorLessonLoaded) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.lesson.title['en'] ?? 'Lesson Editor'),
            // ... existing app bar code ...
          ),
          body: Column(
            children: [
              // НОВЫЙ: Timeline View
              LessonTimelineView(
                scenes: state.editableScenes,
                selectedSceneIndex: _selectedSceneIndex,
                onSceneSelected: (index) {
                  setState(() {
                    _selectedSceneIndex = index;
                  });
                  // Опционально: открыть редактор сценки
                  _editScene(context, state.editableScenes[index], index);
                },
                onSceneReordered: (oldIndex, newIndex) {
                  context.read<EditorBloc>().add(
                    ReorderScenes(oldIndex: oldIndex, newIndex: newIndex),
                  );
                },
                onAddScene: () {
                  context.read<EditorBloc>().add(AddScene());
                },
              ),
              const Divider(),
              // Существующий SceneListWidget
              Expanded(
                child: SceneListWidget(
                  scenes: state.editableScenes,
                  onEdit: (scene, index) => _editScene(context, scene, index),
                  onDelete: (index) {
                    context.read<EditorBloc>().add(DeleteScene(sceneIndex: index));
                  },
                  onReorder: (oldIndex, newIndex) {
                    context.read<EditorBloc>().add(
                      ReorderScenes(oldIndex: oldIndex, newIndex: newIndex),
                    );
                  },
                  onDuplicate: (index) {
                    context.read<EditorBloc>().add(DuplicateScene(sceneIndex: index));
                  },
                ),
              ),
            ],
          ),
        );
      }
      // ... existing error/loading states ...
    },
  );
}

// Добавить переменную состояния
int? _selectedSceneIndex;
```

**Порядок выполнения:**
1. Открыть `lib/features/editor/presentation/pages/lesson_editor_page.dart`
2. Добавить импорт Timeline View
3. Добавить переменную `_selectedSceneIndex` в State класс
4. Обернуть существующий `SceneListWidget` в `Column`
5. Добавить Timeline View над SceneListWidget
6. Добавить `Divider()` между ними

**Проверка:**
```bash
flutter run -d chrome
# Открыть редактор урока
# Проверить, что Timeline View отображается над списком сценок
```

**Тесты:**
`test/widget/features/editor/presentation/pages/lesson_editor_page_test.dart`
- Обновить существующие тесты, чтобы они учитывали наличие Timeline View

---

### PHASE 4B: Live Preview (КРИТИЧЕСКИЙ ПРИОРИТЕТ)

#### Task 4B.1: Создать виджет ScenePreviewWidget
**Файл:** `lib/features/editor/presentation/widgets/scene_preview_widget.dart` (новый)

**Изменения:**
Создать виджет для предпросмотра сценки:

```dart
import 'package:flutter/material.dart';
import '../../bloc/editor_state.dart';
import '../../../lessons/presentation/widgets/scene_widget.dart';

/// Live Preview виджет для предпросмотра сценки в редакторе
class ScenePreviewWidget extends StatefulWidget {
  final EditableScene scene;
  final bool autoPlay;

  const ScenePreviewWidget({
    super.key,
    required this.scene,
    this.autoPlay = false,
  });

  @override
  State<ScenePreviewWidget> createState() => _ScenePreviewWidgetState();
}

class _ScenePreviewWidgetState extends State<ScenePreviewWidget> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      _play();
    }
  }

  void _play() {
    setState(() {
      _isPlaying = true;
    });
    // TODO: Реализовать воспроизведение TTS
  }

  void _stop() {
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: Stack(
        children: [
          // Background
          if (widget.scene.background != null)
            _buildBackground(widget.scene.background!),

          // Scene content (используем существующий SceneWidget)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Character
                  if (widget.scene.character != null)
                    Text(
                      widget.scene.character!,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  const SizedBox(height: 16),

                  // Dialogue
                  if (widget.scene.dialogues != null &&
                      widget.scene.dialogues!['en']?.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.scene.dialogues!['en']!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Animals
                  if (widget.scene.animals?.isNotEmpty == true)
                    Wrap(
                      spacing: 8,
                      children: widget.scene.animals!.map((animal) {
                        return Text(
                          animal.emoji * animal.count,
                          style: const TextStyle(fontSize: 32),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),

          // Play/Stop controls
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: _isPlaying ? _stop : _play,
              child: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(String background) {
    Color bgColor;
    switch (background) {
      case 'jungle_morning':
        bgColor = Colors.green[100]!;
        break;
      case 'jungle_evening':
        bgColor = Colors.orange[100]!;
        break;
      default:
        bgColor = Colors.grey[100]!;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            bgColor,
            bgColor.withOpacity(0.7),
          ],
        ),
      ),
    );
  }
}
```

**Порядок выполнения:**
1. Создать файл `lib/features/editor/presentation/widgets/scene_preview_widget.dart`
2. Скопировать код
3. Проверить импорты

**Проверка:**
```bash
flutter analyze
```

**Тесты:**
`test/widget/features/editor/presentation/widgets/scene_preview_widget_test.dart`

---

#### Task 4B.2: Добавить Preview в SceneEditorDialog
**Файл:** `lib/features/editor/presentation/widgets/scene_editor_dialog.dart`

**Изменения:**
1. Добавить импорт `import 'scene_preview_widget.dart';`
2. Добавить 5-ю вкладку "Preview":

```dart
final tabs = [
  const Tab(icon: Icon(Icons.text_fields), text: 'Dialogue'),
  const Tab(icon: Icon(Icons.person), text: 'Character'),
  const Tab(icon: Icon(Icons.settings), text: 'Settings'),
  const Tab(icon: Icon(Icons.pets), text: 'Animals'),
  const Tab(icon: Icon(Icons.visibility), text: 'Preview'), // НОВАЯ ВКЛАДКА
];

// В TabBarView:
TabBarView(
  children: [
    DialogueEditor(...),
    CharacterPicker(...),
    SettingsTab(...),
    AnimalsTab(...),
    ScenePreviewWidget(scene: editableScene, autoPlay: false), // НОВАЯ ВКЛАДКА
  ],
),
```

**Порядок выполнения:**
1. Открыть `lib/features/editor/presentation/widgets/scene_editor_dialog.dart`
2. Найти список `tabs`
3. Добавить 5-ю вкладку "Preview"
4. Найти `TabBarView`
5. Добавить `ScenePreviewWidget` как 5-й child

**Проверка:**
```bash
flutter run -d chrome
# Открыть редактор сценки
# Проверить, что есть вкладка "Preview"
# Переключиться на неё и убедиться, что preview отображается
```

**Тесты:**
Обновить существующие widget тесты для `scene_editor_dialog_test.dart`

---

### ✅ PHASE 4C: Animation Effects UI (ЗАВЕРШЕНО)

#### ✅ Task 4C.1: Создать виджет AnimationEffectPicker (ЗАВЕРШЕНО)
**Файл:** `lib/features/editor/presentation/widgets/animation_effect_picker.dart` (новый)

**Изменения:**
```dart
import 'package:flutter/material.dart';
import '../../../lessons/domain/entities/animation_effect.dart';

/// Виджет для выбора анимационного эффекта
class AnimationEffectPicker extends StatelessWidget {
  final String label;
  final AnimationEffect? selectedEffect;
  final AnimationEffect? recommendedEffect;
  final List<AnimationEffect> availableEffects;
  final Function(AnimationEffect?) onChanged;

  const AnimationEffectPicker({
    super.key,
    required this.label,
    this.selectedEffect,
    this.recommendedEffect,
    required this.availableEffects,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (recommendedEffect != null) ...[
              const SizedBox(width: 8),
              Chip(
                label: Text(
                  'Recommended: ${_effectToString(recommendedEffect!)}',
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: Colors.green[100],
                avatar: const Icon(Icons.lightbulb_outline, size: 16),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<AnimationEffect?>(
          value: selectedEffect,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: [
            DropdownMenuItem<AnimationEffect?>(
              value: null,
              child: Text('None'),
            ),
            ...availableEffects.map((effect) {
              return DropdownMenuItem<AnimationEffect?>(
                value: effect,
                child: Row(
                  children: [
                    Text(_effectToString(effect)),
                    if (effect == recommendedEffect) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    ],
                  ],
                ),
              );
            }),
          ],
          onChanged: onChanged,
        ),
        if (recommendedEffect != null && selectedEffect != recommendedEffect)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              icon: const Icon(Icons.auto_fix_high, size: 16),
              label: const Text('Use recommended'),
              onPressed: () => onChanged(recommendedEffect),
            ),
          ),
      ],
    );
  }

  String _effectToString(AnimationEffect effect) {
    return effect.name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
```

**Порядок выполнения:**
1. Создать файл `lib/features/editor/presentation/widgets/animation_effect_picker.dart`
2. Скопировать код
3. Проверить импорты

**Проверка:**
```bash
flutter analyze
```

**Тесты:**
`test/widget/features/editor/presentation/widgets/animation_effect_picker_test.dart`

---

#### ✅ Task 4C.2: Добавить AnimationEffectPicker в Animals Tab (ЗАВЕРШЕНО)
**Файл:** `lib/features/editor/presentation/widgets/scene_editor_dialog.dart` (в секции Animals tab)

**Изменения:**
В разделе редактирования животных добавить:

```dart
// Для каждого Animal в списке:
Column(
  children: [
    // Существующие поля (emoji, count)...

    // НОВОЕ: Entrance Effect
    AnimationEffectPicker(
      label: 'Entrance Effect',
      selectedEffect: animal.entranceEffect,
      recommendedEffect: animal.type.getRecommendedEntranceEffect(),
      availableEffects: [
        AnimationEffect.appear,
        AnimationEffect.fade,
        AnimationEffect.flyInLeft,
        AnimationEffect.flyInRight,
        AnimationEffect.flyInTop,
        AnimationEffect.flyInBottom,
        AnimationEffect.floatIn,
        AnimationEffect.zoom,
        AnimationEffect.bounce,
        // Специфичные эффекты
        if (animal.type == 'monkey') AnimationEffect.swingDown,
        if (animal.type == 'banana') AnimationEffect.rollIn,
        if (animal.type == 'apple') AnimationEffect.fallFromTree,
      ],
      onChanged: (effect) {
        // Обновить animal с новым entranceEffect
      },
    ),

    const SizedBox(height: 8),

    // НОВОЕ: Active Effect
    AnimationEffectPicker(
      label: 'Active Effect (optional)',
      selectedEffect: animal.activeEffect,
      recommendedEffect: animal.type.getRecommendedActiveEffect(),
      availableEffects: [
        AnimationEffect.idleBobbing,
        AnimationEffect.float,
        AnimationEffect.wiggle,
        AnimationEffect.pulse,
        // Специфичные эффекты
        if (animal.type == 'butterfly') AnimationEffect.flutter,
        if (animal.type == 'turtle') AnimationEffect.walkSlow,
        if (animal.type == 'frog') AnimationEffect.hop,
        if (animal.type == 'leaf') AnimationEffect.waveInBreeze,
      ],
      onChanged: (effect) {
        // Обновить animal с новым activeEffect
      },
    ),

    const SizedBox(height: 8),

    // НОВОЕ: Exit Effect
    AnimationEffectPicker(
      label: 'Exit Effect',
      selectedEffect: animal.exitEffect,
      recommendedEffect: animal.type.getRecommendedExitEffect(),
      availableEffects: [
        AnimationEffect.disappear,
        AnimationEffect.fadeOut,
        AnimationEffect.flyOutLeft,
        AnimationEffect.flyOutRight,
        AnimationEffect.flyOutTop,
        AnimationEffect.flyOutBottom,
        AnimationEffect.scaleOut,
        AnimationEffect.dropOut,
      ],
      onChanged: (effect) {
        // Обновить animal с новым exitEffect
      },
    ),
  ],
)
```

**Порядок выполнения:**
1. Открыть `lib/features/editor/presentation/widgets/scene_editor_dialog.dart`
2. Найти секцию Animals tab
3. Добавить три `AnimationEffectPicker` для каждого animal
4. Добавить логику обновления животного при изменении эффекта

**Проверка:**
```bash
flutter run -d chrome
# Открыть редактор сценки
# Перейти на вкладку Animals
# Проверить, что для каждого животного есть 3 пикера эффектов
# Проверить, что рекомендации отображаются корректно
```

**Тесты:**
Обновить widget тесты

---

### PHASE 4D: Background & Sound (СРЕДНИЙ ПРИОРИТЕТ)

#### Task 4D.1: Создать виджет BackgroundPicker
**Файл:** `lib/features/editor/presentation/widgets/background_picker.dart` (новый)

**Изменения:**
```dart
import 'package:flutter/material.dart';

/// Виджет для выбора фона сценки
class BackgroundPicker extends StatelessWidget {
  final String? selectedBackground;
  final Function(String?) onChanged;

  const BackgroundPicker({
    super.key,
    this.selectedBackground,
    required this.onChanged,
  });

  static const backgrounds = {
    'jungle_morning': {'name': 'Jungle Morning', 'color': Colors.lightGreen},
    'jungle_evening': {'name': 'Jungle Evening', 'color': Colors.orange},
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildBackgroundOption(context, null, 'None', Colors.grey[300]!),
            ...backgrounds.entries.map((entry) {
              return _buildBackgroundOption(
                context,
                entry.key,
                entry.value['name'] as String,
                entry.value['color'] as Color,
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildBackgroundOption(
    BuildContext context,
    String? value,
    String label,
    Color color,
  ) {
    final isSelected = selectedBackground == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        width: 100,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey[400]!,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.purple),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Порядок выполнения:**
1. Создать файл
2. Скопировать код
3. Проверить компиляцию

**Проверка:**
```bash
flutter analyze
```

**Тесты:**
Widget test для BackgroundPicker

---

#### Task 4D.2: Добавить BackgroundPicker в Settings Tab
**Файл:** `lib/features/editor/presentation/widgets/scene_editor_dialog.dart` (Settings tab)

**Изменения:**
```dart
// В Settings tab добавить:
BackgroundPicker(
  selectedBackground: editableScene.background,
  onChanged: (background) {
    // Обновить сценку
  },
),

const SizedBox(height: 16),

// Ambient Sound
Text('Ambient Sound', style: Theme.of(context).textTheme.titleSmall),
const SizedBox(height: 8),
DropdownButtonFormField<String?>(
  value: editableScene.ambientSound,
  items: [
    DropdownMenuItem(value: null, child: Text('None')),
    DropdownMenuItem(value: 'jungle_ambience', child: Text('Jungle Ambience')),
  ],
  onChanged: (sound) {
    // Обновить сценку
  },
),

if (editableScene.ambientSound != null) ...[
  const SizedBox(height: 8),
  Text('Volume', style: Theme.of(context).textTheme.titleSmall),
  Slider(
    value: editableScene.ambientVolume ?? 0.3,
    min: 0.0,
    max: 1.0,
    divisions: 10,
    label: '${((editableScene.ambientVolume ?? 0.3) * 100).round()}%',
    onChanged: (volume) {
      // Обновить сценку
    },
  ),
],
```

**Порядок выполнения:**
1. Открыть файл
2. Найти Settings tab
3. Добавить BackgroundPicker
4. Добавить Ambient Sound dropdown
5. Добавить Volume slider

**Проверка:**
```bash
flutter run -d chrome
# Проверить Settings tab в редакторе сценки
```

**Тесты:**
Widget tests

---

### PHASE 4E: Export/Import (СРЕДНИЙ ПРИОРИТЕТ)

#### Task 4E.1: Создать ExportService
**Файл:** `lib/features/editor/domain/services/export_service.dart` (новый)

**Изменения:**
```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../lessons/data/models/lesson_model.dart';

/// Сервис для экспорта уроков в различных форматах
class ExportService {
  /// Экспорт урока в JSON
  Future<String> exportToJson(LessonModel lesson) async {
    final json = lesson.toJson();
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  /// Экспорт урока в YAML (упрощенный формат)
  Future<String> exportToYaml(LessonModel lesson) async {
    // TODO: Реализовать YAML экспорт
    // Можно использовать пакет yaml
    throw UnimplementedError('YAML export not implemented yet');
  }

  /// Импорт урока из JSON
  Future<LessonModel> importFromJson(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return LessonModel.fromJson(json);
    } catch (e) {
      throw Exception('Failed to parse JSON: $e');
    }
  }

  /// Валидация импортируемого JSON
  Future<bool> validateJson(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      // Проверяем обязательные поля
      if (!json.containsKey('id')) return false;
      if (!json.containsKey('title')) return false;
      if (!json.containsKey('scenes')) return false;

      // Проверяем структуру scenes
      final scenes = json['scenes'] as List?;
      if (scenes == null) return false;

      return true;
    } catch (e) {
      return false;
    }
  }
}
```

**Порядок выполнения:**
1. Создать директорию `lib/features/editor/domain/services/`
2. Создать файл `export_service.dart`
3. Скопировать код

**Проверка:**
```bash
flutter analyze
```

**Тесты:**
`test/unit/features/editor/domain/services/export_service_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:elli_friends_app/features/editor/domain/services/export_service.dart';
import 'package:elli_friends_app/features/lessons/data/models/lesson_model.dart';

void main() {
  late ExportService exportService;

  setUp(() {
    exportService = ExportService();
  });

  group('ExportService', () {
    test('exportToJson должен создать валидный JSON', () async {
      final lesson = LessonModel(
        id: 'test_lesson',
        title: {'en': 'Test Lesson'},
        topic: 'counting',
        description: {'en': 'Test'},
        difficulty: 1,
        tags: [],
        scenes: [],
      );

      final json = await exportService.exportToJson(lesson);
      expect(json, contains('test_lesson'));
      expect(json, contains('Test Lesson'));
    });

    test('importFromJson должен распарсить JSON', () async {
      final jsonString = '''
      {
        "id": "test_lesson",
        "title": {"en": "Test Lesson"},
        "topic": "counting",
        "description": {"en": "Test"},
        "difficulty": 1,
        "tags": [],
        "scenes": []
      }
      ''';

      final lesson = await exportService.importFromJson(jsonString);
      expect(lesson.id, 'test_lesson');
      expect(lesson.title['en'], 'Test Lesson');
    });

    test('validateJson должен проверять структуру', () async {
      final validJson = '''
      {
        "id": "test",
        "title": {"en": "Test"},
        "scenes": []
      }
      ''';

      expect(await exportService.validateJson(validJson), true);

      final invalidJson = '{"invalid": "structure"}';
      expect(await exportService.validateJson(invalidJson), false);
    });
  });
}
```

---

#### Task 4E.2: Добавить кнопки Export/Import в LessonEditorPage
**Файл:** `lib/features/editor/presentation/pages/lesson_editor_page.dart`

**Изменения:**
```dart
// В AppBar добавить actions:
actions: [
  IconButton(
    icon: const Icon(Icons.file_download),
    tooltip: 'Export',
    onPressed: () => _showExportDialog(context, state.lesson),
  ),
  IconButton(
    icon: const Icon(Icons.file_upload),
    tooltip: 'Import',
    onPressed: () => _showImportDialog(context),
  ),
  // ... existing actions ...
],

// Добавить методы:
void _showExportDialog(BuildContext context, LessonModel lesson) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Export Lesson'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('JSON'),
            onTap: () async {
              final exportService = ExportService();
              final json = await exportService.exportToJson(lesson);
              // TODO: Сохранить файл или показать в диалоге
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('YAML'),
            subtitle: const Text('Coming soon'),
            enabled: false,
            onTap: () {},
          ),
        ],
      ),
    ),
  );
}

void _showImportDialog(BuildContext context) {
  // TODO: Реализовать импорт с file_picker
}
```

**Порядок выполнения:**
1. Открыть файл
2. Добавить actions в AppBar
3. Добавить методы _showExportDialog и _showImportDialog
4. Добавить импорт ExportService

**Проверка:**
```bash
flutter run -d chrome
# Проверить наличие кнопок Export/Import в AppBar
# Нажать Export и убедиться, что диалог открывается
```

**Тесты:**
Widget tests для кнопок

---

### PHASE 4F: Validation & Polish (НИЗКИЙ ПРИОРИТЕТ)

#### Task 4F.1: Добавить валидацию в реальном времени
**Файл:** `lib/features/editor/presentation/widgets/scene_validation_widget.dart` (новый)

**Изменения:**
```dart
import 'package:flutter/material.dart';
import '../../bloc/editor_state.dart';

/// Виджет для отображения ошибок валидации сценки
class SceneValidationWidget extends StatelessWidget {
  final EditableScene scene;

  const SceneValidationWidget({
    super.key,
    required this.scene,
  });

  @override
  Widget build(BuildContext context) {
    final errors = _validateScene(scene);

    if (errors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Validation Errors',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...errors.map((error) => Padding(
            padding: const EdgeInsets.only(left: 28, top: 4),
            child: Text(
              '• $error',
              style: TextStyle(color: Colors.red[700]),
            ),
          )),
        ],
      ),
    );
  }

  List<String> _validateScene(EditableScene scene) {
    final errors = <String>[];

    // Проверка пустого диалога для auto_tts
    if (scene.transitionType == 'auto_tts') {
      if (scene.dialogues == null || scene.dialogues!['en']?.isEmpty == true) {
        errors.add('Dialogue is required for auto_tts transition');
      }
    }

    // Проверка buttonTitle для button transition
    if (scene.transitionType == 'button') {
      if (scene.buttonTitles == null || scene.buttonTitles!['en']?.isEmpty == true) {
        errors.add('Button title is required for button transition');
      }
    }

    // Проверка correctAnswer для вопросов
    if (scene.isQuestion) {
      if (scene.correctAnswer == null) {
        errors.add('Correct answer is required for questions');
      }
    }

    // Проверка duration для auto_timer
    if (scene.transitionType == 'auto_timer') {
      if (scene.duration == null || scene.duration == 0) {
        errors.add('Duration is required for auto_timer transition');
      }
    }

    // Проверка exit анимаций для животных
    if (scene.animals?.isNotEmpty == true) {
      for (var animal in scene.animals!) {
        if (animal.exitEffect == null) {
          errors.add('Exit animation is required for ${animal.type}');
        }
      }
    }

    return errors;
  }
}
```

**Порядок выполнения:**
1. Создать файл
2. Скопировать код
3. Добавить в SceneEditorDialog в начале диалога

**Проверка:**
```bash
flutter run -d chrome
# Создать сценку с ошибками валидации
# Проверить, что виджет отображает ошибки
```

**Тесты:**
Unit tests для метода _validateScene

---

## Список экранов для реализации

На основе прототипа UI/UX из `.claude/lesson_editor_UI_UX/lesson_editor_complete.jsx` необходимо создать следующие экраны:

**Примечание:** В прототипе используются placeholder данные (например, "Counting 1-5" как название урока). В реальном приложении там будут актуальные названия редактируемых уроков и сцен из базы данных.

### **Основные экраны (КРИТИЧЕСКИЙ приоритет):**

1. **SCREEN 1: Lessons List** ✅ (частично реализован)
   - Список всех уроков с фильтрацией и поиском
   - Статистика: количество уроков, сценок, языков
   - FAB кнопка для создания нового урока
   - **Статус:** Базовая версия существует, требуется полировка

2. **SCREEN 2: New Lesson** ✅ (частично реализован)
   - Создание нового урока с метаданными
   - Выбор языков (7 языков)
   - Topic, Difficulty, Tags
   - **Статус:** Базовая версия существует

3. **SCREEN 3: Main Editor (Side-by-Side)** 🎯 **КРИТИЧНЫЙ**
   - Двухпанельный layout: Timeline слева + Scene Editor справа
   - Timeline с визуализацией последовательности сценок
   - Визуализация ветвления для вопросов (task transition)
   - Toolbar с кнопками: Lesson Settings, Export, Import, Undo, Shortcuts
   - **Статус:** Требует переработки (текущая версия использует модальные окна)
   - **Задача:** Интегрировать `LessonTimelineView` и создать Side-by-Side layout

### **Табы Scene Editor (ВЫСОКИЙ приоритет):**

4. **Dialogue Tab** ⚠️ (требует переработки)
   - ⚠️ **КРИТИЧНО:** Текущая версия редактирует только ОДИН диалог
   - **ТРЕБУЕТСЯ:** Список из 1-3 диалогов с возможностью добавления/удаления
   - Для каждого диалога:
     - Выбор персонажа (Orson / Merv / Narrator)
     - Выбор эмоции (😃 Happy, 😮 Surprised, etc.)
     - Редактирование текста диалога
     - Voice Tone selection (friendly, excited, questioning, etc.)
     - Translation Context field для переводчиков
   - Паузы между диалогами (настраиваемые, default: 1.0s)
   - Выбор Primary Language
   - Кнопки: TTS Preview, Auto-Translate, Duration Check
   - **Статус:** Требует значительной переработки

5. **Character Tab** ⚠️ (требует переработки)
   - ⚠️ **КРИТИЧНО:** Персонаж выбирается для КАЖДОГО диалога отдельно (не один на всю сцену)
   - **НОВЫЙ ПОДХОД:** Таб показывает общих персонажей сцены, но выбор происходит в Dialogue Tab
   - Настройки для каждого используемого персонажа:
     - Выбор анимации (idle, wave, walk, happy dance, sad, talking)
     - **Entrance Effect** (как персонаж появляется в начале сцены)
     - **Exit Effect** (как персонаж уходит в конце сцены)
     - Position Character on Screen (X, Y координаты)
   - **Статус:** Требует переработки логики (персонаж не один на всю сцену)

6. **Objects Tab** 🎯 **ВЫСОКИЙ ПРИОРИТЕТ**
   - Список объектов в сценке
   - Quick Add панель с животными и предметами
   - Для каждого объекта: редактирование количества, анимаций (entrance, active, exit)
   - **Рекомендации:** автоматический выбор специфичных анимаций (🦋 → flutter)
   - **Статус:** Реализован частично (Animals Tab), требуется добавить анимационные эффекты

7. **Timeline Tab** 🎯 **КРИТИЧНЫЙ**
   - **Scene-level Timeline** — визуализация временных отрезков ВНУТРИ сценки
   - **Треки для диалогов** (важно!):
     ```
     Track 1: Dialogue 1 (Orson) [00:00-00:03]
     Track 2: Dialogue 2 (Merv)  [00:04-00:07]
     Track 3: Dialogue 3 (Narr)  [00:08-00:11]
     Track 4: Animals (🦋×3)      [00:02-00:11]
     Track 5: Audio/TTS           [00:00-00:11]
     ```
   - Визуализация пауз между диалогами
   - Segments (dividers) для разделения на временные интервалы
   - Scrubber для навигации по timeline
   - **Синхронизация с Live Preview**
   - **Статус:** НЕ РЕАЛИЗОВАН — требуется создать с нуля

8. **Settings Tab** ✅ (реализован)
   - Transition Type (auto_tts, auto_timer, button, task)
   - Duration настройки
   - Background выбор (jungle_morning, jungle_evening)
   - Ambient Sound и Volume slider
   - **Статус:** Реализован, требуется добавить Background и Sound

### **Дополнительные экраны (СРЕДНИЙ приоритет):**

9. **SCREEN 4: Scene Templates** 📝
   - Библиотека шаблонов: Greeting, Counting, Question, Celebration, Pause
   - Быстрое создание сценки из шаблона
   - **Статус:** НЕ РЕАЛИЗОВАН

10. **SCREEN 5: Object Editor** 📝
    - Детальное редактирование объекта (животного/предмета)
    - Количество (count)
    - Entrance, Active, Exit анимации
    - Позиционирование (X, Y координаты)
    - **Рекомендованные анимации** с подсказками
    - **Статус:** НЕ РЕАЛИЗОВАН

11. **SCREEN 6: Animation Picker** 📝
    - Библиотека всех 41 анимационных эффектов
    - Категории: Basic (10), Fancy (6), Exit (11), Active/Idle (7), Object-Specific (7)
    - Preview каждого эффекта
    - Фильтрация по категориям
    - **Статус:** НЕ РЕАЛИЗОВАН

12. **SCREEN 7: Question Editor** 📝
    - Редактирование вопроса (isQuestion: true)
    - Добавление вариантов ответов (options)
    - Указание правильного ответа (correctAnswer)
    - Визуализация ветвления (Correct → Scene X, Wrong → Retry)
    - **Статус:** НЕ РЕАЛИЗОВАН

13. **SCREEN 8: Localization Editor** 🎯 **ВЫСОКИЙ ПРИОРИТЕТ**
    - Inline редактирование всех 7 языков одновременно
    - Цветовая индикация статуса перевода (auto, manual, missing)
    - Иконка ✏️ для ручной корректировки
    - Кнопка 🔊 для TTS preview каждого языка
    - **Translation Context** показывается переводчикам
    - **Статус:** НЕ РЕАЛИЗОВАН

14. **SCREEN 9: TTS Duration Comparison** 📝
    - Сравнение длительности диалога на всех языках
    - Визуализация: EN: 2.3s | RU: 3.1s ⚠️ (too long)
    - Предупреждения о несоответствиях
    - **Статус:** НЕ РЕАЛИЗОВАН

15. **SCREEN 10: Positioning** 📝
    - Drag-and-drop персонажей и объектов в Live Preview
    - Grid и Snap для точного выравнивания
    - Preset позиции: "Top Left", "Center", "Near Orson", "Tree Branch"
    - Сохранение координат (X, Y)
    - **Статус:** НЕ РЕАЛИЗОВАН

16. **SCREEN 11: Live Preview** 🎯 **КРИТИЧНЫЙ**
    - Полноэкранный preview сценки или урока
    - Play/Pause/Stop controls
    - Timeline Scrubber с синхронизацией
    - Выбор языка для TTS preview
    - Режимы: Scene Preview | Full Lesson Preview
    - **Статус:** Частично реализован (ScenePreviewWidget), требуется расширение

### **Утилитарные экраны (НИЗКИЙ приоритет):**

17. **SCREEN 12: Validation** 📝
    - Список всех ошибок валидации в уроке
    - Группировка по типам ошибок
    - Быстрый переход к проблемной сценке
    - Auto-fix где возможно
    - **Статус:** НЕ РЕАЛИЗОВАН

18. **SCREEN 13: Export** 📝
    - Экспорт в JSON, YAML, ZIP
    - Опции: All localizations, Audio files, Background images
    - **Статус:** НЕ РЕАЛИЗОВАН (ExportService создан в Phase 4E)

19. **SCREEN 14: Import** 📝
    - Импорт из JSON/YAML/ZIP
    - Валидация структуры файла
    - Предпросмотр импортируемого урока
    - Разрешение конфликтов
    - **Статус:** НЕ РЕАЛИЗОВАН

20. **SCREEN 15: Keyboard Shortcuts** 📝
    - Список всех горячих клавиш
    - Группировка по категориям
    - **Статус:** НЕ РЕАЛИЗОВАН

21. **SCREEN 16: Undo/Redo History** 📝
    - История изменений (до 50 состояний)
    - Визуализация timeline истории
    - **Статус:** НЕ РЕАЛИЗОВАН

22. **SCREEN 17: Context Menu** 📝
    - Правый клик на сценке
    - Quick actions: Edit, Duplicate, Delete, Move Up/Down
    - **Статус:** НЕ РЕАЛИЗОВАН

23. **SCREEN 18: Lesson Settings** 📝
    - Метаданные урока (title, description, topic, difficulty, tags)
    - Настройки языков
    - **Статус:** НЕ РЕАЛИЗОВАН

24. **SCREEN 19: App Settings** 📝
    - Глобальные настройки приложения
    - Claude API key для автоперевода
    - Azure TTS настройки
    - **Статус:** НЕ РЕАЛИЗОВАН

---

## Обновленный план реализации

### **Приоритет 0: КРИТИЧНО - Переработка модели данных (ПЕРВООЧЕРЕДНОЕ!)**

⚠️ **ВНИМАНИЕ:** Текущая модель данных хранит только ОДИН диалог на сцену. Необходимо переработать:

1. **SceneModel** — добавить массив диалогов (1-3 шт):
   ```dart
   class SceneModel {
     // Старое (удалить):
     // String? character;
     // Map<String, String>? dialogues;
     // String? emotion;

     // НОВОЕ:
     List<DialogueSegment> dialogueSegments; // 1-3 диалога
     List<double> pausesBetweenDialogues;    // паузы между диалогами (в секундах)

     // Общие для всей сцены:
     String? background;                      // jungle_morning
     String? ambientSound;                    // jungle_ambience
     List<Animal> animals;                    // 🦋×3
   }

   class DialogueSegment {
     String character;                        // "orson", "merv", "narrator"
     String emotion;                          // "happy", "sad", etc.
     Map<String, String> dialogue;            // {"en": "Hello!", "ru": "Привет!"}
     String? voiceTone;                       // "friendly", "excited"
     String? translationContext;              // для переводчиков
   }
   ```

2. **EditableScene (EditorState)** — синхронизировать с новой моделью

3. **Миграция БД (Drift)** — обновить схему таблиц

**Время на переработку:** 2-3 дня
**Статус:** ⚠️ БЛОКИРУЕТ дальнейшую разработку Dialogue Tab

---

### **Приоритет 1: КРИТИЧНЫЕ экраны**

1. **Dialogue Tab** — ⚠️ **ПЕРЕРАБОТКА** (зависит от Приоритета 0)
   - Список из 1-3 диалогов вместо одного
   - Для каждого диалога: персонаж, эмоция, текст
   - Настройка пауз между диалогами
   - Drag-and-drop для изменения порядка диалогов
   - **Зависимость:** требует новой модели данных

2. **SCREEN 3: Main Editor (Side-by-Side)** — переработка текущего LessonEditorPage
   - Интегрировать `LessonTimelineView` (Task 4A.7 уже в плане)
   - Создать Side-by-Side layout вместо модальных окон
   - Добавить визуализацию ветвления для вопросов

3. **Timeline Tab (Scene-level)** — новый таб в Scene Editor
   - Визуализация временных отрезков внутри сценки
   - Треки для КАЖДОГО диалога (не один персонаж на всю сцену!)
   - Segments и dividers
   - Синхронизация с Live Preview

4. **SCREEN 11: Live Preview** — расширение существующего ScenePreviewWidget
   - Полноэкранный режим
   - Последовательное воспроизведение 1-3 диалогов с паузами
   - Timeline Scrubber с синхронизацией
   - TTS preview для всех языков
   - Режимы: Scene | Full Lesson

5. **SCREEN 8: Localization Editor** — inline редактирование всех языков
   - Показ всех 7 языков одновременно для КАЖДОГО диалога
   - Ручная корректировка
   - TTS preview для каждого языка

### **Приоритет 2: ВЫСОКИЕ**

6. **Objects Tab** — расширение существующего Animals Tab
   - Добавить AnimationEffectPicker (уже в плане 4C.2)
   - Smart defaults для объектов

7. **Character Tab** — переработка логики
   - ⚠️ Персонаж выбирается в каждом диалоге отдельно
   - Character Tab показывает настройки для всех используемых персонажей:
     - Entrance/Exit эффекты для каждого персонажа
     - Positioning для каждого персонажа
   - AnimationEffectPicker для персонажей

8. **Settings Tab** — добавление Background и Sound
   - BackgroundPicker (уже в плане 4D.1-4D.2)
   - Ambient Sound picker
   - Volume slider

### **Приоритет 3: СРЕДНИЕ**

9. **SCREEN 4: Scene Templates**
   - Шаблоны с несколькими диалогами (1-3)

10. **SCREEN 5: Object Editor**
11. **SCREEN 6: Animation Picker**
12. **SCREEN 7: Question Editor**
13. **SCREEN 9: TTS Duration Comparison**
    - Сравнение длительности для КАЖДОГО диалога в сцене

14. **SCREEN 10: Positioning**
15. **SCREEN 13: Export** (ExportService уже создан)
16. **SCREEN 14: Import**

### **Приоритет 4: НИЗКИЕ**

16. **SCREEN 12: Validation**
17. **SCREEN 15-19: Утилитарные экраны**

---

## Summary

### Порядок реализации (по приоритетам):

**✅ Уже реализовано (Phase 1-3 + 4C):**
- ✅ Drift database с seed service
- ✅ EditorBloc с BLoC pattern
- ✅ SceneEditorDialog с 4 вкладками (Dialogue, Character, Settings, Animals)
- ✅ Автоперевод через Claude API
- ✅ **Phase 4C**: Animation Effects UI с рекомендациями для животных
- ⚠️ **ОГРАНИЧЕНИЕ:** Текущая модель поддерживает только ОДИН диалог на сцену (требуется переработка)

**⚠️ Phase 4X: Переработка модели данных (КРИТИЧЕСКИЙ - ПЕРВООЧЕРЕДНОЕ!)**
   - **БЛОКИРУЕТ:** все дальнейшие фазы
   - **Задачи:**
     1. Создать `DialogueSegment` модель
     2. Обновить `SceneModel` — добавить `List<DialogueSegment>`
     3. Миграция Drift database
     4. Обновить `EditableScene` в EditorState
     5. Обновить EditorBloc events/handlers
     6. Переработать Dialogue Tab UI для списка диалогов
   - **Цель:** Поддержка 1-3 диалогов в одной сцене
   - **Время:** 2-3 дня

**🎯 Phase 4A: Timeline View (КРИТИЧЕСКИЙ)**
   - Tasks 4A.1 - 4A.7
   - **Экраны:** SCREEN 3 (Main Editor) - Timeline в левой панели
   - Цель: Визуализация последовательности сценок с ветвлением
   - **Зависимость:** Phase 4X (новая модель данных)
   - Время: 2-3 дня

**🎯 Phase 4B: Live Preview (КРИТИЧЕСКИЙ)**
   - Tasks 4B.1 - 4B.2
   - **Экраны:** SCREEN 11 (Live Preview) + Preview таб в Scene Editor
   - Цель: Предпросмотр сценки с синхронизацией Timeline
   - Время: 2-3 дня (расширенная версия)

**🎯 Phase 4G: Scene-Level Timeline (КРИТИЧЕСКИЙ - НОВЫЙ)**
   - **Экран:** Timeline Tab в Scene Editor (SCREEN 7)
   - Цель: Визуализация временных отрезков ВНУТРИ сценки
   - Функционал:
     - ⚠️ **ВАЖНО:** Треки для КАЖДОГО диалога (не один персонаж на всю сцену!)
     - Track 1: Dialogue 1 (Orson) [00:00-00:03]
     - Track 2: Pause [00:03-00:04]
     - Track 3: Dialogue 2 (Merv) [00:04-00:07]
     - Track 4: Animals (🦋×3) [00:02-00:10]
     - Track 5: Audio/TTS [00:00-00:10]
     - Segments (dividers) для разделения на временные интервалы
     - Scrubber для навигации
     - Синхронизация с Live Preview
   - **Зависимость:** Phase 4X (новая модель данных)
   - Время: 3-4 дня

**🎯 Phase 4H: Localization Editor (ВЫСОКИЙ - НОВЫЙ)**
   - **Экран:** SCREEN 8 (Localization Editor)
   - Цель: Inline редактирование всех 7 языков одновременно
   - Функционал:
     - ⚠️ **ВАЖНО:** Редактирование для КАЖДОГО диалога в сцене (1-3 шт)
     - Показ всех языков в компактном виде
     - Цветовая индикация (auto/manual/missing)
     - TTS preview для каждого языка
     - Translation Context для каждого диалога
   - **Зависимость:** Phase 4X (новая модель данных)
   - Время: 2-3 дня

**✅ Phase 4C: Animation Effects UI (ЗАВЕРШЕНО)**
   - Tasks 4C.1 - 4C.2 ✅
   - **Экраны:** Objects Tab + Character Tab (анимационные эффекты)
   - Цель: UI для выбора анимационных эффектов с рекомендациями
   - **Реализовано:**
     - ✅ AnimationEffect enum с 53 эффектами
     - ✅ AnimationEffectPicker виджет с рекомендациями
     - ✅ Интеграция в Animals Tab (3 пикера: entrance, active, exit)
     - ✅ Smart defaults для разных типов животных
     - ✅ Обновлена модель данных (AnimalModel, SceneModel, EditableScene)
   - Время: 2-3 дня

**📝 Phase 4D: Background & Sound (СРЕДНИЙ)**
   - Tasks 4D.1 - 4D.2
   - **Экран:** Settings Tab (Background и Sound секции)
   - Цель: Выбор фона и звуков для сценок
   - Время: 1 день

**📝 Phase 4I: Scene Templates (СРЕДНИЙ - НОВЫЙ)**
   - **Экран:** SCREEN 4 (Scene Templates)
   - Цель: Библиотека готовых шаблонов сценок
   - Шаблоны: Greeting, Counting, Question, Celebration, Pause
   - Время: 1-2 дня

**📝 Phase 4J: Object Editor (СРЕДНИЙ - НОВЫЙ)**
   - **Экран:** SCREEN 5 (Object Editor)
   - Цель: Детальное редактирование объекта
   - Функционал: Count, Entrance/Active/Exit animations, Positioning
   - Время: 1-2 дня

**📝 Phase 4K: Animation Picker (СРЕДНИЙ - НОВЫЙ)**
   - **Экран:** SCREEN 6 (Animation Picker)
   - Цель: Библиотека всех 41 анимационных эффектов
   - Функционал: Категории, Preview, Фильтрация
   - Время: 1-2 дня

**📝 Phase 4E: Export/Import (СРЕДНИЙ)**
   - Tasks 4E.1 - 4E.2
   - **Экраны:** SCREEN 13 (Export) + SCREEN 14 (Import)
   - Цель: Экспорт/импорт уроков в JSON/YAML/ZIP
   - Время: 2-3 дня (с UI)

**📝 Phase 4L: Question Editor (СРЕДНИЙ - НОВЫЙ)**
   - **Экран:** SCREEN 7 (Question Editor)
   - Цель: Редактирование вопросов с ветвлением
   - Время: 1-2 дня

**📝 Phase 4M: Positioning (СРЕДНИЙ - НОВЫЙ)**
   - **Экран:** SCREEN 10 (Positioning)
   - Цель: Drag-and-drop позиционирование объектов
   - Время: 2-3 дня

**📝 Phase 4F: Validation (НИЗКИЙ)**
   - Task 4F.1 + SCREEN 12 (Validation)
   - Цель: Валидация в реальном времени + экран списка ошибок
   - Время: 1-2 дня

**📝 Phase 4N: Утилитарные экраны (НИЗКИЙ - НОВЫЙ)**
   - **Экраны:** SCREEN 15-19 (Shortcuts, Undo/Redo, Context Menu, Settings)
   - Время: 3-5 дней

---

### **Общее время реализации Phase 4: 26-43 дней**

Разбивка:
- **⚠️ ПЕРВООЧЕРЕДНОЕ (Phase 4X):** 2-3 дня — переработка модели данных
- **КРИТИЧНЫЕ (Phases 4A, 4B, 4G, 4H):** 9-13 дней
- **ВЫСОКИЕ (Phase 4C):** 2-3 дня
- **СРЕДНИЕ (Phases 4D, 4I, 4J, 4K, 4E, 4L, 4M):** 10-17 дней
- **НИЗКИЕ (Phases 4F, 4N):** 4-7 дней

### Критерии готовности:
- ✅ Все unit тесты проходят
- ✅ Все widget тесты проходят
- ✅ `flutter analyze` не выдаёт ошибок
- ✅ Редактор запускается без ошибок
- ✅ Timeline View отображает сценки
- ✅ Live Preview работает
- ✅ Можно выбрать анимационные эффекты для объектов
- ✅ Можно выбрать фон и звуки
- ✅ Можно экспортировать урок в JSON
- ✅ Валидация показывает ошибки

---

## Таблица соответствия экранов из прототипа

| # | Экран | Статус | Приоритет | Phase | Примечания |
|---|-------|--------|-----------|-------|------------|
| 1 | Lessons List | ✅ Частично | Средний | - | Требуется полировка UI |
| 2 | New Lesson | ✅ Частично | Средний | - | Базовая версия работает |
| 3 | Main Editor (Side-by-Side) | 🎯 В плане | **КРИТИЧНЫЙ** | 4A | Timeline + Side-by-Side layout |
| 4 | Scene Templates | 📝 Не реализован | Средний | 4I | Библиотека шаблонов |
| 5 | Object Editor | 📝 Не реализован | Средний | 4J | Детальное редактирование |
| 6 | Animation Picker | 📝 Не реализован | Средний | 4K | Библиотека 41 эффекта |
| 7 | Question Editor | 📝 Не реализован | Средний | 4L | Ветвление для вопросов |
| 8 | Localization Editor | 🎯 В плане | **ВЫСОКИЙ** | 4H | Inline 7 языков + TTS |
| 9 | TTS Duration Comparison | 📝 Не реализован | Средний | - | Сравнение длительности |
| 10 | Positioning | 📝 Не реализован | Средний | 4M | Drag-and-drop |
| 11 | Live Preview | 🎯 В плане | **КРИТИЧНЫЙ** | 4B | Расширение ScenePreviewWidget |
| 12 | Validation | 📝 В плане | Низкий | 4F | Список ошибок |
| 13 | Export | 📝 В плане | Средний | 4E | JSON/YAML/ZIP |
| 14 | Import | 📝 В плане | Средний | 4E | С валидацией |
| 15 | Keyboard Shortcuts | 📝 Не реализован | Низкий | 4N | Справка по горячим клавишам |
| 16 | Undo/Redo History | 📝 Не реализован | Низкий | 4N | Timeline истории |
| 17 | Context Menu | 📝 Не реализован | Низкий | 4N | Правый клик на сценке |
| 18 | Lesson Settings | 📝 Не реализован | Низкий | 4N | Метаданные урока |
| 19 | App Settings | 📝 Не реализован | Низкий | 4N | Глобальные настройки |
| - | **Dialogue Tab** | ⚠️ Требует переработки | **КРИТИЧНЫЙ** | 4X | Поддержка 1-3 диалогов вместо одного |
| - | **Character Tab** | ⚠️ Требует переработки | Высокий | 4C | Персонаж выбирается в каждом диалоге |
| - | **Objects Tab** | ✅ Частично | **ВЫСОКИЙ** | 4C | Требуется AnimationEffectPicker |
| - | **Timeline Tab** (Scene-level) | 🎯 В плане | **КРИТИЧНЫЙ** | 4G | Новый таб с треками |
| - | **Settings Tab** | ✅ Реализован | Средний | 4D | Требуется Background & Sound |

**Легенда:**
- ✅ Реализован / Частично реализован
- 🎯 В плане Phase 4 (запланирован)
- 📝 Не реализован (будет добавлено позже)

---

---

## Концептуальный UI редактора диалогов

**Примечание:** "Counting Butterflies" в примере ниже — это просто placeholder название сцены из прототипа. В реальном приложении тут будет актуальное название редактируемой сцены (например, "Считаем бабочек", "Приветствие", "Вопрос про цвета" и т.д.).

```
┌─────────────────────────────────────────────────────────┐
│ Scene 3: Counting Butterflies                          │
├─────────────────────────────────────────────────────────┤
│ 🎨 Background: jungle_morning                          │
│ 🔊 Ambient: jungle_ambience (30%)                      │
│ 🦋 Objects: Butterfly ×3 (appear at 00:02)            │
├─────────────────────────────────────────────────────────┤
│ 📝 Dialogues (1-3)                          [+ Add]    │
│                                                         │
│ ┌─ 1 ─────────────────────────────────────────┐        │
│ │ 🐱 Orson  😃 Happy                         │        │
│ │ "Привет! Посмотри на бабочек!"            │        │
│ │ Voice: friendly  [🔊 Preview] [🌐 7 langs] │        │
│ │ Duration: 3.0s                        [×]  │        │
│ └────────────────────────────────────────────┘        │
│              ⏸️ Pause: 1.0s ⬇️                         │
│ ┌─ 2 ─────────────────────────────────────────┐        │
│ │ 🐻 Merv  😮 Surprised                      │        │
│ │ "Ого, как их много!"                      │        │
│ │ Voice: excited   [🔊 Preview] [🌐 7 langs] │        │
│ │ Duration: 2.5s                        [×]  │        │
│ └────────────────────────────────────────────┘        │
│              ⏸️ Pause: 1.0s ⬇️                         │
│ ┌─ 3 ─────────────────────────────────────────┐        │
│ │ 🎙️ Narrator                                │        │
│ │ "Давайте посчитаем вместе"                │        │
│ │ Voice: friendly  [🔊 Preview] [🌐 7 langs] │        │
│ │ Duration: 2.8s                        [×]  │        │
│ └────────────────────────────────────────────┘        │
│                                                         │
│ Total Duration: ~10.3s                                 │
│                                                         │
│ [+ Add Dialogue] (max 3)                               │
└─────────────────────────────────────────────────────────┘
```

**Ключевые фичи UI:**
1. ✅ Drag-and-drop для изменения порядка диалогов
2. ✅ Inline редактирование каждого диалога
3. ✅ Визуализация пауз между диалогами (настраиваемые)
4. ✅ Выбор персонажа и эмоции для каждого диалога
5. ✅ Кнопка "×" для удаления диалога
6. ✅ Ограничение: максимум 3 диалога
7. ✅ Total Duration показывает общую длительность сцены

---

**Следующий шаг:** Начать с **Phase 4X** (переработка модели данных) — **КРИТИЧНО!**
