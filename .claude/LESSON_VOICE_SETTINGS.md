# Lesson Voice Settings - План реализации

**Дата создания:** 2025-11-26
**Цель:** Проставить оптимальные голосовые настройки (voiceContext) для всех диалогов в уроках, чтобы голоса звучали естественно и интересно для детей 5-7 лет.

---

## Обзор текущего состояния

### Персонажи и их голоса

| Персонаж | Тип | EN Voice | Pitch | Rate | Default Style |
|----------|-----|----------|-------|------|---------------|
| **Orson** 🦁 | Взрослый М | Guy Neural | 0% | 0.90 | friendly |
| **Merv** 🧙 | Ребёнок Ж | Ana Neural (Child) | +5% | 0.92 | friendly |

**Детские голоса по языкам для Merv:**

| Язык | Голос | Детский? | Стили? |
|------|-------|----------|--------|
| EN | Ana Neural | ✅ Да | ✅ cheerful, friendly, excited... |
| RU | Dariya Neural | ❌ Нет (повышен pitch +10%) | ❌ |
| DE | Gisela Neural | ✅ Да | ❌ |
| FR | Eloise Neural | ✅ Да | ❌ |
| IT | Pierina Neural | ✅ Да | ❌ |
| AM | Mekdes Neural | ❌ Нет (повышен pitch +12%) | ❌ |
| MY | Nilar Neural | ❌ Нет (повышен pitch +12%) | ❌ |

### Уроки для обработки

| Урок | Файл | Сцен | Персонажи |
|------|------|------|-----------|
| Counting as a Game of Friends | `lesson_counting.json` | 24 | Orson, Merv |
| Subtraction as Hide and Seek | `lesson_subtraction.json` | 21 | Orson, Merv |

### Доступные тоны в уроках

Текущие tone значения в JSON:
- `friendly`, `cheerful`, `excited`, `clear`, `amazed`, `questioning`
- `counting`, `enthusiastic`, `proud`, `happy`, `grateful`
- `mysterious`, `inviting`, `surprised`, `thoughtful`, `calm`, `explaining`, `playful`

---

## Plan

### PHASE 1: Расширить DialogueVoiceContext (1 час) ✅ ВЫПОЛНЕНО

**Статус:** ✅ Выполнено 2025-11-26
**Цель:** Добавить недостающие factory-конструкторы для всех тонов из уроков.

#### Задача 1.1: Добавить новые factory методы

**Файл:** `lib/features/lessons/domain/entities/dialogue_voice_context.dart`

**Изменения:**

