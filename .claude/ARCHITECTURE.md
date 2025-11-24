# Elli & Friends - Архитектура приложения

## ОБЗОР ПРОЕКТА

### Общая информация
- **Название:** Elli & Friends (Элли и друзья)
- **Тип:** Образовательное мобильное приложение
- **Целевая аудитория:** Дети 3-7 лет
- **Темы обучения:** Счёт, вычитание, буквы, формы, цвета
- **Платформы:** iOS, Android, Web, macOS, Windows, Linux
- **Языки интерфейса:** 6 языков (English, Russian, French, German, Italian, Burmese)

### Ключевая концепция
**НЕ видео-приложение!** Вместо предзаписанных видео создаём **интерактивные анимированные уроки**, где:
- Диалоги персонажей отрисовываются в реальном времени
- Дети могут взаимодействовать во время урока
- Уроки описаны в JSON файлах (легко редактировать и локализовать)
- Анимации персонажей — Rive файлы с поддержкой эмоций и действий
- Голоса персонажей — Text-to-Speech (можно заменить на записи позже)

---

## АРХИТЕКТУРА

### Паттерн: Clean Architecture + BLoC

```
┌─────────────────────────────────────────┐
│       PRESENTATION LAYER                │
│  (UI, Widgets, BLoC, Screens, Pages)   │
└─────────────────────────────────────────┘
              ↓ ↑
┌─────────────────────────────────────────┐
│         DOMAIN LAYER                    │
│  (Entities, UseCases, Repositories)    │
└─────────────────────────────────────────┘
              ↓ ↑
┌─────────────────────────────────────────┐
│          DATA LAYER                     │
│  (Models, Repository Impl, DataSources)│
└─────────────────────────────────────────┘
```

### Принципы:
- **Separation of Concerns** — каждый слой отвечает за своё
- **Dependency Inversion** — внутренние слои не зависят от внешних
- **Single Responsibility** — один класс = одна ответственность
- **Testability** — легко писать unit и widget тесты

---

## СТРУКТУРА ПРОЕКТА

