# План реализации текстовых вариантов ответов

## Обзор задачи

Текущая система поддерживает только числовые ответы (1, 2, 3, 4, 5). Нужно добавить поддержку текстовых вариантов ответов, например для уроков о цветах: "Черный", "Белый", "Желтый", "Зеленый".

## Текущая архитектура

### Модели данных

**Scene entity** ([lib/features/lessons/domain/entities/lesson.dart:27-111](lib/features/lessons/domain/entities/lesson.dart#L27-L111)):
- `isQuestion: bool` — это вопрос?
- `correctAnswer: int?` — правильный числовой ответ
- `waitForAnswer: bool` — ждать ответа?

**JSON формат** (например `lesson_colors_in_the_jungle_p2.json`):
```json
{
  "isQuestion": true,
  "correctAnswerText": {
    "en": "white",
    "ru": "белый"
  },
  "waitForAnswer": true
}
```

> **Примечание:** В JSON уже есть поле `correctAnswerText`, но оно НЕ парсится и не используется!

### Виджет кнопок ответа

**AnswerButtons** ([lib/features/lessons/presentation/widgets/answer_buttons.dart](lib/features/lessons/presentation/widgets/answer_buttons.dart)):
- Только числовые кнопки 1-5
- `maxNumber: int` — максимальное число
- `onAnswer: Function(int)` — callback с числовым ответом

### BLoC

**LessonBloc** ([lib/features/lessons/presentation/bloc/lesson_bloc.dart](lib/features/lessons/presentation/bloc/lesson_bloc.dart)):
- `AnswerQuestion(int answer)` — событие с числовым ответом
- Сравнивает `event.answer == scene.correctAnswer`

---

## План реализации

### Этап 1: Расширение модели данных

#### 1.1 Обновить Scene entity

**Файл:** `lib/features/lessons/domain/entities/lesson.dart`

Добавить новые поля:
```dart
class Scene extends Equatable {
  // ... существующие поля ...

  // Новые поля для текстовых ответов
  final String? correctAnswerText;           // Правильный текстовый ответ
  final List<AnswerOption>? answerOptions;   // Варианты ответов

  // ... конструктор и props ...
}

/// Вариант ответа (для текстовых и числовых ответов)
class AnswerOption extends Equatable {
  final dynamic value;     // Значение (int или String)
  final String label;      // Отображаемый текст

  const AnswerOption({
    required this.value,
    required this.label,
  });

  @override
  List<Object?> get props => [value, label];
}
```

#### 1.2 Обновить SceneModel

**Файл:** `lib/features/lessons/data/models/lesson_model.dart`

Добавить парсинг новых полей:
```dart
class SceneModel extends Scene {
  // ...

  factory SceneModel.fromJson(Map<String, dynamic> json, {String locale = 'en'}) {
    // ... существующий код ...

    return SceneModel(
      // ... существующие поля ...
      correctAnswerText: getLocalizedString(json['correctAnswerText'], locale),
      answerOptions: (json['answerOptions'] as List?)
          ?.map((opt) => AnswerOptionModel.fromJson(opt, locale: locale))
          .toList(),
    );
  }
}

class AnswerOptionModel extends AnswerOption {
  const AnswerOptionModel({
    required super.value,
    required super.label,
  });

  factory AnswerOptionModel.fromJson(Map<String, dynamic> json, {String locale = 'en'}) {
    String getLocalizedString(dynamic value, String locale) {
      if (value is String) return value;
      if (value is Map) return value[locale] ?? value['en'] ?? '';
      return '';
    }

    return AnswerOptionModel(
      value: json['value'],  // int или String
      label: getLocalizedString(json['label'], locale),
    );
  }
}
```

---

### Этап 2: Новый виджет TextAnswerButtons

#### 2.1 Создать виджет

**Файл:** `lib/features/lessons/presentation/widgets/text_answer_buttons.dart`

```dart
import 'package:flutter/material.dart';
import '../../domain/entities/lesson.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Widget for displaying text answer buttons during lessons
class TextAnswerButtons extends StatelessWidget {
  final List<AnswerOption> options;
  final Function(dynamic) onAnswer;
  final dynamic selectedAnswer;
  final dynamic correctAnswer;

  const TextAnswerButtons({
    super.key,
    required this.options,
    required this.onAnswer,
    this.selectedAnswer,
    this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: options.map((option) {
        final isSelected = selectedAnswer == option.value;
        final isCorrect = correctAnswer == option.value;
        final isDisabled = selectedAnswer != null && !isSelected;

        return _TextAnswerButton(
          label: option.label,
          onTap: selectedAnswer == null ? () => onAnswer(option.value) : null,
          isSelected: isSelected,
          isCorrect: isCorrect,
          isDisabled: isDisabled,
        );
      }).toList(),
    );
  }
}

class _TextAnswerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isCorrect;
  final bool isDisabled;

  const _TextAnswerButton({
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
    this.isDisabled = false,
  });

  Color _getButtonColor() {
    if (isCorrect) return AppColors.correct;
    if (isDisabled) return Colors.grey.shade400;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _getButtonColor(),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      elevation: isDisabled ? 1 : 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 80,
            minHeight: 56,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDisabled ? Colors.grey.shade600 : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
```

---

### Этап 3: Обновление BLoC

#### 3.1 Обновить событие AnswerQuestion

**Файл:** `lib/features/lessons/presentation/bloc/lesson_bloc.dart`

Изменить тип ответа с `int` на `dynamic`:
```dart
class AnswerQuestion extends LessonEvent {
  final dynamic answer;  // int или String
  AnswerQuestion(this.answer);

  @override
  List<Object> get props => [answer];
}
```

#### 3.2 Обновить обработчик _onAnswerQuestion

```dart
void _onAnswerQuestion(
  AnswerQuestion event,
  Emitter<LessonState> emit,
) {
  if (state is LessonLoaded) {
    final current = state as LessonLoaded;
    final scene = current.currentScene;

    if (scene.waitForAnswer) {
      bool isCorrect = false;

      // Проверяем текстовый ответ
      if (scene.correctAnswerText != null) {
        isCorrect = event.answer.toString().toLowerCase() ==
                    scene.correctAnswerText!.toLowerCase();
      }
      // Проверяем числовой ответ (для обратной совместимости)
      else if (scene.correctAnswer != null) {
        isCorrect = event.answer == scene.correctAnswer;
      }

      final updatedState = isCorrect
        ? current.copyWith(correctAnswers: current.correctAnswers + 1)
        : current;

      emit(LessonAnswered(isCorrect, event.answer, updatedState));
    }
  }
}
```

#### 3.3 Обновить LessonAnswered state

```dart
class LessonAnswered extends LessonState {
  final bool isCorrect;
  final dynamic selectedAnswer;  // int или String
  final LessonLoaded loadedState;

  LessonAnswered(this.isCorrect, this.selectedAnswer, this.loadedState);

  @override
  List<Object> get props => [isCorrect, selectedAnswer, loadedState];
}
```

---

### Этап 4: Обновление LessonPage

#### 4.1 Импортировать новый виджет

**Файл:** `lib/features/lessons/presentation/pages/lesson_page.dart`

```dart
import '../widgets/text_answer_buttons.dart';
```

#### 4.2 Условный рендеринг кнопок

Заменить секцию с кнопками ответа:
```dart
// Кнопки ответа (если это вопрос)
if (scene.waitForAnswer) ...[
  const SizedBox(height: AppDimensions.paddingLarge),

  // Текстовые варианты (если есть answerOptions)
  if (scene.answerOptions != null && scene.answerOptions!.isNotEmpty)
    TextAnswerButtons(
      options: scene.answerOptions!,
      onAnswer: (answer) {
        context.read<LessonBloc>().add(AnswerQuestion(answer));
      },
      selectedAnswer: state is LessonAnswered ? state.selectedAnswer : null,
      correctAnswer: state is LessonAnswered ? scene.correctAnswerText : null,
    )
  // Числовые кнопки (если нет answerOptions, но есть correctAnswer)
  else if (scene.correctAnswer != null)
    AnswerButtons(
      maxNumber: 5,
      onAnswer: (answer) {
        context.read<LessonBloc>().add(AnswerQuestion(answer));
      },
      selectedAnswer: state is LessonAnswered ? state.selectedAnswer : null,
      correctAnswer: state is LessonAnswered ? scene.correctAnswer : null,
    ),
],
```

---

### Этап 5: Обновление JSON формата уроков

#### 5.1 Формат для текстовых ответов

```json
{
  "character": "orson",
  "dialogue": {
    "en": "What colour is the cloud?",
    "ru": "Какого цвета облако?"
  },
  "isQuestion": true,
  "correctAnswerText": {
    "en": "white",
    "ru": "белый"
  },
  "answerOptions": [
    {
      "value": "black",
      "label": {"en": "Black", "ru": "Чёрный"}
    },
    {
      "value": "white",
      "label": {"en": "White", "ru": "Белый"}
    },
    {
      "value": "yellow",
      "label": {"en": "Yellow", "ru": "Жёлтый"}
    },
    {
      "value": "green",
      "label": {"en": "Green", "ru": "Зелёный"}
    }
  ],
  "waitForAnswer": true,
  "transitionType": "task"
}
```

#### 5.2 Обновить lesson_colors_in_the_jungle_p2.json

Добавить `answerOptions` ко всем вопросам о цветах.

---

## Файлы для изменения

| Файл | Изменения |
|------|-----------|
| `lib/features/lessons/domain/entities/lesson.dart` | Добавить `correctAnswerText`, `answerOptions`, класс `AnswerOption` |
| `lib/features/lessons/data/models/lesson_model.dart` | Парсинг новых полей, класс `AnswerOptionModel` |
| `lib/features/lessons/presentation/bloc/lesson_bloc.dart` | `dynamic answer`, обновить проверку ответа |
| `lib/features/lessons/presentation/widgets/text_answer_buttons.dart` | **Новый файл** |
| `lib/features/lessons/presentation/pages/lesson_page.dart` | Условный рендеринг кнопок |
| `assets/data/lessons/lesson_colors_in_the_jungle_p2.json` | Добавить `answerOptions` |

---

## Обратная совместимость

- Существующие уроки с числовыми ответами продолжат работать
- Поле `correctAnswer: int?` остаётся для числовых вопросов
- Система автоматически выбирает нужный тип кнопок на основе данных сцены

---

## Тестирование

1. **Unit тесты:**
   - Парсинг `AnswerOption` из JSON
   - Проверка правильности текстового ответа в BLoC

2. **Widget тесты:**
   - `TextAnswerButtons` отображает варианты
   - Подсветка правильного/неправильного ответа

3. **Integration тест:**
   - Пройти урок о цветах с текстовыми ответами

---

## Оценка сложности

- **Этап 1 (Модели):** Простой
- **Этап 2 (Виджет):** Простой (похож на существующий)
- **Этап 3 (BLoC):** Простой
- **Этап 4 (LessonPage):** Простой
- **Этап 5 (JSON):** Простой

**Общая сложность:** Низкая-Средняя

---

## Дополнительные улучшения (опционально)

1. **Перемешивание вариантов** — случайный порядок кнопок
2. **Иконки/эмодзи в кнопках** — визуальные подсказки для цветов
3. **Анимация при выборе** — bounce/scale эффект
4. **Голосовое озвучивание вариантов** — TTS при нажатии на кнопку