```dart
// После существующих factory методов, добавить:

/// Create context for clear/explaining speech (teacher mode)
factory DialogueVoiceContext.clear() {
  return const DialogueVoiceContext(
    style: 'friendly',
    styleDegree: 1.0,
    rateModifier: 0.92, // Чуть медленнее для ясности
    breakAfter: 300, // Пауза после для усвоения
  );
}

/// Create context for amazed/wow speech
factory DialogueVoiceContext.amazed({double intensity = 1.4}) {
  return DialogueVoiceContext(
    style: 'excited',
    styleDegree: intensity,
    pitchModifier: '+8%',
    rateModifier: 0.95,
  );
}

/// Create context for counting numbers
factory DialogueVoiceContext.counting() {
  return const DialogueVoiceContext(
    style: 'cheerful',
    styleDegree: 1.1,
    rateModifier: 0.80, // Медленно для чёткости
    breakAfter: 200, // Пауза между числами
  );
}

/// Create context for enthusiastic/praise speech
factory DialogueVoiceContext.enthusiastic({double intensity = 1.4}) {
  return DialogueVoiceContext(
    style: 'excited',
    styleDegree: intensity,
    pitchModifier: '+7%',
    rateModifier: 1.05,
  );
}

/// Create context for proud speech (praising child)
factory DialogueVoiceContext.proud({double intensity = 1.3}) {
  return DialogueVoiceContext(
    style: 'cheerful',
    styleDegree: intensity,
    pitchModifier: '+3%',
    rateModifier: 0.95,
  );
}

/// Create context for grateful/thankful speech
factory DialogueVoiceContext.grateful({double intensity = 1.2}) {
  return DialogueVoiceContext(
    style: 'friendly',
    styleDegree: intensity,
    rateModifier: 0.9,
    volume: 'medium',
  );
}

/// Create context for mysterious/magical speech
factory DialogueVoiceContext.mysterious({double intensity = 1.3}) {
  return DialogueVoiceContext(
    style: 'whispering',
    styleDegree: intensity,
    pitchModifier: '-3%',
    rateModifier: 0.85,
    volume: 'soft',
  );
}

/// Create context for inviting/welcoming speech
factory DialogueVoiceContext.inviting({double intensity = 1.2}) {
  return DialogueVoiceContext(
    style: 'friendly',
    styleDegree: intensity,
    pitchModifier: '+5%',
    rateModifier: 0.95,
  );
}

/// Create context for surprised speech
factory DialogueVoiceContext.surprised({double intensity = 1.4}) {
  return DialogueVoiceContext(
    style: 'excited',
    styleDegree: intensity,
    pitchModifier: '+12%',
    rateModifier: 1.1,
    breakBefore: 100,
  );
}

/// Create context for thoughtful/thinking speech
factory DialogueVoiceContext.thoughtful() {
  return const DialogueVoiceContext(
    style: 'friendly',
    styleDegree: 0.9,
    rateModifier: 0.85,
    breakBefore: 300,
    breakAfter: 200,
  );
}

/// Create context for explaining speech (step by step)
factory DialogueVoiceContext.explaining() {
  return const DialogueVoiceContext(
    style: 'friendly',
    styleDegree: 1.0,
    rateModifier: 0.88,
    breakAfter: 400,
  );
}

/// Create context for playful speech
factory DialogueVoiceContext.playful({double intensity = 1.3}) {
  return DialogueVoiceContext(
    style: 'cheerful',
    styleDegree: intensity,
    pitchModifier: '+5%',
    rateModifier: 1.05,
  );
}
```

**Также обновить `fromTone` switch:**

```dart
case 'clear':
  return DialogueVoiceContext.clear();
case 'amazed':
  return DialogueVoiceContext.amazed();
case 'counting':
  return DialogueVoiceContext.counting();
case 'enthusiastic':
  return DialogueVoiceContext.enthusiastic();
case 'proud':
  return DialogueVoiceContext.proud();
case 'grateful':
  return DialogueVoiceContext.grateful();
case 'mysterious':
  return DialogueVoiceContext.mysterious();
case 'inviting':
  return DialogueVoiceContext.inviting();
case 'surprised':
  return DialogueVoiceContext.surprised();
case 'thoughtful':
  return DialogueVoiceContext.thoughtful();
case 'explaining':
  return DialogueVoiceContext.explaining();
case 'playful':
  return DialogueVoiceContext.playful();
```

**Проверка:**
1. Запустить `flutter analyze` — ошибок нет
2. Создать тестовые экземпляры:
```dart
final contexts = [
  DialogueVoiceContext.clear(),
  DialogueVoiceContext.amazed(),
  DialogueVoiceContext.counting(),
  // ... etc
];
```

---

### PHASE 2: Добавить voiceContext в JSON схему Scene (30 мин)

**Цель:** Убедиться, что SceneModel поддерживает поле `voiceContext` при парсинге.

#### Задача 2.1: Проверить SceneModel

**Файл:** `lib/features/lessons/data/models/scene_model.dart`

**Изменения:**
Убедиться, что есть парсинг поля `voiceContext` из JSON. Если нет — добавить:

```dart
factory SceneModel.fromJson(Map<String, dynamic> json) {
  // ... existing code ...

  // Parse voiceContext if present
  DialogueVoiceContext? voiceContext;
  if (json['voiceContext'] != null) {
    voiceContext = DialogueVoiceContext.fromJson(
      json['voiceContext'] as Map<String, dynamic>,
    );
  }

  return SceneModel(
    // ... existing fields ...
    voiceContext: voiceContext,
  );
}
```

**Проверка:**
1. Добавить `voiceContext` в одну сцену JSON и убедиться, что парсится

---

### PHASE 3: Оценить и проставить voiceContext для lesson_counting.json (2 часа)

**Цель:** Для каждой сцены с диалогом проставить оптимальные настройки голоса.

#### Задача 3.1: Анализ сцен lesson_counting.json

**Файл:** `assets/data/lessons/lesson_counting.json`