```
elli_friends_app/
│
├── lib/
│   ├── main.dart                          # Точка входа
│   │
│   ├── core/                              # Общие компоненты
│   │   ├── constants/
│   │   │   ├── app_colors.dart           # Цветовая палитра
│   │   │   ├── app_dimensions.dart       # Размеры и отступы
│   │   │   ├── app_assets.dart           # Пути к ассетам
│   │   │   └── supported_languages.dart  # Конфигурация языков
│   │   ├── theme/
│   │   │   ├── app_theme.dart            # Тема приложения (MD3)
│   │   │   └── app_text_styles.dart      # Стили текста
│   │   ├── router/
│   │   │   └── app_router.dart           # Навигация (GoRouter)
│   │   ├── services/
│   │   │   ├── audio_manager.dart        # Управление звуком и TTS
│   │   │   ├── locale_service.dart       # Управление локализацией
│   │   │   └── language_service.dart     # Сервис языковых настроек
│   │   └── utils/
│   │       └── tts_diagnostics.dart      # Диагностика TTS
│   │
│   ├── features/                          # Функциональные модули
│   │   │
│   │   ├── home/                          # Главный экран
│   │   │   ├── presentation/
│   │   │   │   ├── pages/
│   │   │   │   │   └── home_page.dart
│   │   │   │   ├── screens/
│   │   │   │   │   └── home_screen.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── character_widget.dart
│   │   │   │   │   ├── animated_character_widget.dart
│   │   │   │   │   ├── activity_button.dart
│   │   │   │   │   └── activity_card.dart
│   │   │   │   └── bloc/
│   │   │   │       ├── home_bloc.dart
│   │   │   │       ├── home_event.dart
│   │   │   │       └── home_state.dart
│   │   │   └── domain/
│   │   │       └── entities/
│   │   │           └── activity.dart
│   │   │
│   │   ├── lessons/                       # Интерактивные уроки
│   │   │   ├── presentation/
│   │   │   │   ├── pages/
│   │   │   │   │   └── lesson_page.dart
│   │   │   │   ├── screens/
│   │   │   │   │   └── lesson_screen.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── scene_widget.dart
│   │   │   │   │   ├── lesson_intro_widget.dart
│   │   │   │   │   ├── answer_buttons.dart
│   │   │   │   │   ├── confetti_celebration.dart
│   │   │   │   │   ├── wrong_answer_animation.dart
│   │   │   │   │   └── animals/
│   │   │   │   │       ├── slow_turtles.dart
│   │   │   │   │       ├── playful_monkeys.dart
│   │   │   │   │       ├── singing_birds.dart
│   │   │   │   │       └── flying_butterflies.dart
│   │   │   │   └── bloc/
│   │   │   │       ├── lesson_bloc.dart
│   │   │   │       ├── lesson_event.dart
│   │   │   │       └── lesson_state.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── lesson.dart
│   │   │   │   │   ├── scene.dart
│   │   │   │   │   └── animal.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── lesson_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── get_lesson.dart
│   │   │   │       └── get_all_lessons.dart
│   │   │   └── data/
│   │   │       ├── models/
│   │   │       │   ├── lesson_model.dart
│   │   │       │   ├── scene_model.dart
│   │   │       │   └── animal_model.dart
│   │   │       ├── datasources/
│   │   │       │   └── lesson_local_datasource.dart
│   │   │       └── repositories/
│   │   │           └── lesson_repository_impl.dart
│   │   │
│   │   ├── games/                         # Мини-игры
│   │   │   ├── presentation/
│   │   │   │   ├── pages/
│   │   │   │   │   └── game_page.dart
│   │   │   │   ├── screens/
│   │   │   │   │   └── game_screen.dart
│   │   │   │   └── bloc/
│   │   │   │       ├── game_bloc.dart
│   │   │   │       ├── game_event.dart
│   │   │   │       └── game_state.dart
│   │   │   └── domain/
│   │   │       └── entities/
│   │   │           ├── game.dart
│   │   │           ├── game_config.dart
│   │   │           └── game_question.dart
│   │   │
│   │   ├── progress/                      # Прогресс (в разработке)
│   │   │   ├── domain/
│   │   │   │   └── entities/
│   │   │   │       └── user_progress.dart
│   │   │   └── data/
│   │   │
│   │   ├── settings/                      # Настройки
│   │   │   └── presentation/
│   │   │       └── pages/
│   │   │           ├── settings_page.dart
│   │   │           └── tts_test_page.dart
│   │   │
│   │   └── demo/                          # Демо персонажей
│   │       └── mascots_demo.dart
│   │
│   ├── shared/                            # Общие виджеты и анимации
│   │   ├── widgets/
│   │   │   ├── animated_character_widget.dart
│   │   │   └── animated_ellie_widget.dart
│   │   └── animations/
│   │       └── bounce_animation.dart
│   │
│   └── l10n/                              # Локализация (ARB файлы)
│       ├── app_en.arb
│       ├── app_ru.arb
│       ├── app_fr.arb
│       ├── app_de.arb
│       ├── app_it.arb
│       └── app_my.arb
│
├── assets/                                # Ресурсы
│   ├── audio/
│   │   ├── sfx/                          # Звуковые эффекты
│   │   ├── animals/                       # Звуки животных
│   │   └── music/                         # Фоновая музыка
│   ├── images/
│   │   ├── characters/                    # Изображения персонажей
│   │   ├── animals/                       # Изображения животных
│   │   └── backgrounds/                   # Фоны
│   ├── animations/                        # Rive анимации (.riv)
│   │   ├── elli.riv
│   │   ├── orson.riv
│   │   └── ...
│   └── data/
│       └── lessons/                       # JSON файлы уроков
│           ├── lesson_counting.json
│           └── lesson_subtraction.json
│
├── test/                                  # Тесты
│   ├── unit/
│   │   ├── core/
│   │   │   └── services/
│   │   └── features/
│   │       ├── home/
│   │       ├── lessons/
│   │       └── games/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml
└── l10n.yaml                              # Конфигурация локализации
```

---

## ТЕХНОЛОГИЧЕСКИЙ СТЕК

### Основные зависимости

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # Управление состоянием
  flutter_bloc: ^8.1.3              # BLoC паттерн
  equatable: ^2.0.5                  # Сравнение объектов

  # Навигация
  go_router: ^12.0.0                 # Декларативная навигация с MD3

  # Хранение данных
  shared_preferences: ^2.2.2         # Key-value хранилище

  # Аудио и TTS
  audioplayers: ^5.2.1               # Звуковые эффекты и музыка
  flutter_tts: ^3.8.3                # Text-to-Speech

  # UI и анимации
  flutter_svg: ^2.0.9                # SVG иконки
  rive: 0.14.0-dev.14                # Rive анимации (Runtime v7)

  # Локализация
  intl: ^0.20.2                      # Интернационализация

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0              # Линтер
  bloc_test: ^9.1.5                  # Тестирование BLoC
  mocktail: ^1.0.1                   # Моки для тестов
