# Архитектура Counting Game

## Обзор

Counting Game реализована по Clean Architecture с использованием BLoC паттерна.

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌────────────────────┐         ┌─────────────────────┐    │
│  │   GamePage (UI)    │◄────────│    GameBloc         │    │
│  │                    │         │  (State Management) │    │
│  │  - Progress bar    │         │                     │    │
│  │  - Animal display  │         │  Events:            │    │
│  │  - Answer buttons  │         │  - StartGame        │    │
│  │  - Feedback screen │         │  - AnswerQuestion   │    │
│  │  - Result dialog   │         │  - NextQuestion     │    │
│  └────────────────────┘         │  - RestartGame      │    │
│                                  │                     │    │
│                                  │  States:            │    │
│                                  │  - GameInitial      │    │
│                                  │  - GameInProgress   │    │
│                                  │  - GameAnswered     │    │
│                                  │  - GameCompleted    │    │
│                                  └─────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ uses
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                           │
│  ┌────────────────────────────────────────────────────┐    │
│  │                   Entities                         │    │
│  │                                                    │    │
│  │  ┌──────────┐  ┌──────────────┐  ┌──────────────┐│    │
│  │  │   Game   │  │  GameConfig  │  │GameQuestion  ││    │
│  │  ├──────────┤  ├──────────────┤  ├──────────────┤│    │
│  │  │ id       │  │ minNumber    │  │ number       ││    │
│  │  │ title    │  │ maxNumber    │  │ emoji        ││    │
│  │  │ type     │  │ questionsCount│ └──────────────┘│    │
│  │  │ difficulty│ │ timeLimit    │                  │    │
│  │  │ config   │  └──────────────┘                  │    │
│  │  └──────────┘                                     │    │
│  └────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## Поток данных

### 1. Запуск игры
```
User opens GamePage
    │
    ├──> GamePage creates GameBloc
    │
    └──> GameBloc.add(StartGame)
            │
            ├──> Generate first question
            │
            └──> emit(GameInProgress)
                    │
                    └──> UI updates with question
```

### 2. Ответ на вопрос
```
User taps answer button
    │
    └──> GameBloc.add(AnswerQuestion(number))
            │
            ├──> Check if answer is correct
            │
            ├──> emit(GameAnswered)
            │       │
            │       └──> UI shows feedback (2 sec)
            │
            ├──> Update score & correctAnswers
            │
            └──> emit(GameInProgress)
                    │
                    └──> Auto: GameBloc.add(NextQuestion)
```

### 3. Переход к следующему вопросу
```
After 2 seconds delay
    │
    └──> GameBloc.add(NextQuestion)
            │
            ├──> currentQuestionIndex++
            │
            ├──> Is last question?
            │       │
            │       ├──> Yes: emit(GameCompleted)
            │       │           │
            │       │           └──> Show result dialog
            │       │
            │       └──> No: Generate new question
            │               │
            │               └──> emit(GameInProgress)
            │                       │
            │                       └──> UI updates
            └
```

### 4. Завершение игры
```
Last question answered
    │
    └──> GameBloc.add(NextQuestion)
            │
            ├──> Calculate stars
            │       │
            │       ├──> 90%+  → 3 stars
            │       ├──> 70-89% → 2 stars
            │       ├──> 50-69% → 1 star
            │       └──> <50%  → 0 stars
            │
            └──> emit(GameCompleted)
                    │
                    └──> Show dialog with:
                            - Final score
                            - Correct answers count
                            - Stars
                            - "Готово" button
                            - "Ещё раз" button
```

## State Management (BLoC)

### Events → States диаграмма

```
StartGame
    └──> GameInProgress (question 1)

AnswerQuestion
    ├──> GameAnswered (feedback)
    └──> GameInProgress (updated score)

NextQuestion
    ├──> GameInProgress (next question)
    └──> GameCompleted (if last)

RestartGame
    └──> GameInProgress (reset to question 1)
```

## Генерация вопросов

```dart
GameQuestion _generateQuestion(Game game) {
  // 1. Generate random number (1-5)
  number = Random().nextInt(maxNumber - minNumber + 1) + minNumber
  
  // 2. Pick random animal emoji
  emoji = ['🦋', '🐒', '🐦', '🐢', '🐸'][Random()]
  
  // 3. Return question
  return GameQuestion(number: number, emoji: emoji)
}
```

## Расчет результатов

### Очки
```
Правильный ответ: +10 очков
Неправильный ответ: +0 очков

Максимум очков = questions_count × 10
Пример: 5 вопросов × 10 = 50 очков
```

### Звёзды
```dart
int _calculateStars(int correct, int total) {
  percentage = (correct / total) * 100
  
  if (percentage >= 90) return 3  // ⭐⭐⭐
  if (percentage >= 70) return 2  // ⭐⭐☆
  if (percentage >= 50) return 1  // ⭐☆☆
  return 0                        // ☆☆☆
}
```

## Конфигурация игры

Текущая конфигурация (захардкожена):
```dart
Game(
  id: 'counting',
  title: 'Посчитай животных',
  type: 'counting',
  difficulty: 1,
  config: GameConfig(
    minNumber: 1,        // Минимальное число
    maxNumber: 5,        // Максимальное число
    questionsCount: 5,   // Количество вопросов
    timeLimit: 0,        // Нет ограничения по времени
  ),
)
```

В будущем это будет загружаться из JSON файлов.

## Зависимости

```yaml
dependencies:
  flutter_bloc: ^8.1.6      # State management
  equatable: ^2.0.5         # Value equality
  go_router: ^14.6.2        # Navigation

dev_dependencies:
  bloc_test: ^9.1.7         # BLoC testing
  flutter_test: SDK         # Unit testing
```

## Тестирование

```
GameBloc Tests (10 tests)
  ├── Initial state
  ├── Start game
  │   ├── Emits GameInProgress
  │   └── Generates valid question
  ├── Answer question
  │   ├── Correct answer
  │   └── Incorrect answer
  ├── Next question
  │   ├── Not last question
  │   ├── Last question → GameCompleted
  │   ├── Stars calculation (3★)
  │   └── Stars calculation (2★)
  └── Restart game
```

## Файловая структура

```
lib/features/games/
├── domain/
│   └── entities/
│       └── game.dart              # Business entities
└── presentation/
    ├── bloc/
    │   └── game_bloc.dart         # State management
    └── pages/
        └── game_page.dart         # UI

test/unit/features/games/
└── presentation/
    └── bloc/
        └── game_bloc_test.dart    # Unit tests
```

## Принципы

1. **Single Responsibility**: Каждый класс отвечает за одну задачу
2. **Separation of Concerns**: UI, логика и данные разделены
3. **Testability**: BLoC полностью покрыт тестами
4. **Immutability**: Все состояния неизменяемые (Equatable)
5. **Reactive**: UI реагирует на изменения состояния через BlocBuilder/BlocConsumer

## Будущие улучшения

1. **Data Layer**: Загрузка конфигураций из JSON
2. **Use Cases**: Бизнес-логика в отдельных use cases
3. **Repository Pattern**: Абстракция источников данных
4. **Dependency Injection**: Использование get_it или injectable
5. **Локализация**: Многоязычная поддержка
6. **Звуки**: Звуковые эффекты для правильных/неправильных ответов
7. **Анимации**: Плавные переходы и анимации животных