| # | Персонаж | Текст (EN) | Текущий tone | Рекомендуемый voiceContext |
|---|----------|------------|--------------|---------------------------|
| 3 | orson | "Hello, I'm Orson!" | friendly | `{ "style": "friendly", "styleDegree": 1.2, "breakAfter": 300 }` |
| 4 | orson | "Today, we will learn..." | cheerful | `{ "style": "cheerful", "styleDegree": 1.1, "rateModifier": 0.92 }` |
| 5 | merv | "Hi Orson! I love counting!" | excited | `{ "style": "excited", "styleDegree": 1.4, "pitchModifier": "+5%", "rateModifier": 1.1 }` |
| 6 | orson | "Let's start with one. Look, there's one butterfly!" | clear | `{ "style": "friendly", "rateModifier": 0.9, "breakAfter": 400 }` |
| 7 | merv | "One butterfly! So beautiful!" | amazed | `{ "style": "excited", "styleDegree": 1.4, "pitchModifier": "+8%", "rateModifier": 0.95 }` |
| 8 | orson | "Now let's count monkeys. How many..." | questioning | `{ "style": "friendly", "pitchModifier": "+10%", "breakAfter": 500 }` |
| 9 | orson | "That's right! Four monkeys!" | enthusiastic | `{ "style": "excited", "styleDegree": 1.4, "pitchModifier": "+7%", "rateModifier": 1.05 }` |
| 10 | merv | "One, two, three, four!" | counting | `{ "style": "cheerful", "styleDegree": 1.1, "rateModifier": 0.75, "breakAfter": 200 }` |
| 11 | orson | "Now look at the birds..." | questioning | `{ "style": "friendly", "pitchModifier": "+10%", "breakAfter": 500 }` |
| 12 | orson | "Excellent! Two birds!" | enthusiastic | `{ "style": "excited", "styleDegree": 1.4, "pitchModifier": "+7%" }` |
| 13 | merv | "One, two birds flying!" | happy | `{ "style": "cheerful", "styleDegree": 1.3, "pitchModifier": "+3%" }` |
| 14 | orson | "Now, let's count the turtles..." | questioning | `{ "style": "friendly", "pitchModifier": "+10%", "breakAfter": 500 }` |
| 15 | orson | "Perfect! Five turtles!" | enthusiastic | `{ "style": "excited", "styleDegree": 1.5, "pitchModifier": "+8%" }` |
| 16 | merv | "One, two, three, four, five turtles!" | excited | `{ "style": "excited", "styleDegree": 1.3, "rateModifier": 0.78 }` |
| 17 | orson | "Last one! How many frogs are here?" | questioning | `{ "style": "friendly", "pitchModifier": "+12%", "styleDegree": 1.2 }` |
| 18 | orson | "Amazing! Three frogs!" | proud | `{ "style": "cheerful", "styleDegree": 1.4, "pitchModifier": "+5%" }` |
| 19 | merv | "One, two, three frogs!" | happy | `{ "style": "cheerful", "styleDegree": 1.2, "rateModifier": 0.82 }` |
| 20 | orson | "You did a great job counting today!" | proud | `{ "style": "cheerful", "styleDegree": 1.3, "rateModifier": 0.95 }` |
| 21 | merv | "Now I can count to five! Thank you, Orson!" | grateful | `{ "style": "friendly", "styleDegree": 1.2, "rateModifier": 0.9 }` |
| 22 | orson | "See you next time, friend!" | friendly | `{ "style": "friendly", "styleDegree": 1.1, "breakAfter": 500 }` |

#### Задача 3.2: Применить voiceContext к JSON

**Файл:** `assets/data/lessons/lesson_counting.json`

**Пример изменения:**

```json
{
  "character": "orson",
  "dialogue": {
    "en": "Hello, I'm Orson!",
    ...
  },
  "tone": "friendly",
  "voiceContext": {
    "style": "friendly",
    "styleDegree": 1.2,
    "breakAfter": 300
  },
  ...
}
```

**Проверка:**
1. `flutter analyze` — JSON валиден
2. Запустить урок — голоса изменились
3. Субъективная оценка: звучит ли естественно?

---

### PHASE 4: Оценить и проставить voiceContext для lesson_subtraction.json (2 часа)