```

---

## ПЕРСОНАЖИ

### Основные персонажи с Rive анимациями

| Персонаж | Описание | Файл анимации |
|----------|----------|---------------|
| **Elli** | Дружелюбный слон, главный проводник на главном экране | `elli.riv` |
| **Orson** | Мудрый лев-учитель для уроков | `orson.riv` |
| **Bono** | Слон-помощник | `bono.riv` |
| **Hippo** | Любопытный бегемот | `hippo.riv` |

### Эмоции персонажей (Rive States)
- `idle` — спокойное состояние
- `happy` — радость
- `thinking` — размышление
- `excited` — восторг
- `surprised` — удивление

---

## МОДЕЛИ ДАННЫХ

### Lesson (Урок)

```dart
class Lesson extends Equatable {
  final String id;
  final String title;
  final String topic;              // "counting", "subtraction", "alphabet"
  final String description;
  final int difficulty;            // 1-5
  final List<Scene> scenes;
  final List<String> tags;
}
```

### Scene (Сцена урока)

```dart
class Scene extends Equatable {
  final String? character;         // "orson", "elli", null
  final String? dialogue;          // Текст для TTS
  final int? duration;             // Длительность в секундах
  final String? emotion;           // "happy", "thinking", etc.
  final String? riveAnimation;     // Название анимации в Rive
  final List<Animal> animals;      // Животные на экране
  final bool isQuestion;           // Это вопрос?
  final int? correctAnswer;        // Правильный ответ
  final List<AnswerOption>? answerOptions;  // Варианты ответов
  final String transitionTrigger;  // "auto_tts", "button", "task", "auto_timer"
}
```

### Animal (Животное)

```dart
class Animal extends Equatable {
  final String type;               // "butterfly", "turtle", "monkey"
  final String emoji;              // "🦋", "🐢", "🐵"
  final int count;                 // Количество
}
```

### Game (Игра)

```dart
class Game extends Equatable {
  final String id;
  final String title;
  final String type;               // "counting", "subtraction"
  final int difficulty;
  final GameConfig config;
}

class GameConfig extends Equatable {
  final int minNumber;
  final int maxNumber;
  final int questionsCount;
  final int? timeLimit;
}
```

---

## ФОРМАТ УРОКА (JSON)

```json
{
  "id": "lesson_counting",
  "title": {
    "en": "Counting as a Game of Friends",
    "ru": "Счёт как игра с друзьями",
    "fr": "Compter comme un jeu d'amis"
  },
  "topic": "counting",
  "description": {
    "en": "Learn to count from 1 to 5",
    "ru": "Учимся считать от 1 до 5"
  },
  "difficulty": 1,
  "scenes": [
    {
      "character": "orson",
      "dialogue": {
        "en": "Hello, I'm Orson! Let's learn to count!",
        "ru": "Привет, я Орсон! Давай научимся считать!"
      },
      "emotion": "happy",
      "rive_animation": "wave",
      "transition_trigger": "auto_tts"
    },
    {
      "character": "orson",
      "dialogue": {
        "en": "How many butterflies do you see?",
        "ru": "Сколько бабочек ты видишь?"
      },
      "emotion": "thinking",
      "animals": [
        {"type": "butterfly", "emoji": "🦋", "count": 3}
      ],
      "is_question": true,
      "correct_answer": 3,
      "answer_options": [
        {"value": 1, "label": {"en": "1", "ru": "1"}},
        {"value": 2, "label": {"en": "2", "ru": "2"}},
        {"value": 3, "label": {"en": "3", "ru": "3"}}
      ],
      "transition_trigger": "task"
    }
  ]
}
```

---

## АУДИО СИСТЕМА

### AudioManager (Singleton)

Централизованный сервис для управления звуком:

- **Text-to-Speech** для диалогов
  - Разные настройки pitch/rate для персонажей
  - Поддержка 6 языков
- **Звуковые эффекты** (correct, wrong, click, star, success)
- **Звуки животных** (butterfly, monkey, bird, turtle, frog)
- **Фоновая музыка** с auto-loop
- **Автоприглушение музыки** при диалоге (ducking)

```dart
final audio = AudioManager();

// TTS с настройками персонажа
await audio.speak("Привет!", character: "orson");

// Звуковые эффекты
await audio.playSfx(SoundEffect.correct);