**Цель:** Для каждой сцены с диалогом проставить оптимальные настройки голоса.

#### Задача 4.1: Анализ сцен lesson_subtraction.json

**Файл:** `assets/data/lessons/lesson_subtraction.json`

| # | Персонаж | Текст (EN) | Текущий tone | Рекомендуемый voiceContext |
|---|----------|------------|--------------|---------------------------|
| 3 | orson | "Hello!!!" | friendly | `{ "style": "excited", "styleDegree": 1.3, "pitchModifier": "+5%", "breakAfter": 200 }` |
| 4 | orson | "My name is Orson." | friendly | `{ "style": "friendly", "styleDegree": 1.1, "rateModifier": 0.9 }` |
| 5 | orson | "I will show you that learning" | friendly | `{ "style": "friendly", "rateModifier": 0.9 }` |
| 6 | orson | "is not boring," | friendly | `{ "style": "friendly", "styleDegree": 0.9, "breakAfter": 100 }` |
| 7 | orson | "but exciting with me." | friendly | `{ "style": "cheerful", "styleDegree": 1.3, "pitchModifier": "+3%" }` |
| 8 | orson | "Do you want to start?" | inviting | `{ "style": "friendly", "styleDegree": 1.2, "pitchModifier": "+8%", "rateModifier": 0.95 }` |
| 9 | orson | "Subtraction is like a hide and seek game..." | mysterious | `{ "style": "whispering", "styleDegree": 1.2, "pitchModifier": "-3%", "rateModifier": 0.85, "volume": "soft" }` |
| 10 | orson | "Look, we have six apples." | clear | `{ "style": "friendly", "rateModifier": 0.88, "breakAfter": 400 }` |
| 11 | orson | "Oh no, some apples are playing hide and seek." | surprised | `{ "style": "excited", "styleDegree": 1.3, "pitchModifier": "+10%", "breakBefore": 100 }` |
| 12 | orson | "I see only four. So, two little apples must be hiding..." | thoughtful | `{ "style": "friendly", "styleDegree": 0.9, "rateModifier": 0.85, "breakBefore": 200 }` |
| 13 | orson | "Look, we've got four bananas." | calm | `{ "style": "friendly", "rateModifier": 0.9, "volume": "medium" }` |
| 14 | orson | "Now there are only two left. So, if we take away two..." | explaining | `{ "style": "friendly", "rateModifier": 0.85, "breakAfter": 500 }` |
| 15 | orson | "Let's try together." | inviting | `{ "style": "cheerful", "styleDegree": 1.2, "pitchModifier": "+5%" }` |
| 16 | merv | "Hi Orson, let's use oranges as an example..." | cheerful | `{ "style": "cheerful", "styleDegree": 1.3, "rateModifier": 0.92 }` |
| 17 | orson | "If we hide one of the four oranges, how many..." | questioning | `{ "style": "friendly", "pitchModifier": "+10%", "breakAfter": 600 }` |
| 18 | orson | "That's right, three! Great job." | enthusiastic | `{ "style": "excited", "styleDegree": 1.4, "pitchModifier": "+7%" }` |
| 19 | orson | "Ready for the next challenge? Hmm... let's go!" | playful | `{ "style": "cheerful", "styleDegree": 1.3, "pitchModifier": "+5%", "rateModifier": 1.05 }` |

#### Задача 4.2: Применить voiceContext к JSON

**Файл:** `assets/data/lessons/lesson_subtraction.json`

**Проверка:**
1. `flutter analyze` — JSON валиден
2. Запустить урок — голоса изменились
3. Субъективная оценка: звучит ли естественно?

---

### PHASE 5: Интеграция — убедиться, что AudioManager использует voiceContext (1 час)

**Цель:** Проверить, что voiceContext из Scene передаётся в AzureTtsService.

#### Задача 5.1: Проверить LessonPage

**Файл:** `lib/features/lessons/presentation/pages/lesson_page.dart`

Найти место, где вызывается `audioManager.speakDialogue()` и убедиться, что передаётся `voiceContext`:

```dart
await audioManager.speakDialogue(
  dialogue,
  character: scene.character,
  voiceContext: scene.voiceContext, // <- убедиться что это есть
);
```

#### Задача 5.2: Проверить AudioManager.speakDialogue

**Файл:** `lib/core/services/audio_manager.dart`