// Фоновая музыка
await audio.playBackgroundMusic('jungle_ambient');
```

---

## ЛОКАЛИЗАЦИЯ

### Поддерживаемые языки (6)

| Код | Язык | TTS код |
|-----|------|---------|
| en | English | en-US |
| ru | Русский | ru-RU |
| fr | Français | fr-FR |
| de | Deutsch | de-DE |
| it | Italiano | it-IT |
| my | မြန်မာ (Burmese) | my-MM |

### Архитектура локализации

1. **UI строки** — ARB файлы в `lib/l10n/`
2. **Контент уроков** — встроенная локализация в JSON
3. **LocaleService** — глобальный сервис для управления языком
4. **Автоопределение** — использует язык устройства если поддерживается

---

## НАВИГАЦИЯ

### GoRouter с MD3

```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => HomePage()),
    GoRoute(path: '/lesson/:lessonId', builder: (_, state) =>
        LessonPage(lessonId: state.pathParameters['lessonId']!)),
    GoRoute(path: '/game/:gameId', builder: (_, state) =>
        GamePage(gameId: state.pathParameters['gameId']!)),
    GoRoute(path: '/settings', builder: (_, __) => SettingsPage()),
  ],
);
```

---

## ТЕСТИРОВАНИЕ

### Структура тестов

```
test/
├── unit/                              # Unit тесты
│   ├── features/
│   │   ├── home/presentation/bloc/    # HomeBloc тесты
│   │   ├── lessons/
│   │   │   ├── data/datasources/      # DataSource тесты
│   │   │   ├── data/models/           # Model тесты
│   │   │   ├── data/repositories/     # Repository тесты
│   │   │   ├── domain/usecases/       # UseCase тесты
│   │   │   └── presentation/bloc/     # LessonBloc тесты
│   │   └── games/presentation/bloc/   # GameBloc тесты
│   └── core/
├── widget/                            # Widget тесты
└── integration/                       # E2E тесты
```

### Запуск тестов

```bash
# Все тесты
flutter test

# Конкретный файл
flutter test test/unit/features/home/presentation/bloc/home_bloc_test.dart

# С coverage
flutter test --coverage
```

---

## ДИЗАЙН СИСТЕМА

### Цветовая палитра

```dart
class AppColors {
  // Основные цвета
  static const primary = Color(0xFF4A90E2);      // Синий
  static const secondary = Color(0xFFFFA726);    // Оранжевый
  static const accent = Color(0xFF66BB6A);       // Зелёный

  // Цвета персонажей
  static const elliBg = Color(0xFFFFF9C4);       // Жёлтый
  static const bonoBg = Color(0xFFE3F2FD);       // Голубой
  static const hippoBg = Color(0xFFF3E5F5);      // Фиолетовый

  // Обратная связь
  static const correct = Color(0xFF4CAF50);      // Зелёный
  static const incorrect = Color(0xFFFF9800);    // Оранжевый
}
```

### Material Design 3

- `useMaterial3: true` в теме
- MD3 Navigation
- Rounded corners (BorderRadius.circular(24))
- Large touch targets (минимум 60x60)

---

## RIVE АНИМАЦИИ

### Интеграция

- **Версия:** Rive 0.14.0-dev.14 (Runtime v7)
- **Файлы:** `assets/animations/*.riv`
- **Виджеты:** `AnimatedCharacterWidget`, `AnimatedEllieWidget`

### Использование

```dart
AnimatedCharacterWidget(
  character: 'orson',
  emotion: 'happy',
  onTap: () => print('Character tapped!'),
)
```

---

## ПОТЕНЦИАЛЬНЫЕ УЛУЧШЕНИЯ

- [ ] **Dependency Injection** — добавить get_it для лучшего управления зависимостями
- [ ] **State Persistence** — сохранение прогресса уроков в базу данных
- [ ] **Remote Data** — поддержка загрузки уроков с сервера
- [ ] **Analytics** — добавить телеметрию и аналитику
- [ ] **Integration Tests** — больше E2E тестов
- [ ] **Caching** — кэширование уроков
- [ ] **Voice Input** — распознавание речи для ответов

---

## ПОЛЕЗНЫЕ КОМАНДЫ

```bash
# Запуск приложения
flutter run -d chrome          # Web
flutter run -d macos           # macOS
flutter run                    # Default device

# Генерация локализации
flutter gen-l10n

# Анализ кода
flutter analyze

# Сборка
flutter build web
flutter build apk
flutter build ios
```