Убедиться, что метод `speakDialogue` принимает `DialogueVoiceContext?` и использует его при вызове Azure TTS:

```dart
Future<void> speakDialogue(
  String text, {
  required String character,
  DialogueVoiceContext? voiceContext,
}) async {
  // ... get voice profile ...

  // Use voiceContext or create from tone
  final context = voiceContext ?? DialogueVoiceContext.empty;

  await _azureTts.generateAudioWithProfile(
    text: text,
    profile: profile,
    voiceContext: context,
  );
}
```

**Проверка:**
1. Добавить `debugPrint` в AudioManager для логирования voiceContext
2. Запустить урок и проверить логи

---

### PHASE 6: Тестирование (2 часа)

#### Задача 6.1: Unit тесты для новых DialogueVoiceContext factory

**Файл:** `test/unit/features/lessons/domain/entities/dialogue_voice_context_test.dart` (новый)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:elli_friends_app/features/lessons/domain/entities/dialogue_voice_context.dart';

void main() {
  group('DialogueVoiceContext Factory Methods', () {
    test('clear() creates correct context', () {
      final context = DialogueVoiceContext.clear();
      expect(context.style, 'friendly');
      expect(context.rateModifier, 0.92);
      expect(context.breakAfter, 300);
    });

    test('amazed() creates correct context', () {
      final context = DialogueVoiceContext.amazed();
      expect(context.style, 'excited');
      expect(context.styleDegree, 1.4);
      expect(context.pitchModifier, '+8%');
    });

    test('counting() creates correct context for slow counting', () {
      final context = DialogueVoiceContext.counting();
      expect(context.style, 'cheerful');
      expect(context.rateModifier, lessThan(1.0)); // slower
      expect(context.breakAfter, isNotNull); // has pause
    });

    test('fromTone() maps all new tones correctly', () {
      final tones = [
        'clear', 'amazed', 'counting', 'enthusiastic', 'proud',
        'grateful', 'mysterious', 'inviting', 'surprised',
        'thoughtful', 'explaining', 'playful',
      ];

      for (final tone in tones) {
        final context = DialogueVoiceContext.fromTone(tone);
        expect(context.hasContext, true, reason: 'Tone "$tone" should create context');
      }
    });
  });

  group('DialogueVoiceContext Serialization', () {
    test('toJson/fromJson roundtrip', () {
      final original = DialogueVoiceContext.enthusiastic();
      final json = original.toJson();
      final restored = DialogueVoiceContext.fromJson(json);

      expect(restored.style, original.style);
      expect(restored.styleDegree, original.styleDegree);
      expect(restored.pitchModifier, original.pitchModifier);
      expect(restored.rateModifier, original.rateModifier);
    });
  });
}
```

**Команда:** `flutter test test/unit/features/lessons/domain/entities/dialogue_voice_context_test.dart`

#### Задача 6.2: Интеграционное тестирование (ручное)

**Чек-лист для Counting урока:**

- [ ] Запустить `flutter run -d chrome`
- [ ] Открыть урок "Counting as a Game of Friends"
- [ ] Прослушать все сцены с диалогами
- [ ] Оценить по шкале 1-5:
  - [ ] Голоса Orson и Merv различаются? (1=одинаковые, 5=явно разные)
  - [ ] Эмоции слышны? (1=монотонно, 5=выразительно)
  - [ ] Скорость подходит детям? (1=слишком быстро, 5=идеально)
  - [ ] Паузы естественные? (1=рваные, 5=плавные)
- [ ] Записать проблемные сцены для доработки

**Чек-лист для Subtraction урока:**

- [ ] Открыть урок "Subtraction as Hide and Seek"
- [ ] Прослушать все сцены с диалогами
- [ ] Оценить по той же шкале
- [ ] Особое внимание на:
  - [ ] "mysterious" тон — звучит ли загадочно?
  - [ ] "surprised" тон — слышно ли удивление?
  - [ ] "explaining" тон — понятно ли объяснение?

---

### PHASE 7: Финальная проверка и документация (30 мин)

#### Задача 7.1: Проверить все языки

Для EN, RU, DE (языки со стилями):
1. Переключить язык в настройках
2. Запустить оба урока
3. Убедиться, что стили применяются

Для AM, MY (языки без стилей):
1. Переключить язык
2. Убедиться, что rate/pitch применяются
3. Style игнорируется (fallback на базовые настройки)

#### Задача 7.2: Обновить документацию

**Файл:** `.claude/CHARACTERS_VOICE_SETTINGS.md`

Добавить секцию "Voice Context по сценам":
- Описание принципов выбора тонов
- Рекомендации для будущих уроков

---

## Порядок выполнения

| # | Фаза | Задачи | Оценка времени | Зависимости |
|---|------|--------|----------------|-------------|
| 1 | Phase 1 | 1.1 | 1 час | - |
| 2 | Phase 2 | 2.1 | 30 мин | Phase 1 |
| 3 | Phase 3 | 3.1, 3.2 | 2 часа | Phase 1, 2 |
| 4 | Phase 4 | 4.1, 4.2 | 2 часа | Phase 1, 2 |
| 5 | Phase 5 | 5.1, 5.2 | 1 час | Phase 3, 4 |
| 6 | Phase 6 | 6.1, 6.2 | 2 часа | Phase 5 |
| 7 | Phase 7 | 7.1, 7.2 | 30 мин | Phase 6 |

**Общее время:** ~9 часов

---

## Файлы для изменения

| # | Файл | Изменение | Приоритет |
|---|------|-----------|-----------|
| 1 | `lib/features/lessons/domain/entities/dialogue_voice_context.dart` | Добавить 12 новых factory методов, обновить fromTone | HIGH |
| 2 | `lib/features/lessons/data/models/scene_model.dart` | Убедиться в парсинге voiceContext | MEDIUM |
| 3 | `assets/data/lessons/lesson_counting.json` | Добавить voiceContext к 18 сценам | HIGH |
| 4 | `assets/data/lessons/lesson_subtraction.json` | Добавить voiceContext к 17 сценам | HIGH |
| 5 | `lib/features/lessons/presentation/pages/lesson_page.dart` | Убедиться в передаче voiceContext | MEDIUM |
| 6 | `lib/core/services/audio_manager.dart` | Убедиться в использовании voiceContext | MEDIUM |
| 7 | `test/unit/.../dialogue_voice_context_test.dart` | Новые unit тесты | LOW |
| 8 | `.claude/CHARACTERS_VOICE_SETTINGS.md` | Документация | LOW |

---

## Критерии приёмки

- [x] Все 12 новых factory методов DialogueVoiceContext созданы ✅ (2025-11-26)
- [x] fromTone() маппит все тоны из уроков ✅ (2025-11-26)
- [ ] lesson_counting.json содержит voiceContext для всех сцен с диалогами
- [ ] lesson_subtraction.json содержит voiceContext для всех сцен с диалогами
- [ ] При воспроизведении урока голоса звучат эмоционально и разнообразно
- [ ] Orson и Merv чётко различаются по голосу
- [ ] Скорость речи подходит для детей 5-7 лет (rate 0.75-1.0)
- [ ] Unit тесты проходят
- [ ] Ручное тестирование для EN и RU языков пройдено

---

## Примечания

### Рекомендации по настройке голоса для детей:

1. **Скорость (rate):**
   - Нормальная речь: 0.88-0.95
   - Счёт чисел: 0.75-0.82
   - Вопросы: 0.90-0.95
   - Восторг: 1.0-1.1

2. **Pitch:**
   - Merv (женский): +5% базово, до +13% для восторга
   - Orson (мужской): 0% базово, до +10% для вопросов

3. **Паузы (breaks):**
   - После вопроса: 400-600ms (время подумать)
   - После объяснения: 300-500ms (время усвоить)
   - Между числами при счёте: 200ms

4. **Стили:**
   - Для счёта/чисел: cheerful (бодрый)
   - Для вопросов: friendly + повышенный pitch
   - Для похвалы: excited (возбуждённый)
   - Для объяснений: friendly + медленный rate

---

## История изменений

### 2025-11-26: PHASE 1 выполнен

**Что сделано:**
1. Добавлены все 12 новых factory методов в `DialogueVoiceContext`:
   - `clear()` — для чёткой, объяснительной речи
   - `amazed()` — для удивления/восторга
   - `counting()` — для медленного счёта чисел
   - `enthusiastic()` — для похвалы и восторга
   - `proud()` — для гордости за ребёнка
   - `grateful()` — для благодарности
   - `mysterious()` — для загадочной речи
   - `inviting()` — для приглашения/вопроса
   - `surprised()` — для удивления
   - `thoughtful()` — для задумчивой речи
   - `explaining()` — для пошагового объяснения
   - `playful()` — для игривой речи

2. Обновлён метод `fromTone()` — теперь он корректно маппит все тоны из JSON уроков:
   - `friendly` → базовый дружелюбный стиль
   - `cheerful`/`happy` → радостный стиль
   - `excited` → возбуждённый стиль
   - `questioning` → вопросительный тон
   - `clear`/`explaining` → объяснительный режим
   - `counting` → медленный счёт
   - `enthusiastic`/`proud` → похвала
   - `mysterious` → загадочный шёпот
   - `inviting` → приглашение
   - `surprised`/`amazed` → удивление
   - `thoughtful`/`calm` → задумчивость
   - `playful` → игривость
   - `grateful` → благодарность

3. Проверена интеграция:
   - `LessonPage._playScene()` передаёт `tone` в `AudioManager`
   - `AudioManager.speakDialogue()` создаёт `DialogueVoiceContext.fromTone(tone)`
   - `AudioManager._speakWithAzureTts()` использует context для генерации SSML
   - Оба урока используют tone и работают корректно

**Файлы изменены:**
- `lib/features/lessons/domain/entities/dialogue_voice_context.dart` — добавлены factory методы и fromTone

---

## Руководство для пользователей

### Как использовать tone в JSON уроках

Просто укажите поле `tone` в сцене с диалогом:

```json
{
  "character": "orson",
  "dialogue": {
    "en": "Hello, I'm Orson!",
    "ru": "Привет, я Орсон!"
  },
  "tone": "friendly"
}
```

### Доступные значения tone

| Tone | Описание | Когда использовать |
|------|----------|-------------------|
| `friendly` | Дружелюбный, нейтральный | Приветствия, общение |
| `cheerful`/`happy` | Радостный | Когда персонаж радуется |
| `excited` | Возбуждённый, восторженный | Яркие эмоции |
| `questioning` | Вопросительный | Вопросы к ребёнку |
| `clear` | Чёткий, понятный | Объяснения концепций |
| `counting` | Медленный, чёткий | Когда считаем числа |
| `enthusiastic` | Восторженный, похвала | "Правильно! Молодец!" |
| `proud` | Гордость | Похвала за достижение |
| `grateful` | Благодарность | "Спасибо!" |
| `mysterious` | Загадочный, шёпот | Интересные факты |
| `inviting` | Приглашающий | "Хочешь попробовать?" |
| `surprised` | Удивлённый | "Ого! Вот это да!" |
| `amazed` | Поражённый | Сильное удивление |
| `thoughtful` | Задумчивый | Размышления |
| `explaining` | Объяснительный | Пошаговые инструкции |
| `playful` | Игривый | Шутки и игры |
| `calm` | Спокойный | Успокаивающая речь |

### Как это работает

1. JSON файл урока содержит `tone` для каждой сцены
2. При воспроизведении `LessonPage` передаёт tone в `AudioManager`
3. `AudioManager` вызывает `DialogueVoiceContext.fromTone(tone)`
4. Создаётся объект с настройками голоса (style, pitch, rate, breaks)
5. Azure TTS генерирует аудио с этими параметрами

### Пример: как звучат разные тоны

```
"friendly" → Стандартная речь, дружелюбный тон
"counting" → Медленно (0.80x), паузы между числами
"excited" → Быстрее (1.1x), выше тон (+5%), яркий стиль
"questioning" → Тон выше (+10%), пауза после (500ms)
"mysterious" → Шёпот, ниже тон (-3%), тихо, медленно (0.85x)
```

---

## Ссылки

- [DialogueVoiceContext](lib/features/lessons/domain/entities/dialogue_voice_context.dart)
- [CharacterVoiceProfile](lib/features/lessons/domain/entities/character_voice_profile.dart)
- [AzureTtsReference](lib/core/services/azure_tts_reference.dart)
- [lesson_counting.json](assets/data/lessons/lesson_counting.json)
- [lesson_subtraction.json](assets/data/lessons/lesson_subtraction.json)
