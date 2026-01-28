# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Elli & Friends is a Flutter educational app for children (3-7 years). It features interactive animated lessons with animal characters, NOT pre-recorded videos. Lessons render in real-time using Flutter widgets with TTS voice narration.

## Build & Run Commands

```bash
# Run app
flutter run -d chrome          # Web
flutter run -d macos           # macOS
flutter run -d ios             # iOS simulator
./run_web.sh                   # Web with setup script

# Build
flutter build web
flutter build apk
flutter build ios

# Code quality
flutter analyze                # Lint
dart format lib/               # Format
flutter test                   # All tests
flutter test path/to/test.dart # Single test
flutter test --coverage        # Coverage report

# Code generation
flutter gen-l10n               # Localization
dart run build_runner build    # Drift database
dart bin/generate_audio.dart   # Pre-generate TTS audio
```

## Architecture

**Clean Architecture + BLoC Pattern** with 3 layers:

```
Presentation (UI, Widgets, BLoC)
       ↓ ↑
Domain (Entities, UseCases, Repository Interfaces)
       ↓ ↑
Data (Models, Repository Impl, DataSources)
```

### Key Features Structure (`lib/features/`)
- **home/** - Main screen with Elli character
- **lessons/** - Interactive lesson player with scene progression
- **games/** - Mini-games (counting, subtraction)
- **editor/** - Lesson editor UI
- **settings/** - Audio settings, TTS test page
- **demo/** - Character/voice testing

### Core Services (`lib/core/services/`)
- **AudioManager** (Singleton) - Centralized audio: TTS, SFX, music, animal sounds with auto-ducking
- **LocaleService** - Language management (6 languages: en, ru, fr, de, it, my)
- **AudioCachingService** - Pre-generated Azure TTS audio

### Database
Uses **Drift** (type-safe SQLite) with tables: Characters, Lessons, Scenes. SeedService loads from JSON assets.

### Routes (GoRouter)
- `/` - Home
- `/lesson/:lessonId` - Lesson player
- `/game/:gameId` - Game
- `/settings`, `/tts-test`, `/mascots-demo`, `/editor`

## Key Technologies

| Package | Purpose |
|---------|---------|
| flutter_bloc | State management (BLoC pattern) |
| go_router | Navigation |
| rive (0.14.0-dev.14) | Character animations (Runtime v7, NOT v9) |
| drift | Type-safe SQLite database |
| flutter_tts | Text-to-Speech |
| audioplayers | Audio playback |

## Character Animation System

Characters use Rive animations (.riv files in `assets/animations/`):
- **Elli** - Friendly elephant, home screen guide
- **Orson** - Wise lion teacher for lessons
- **Bono** - Elephant helper
- **Hippo** - Curious hippo

## Voice System (Two-Level)

1. **CharacterVoiceProfile** - Base voice settings per character per language
2. **DialogueVoiceContext** - Emotional modifiers per phrase (style, pitch, rate)

Supports Azure TTS (high-quality) with flutter_tts fallback.

## Lesson Data Format

Lessons are JSON files in `assets/data/lessons/` with multi-language support:
```json
{
  "id": "lesson_counting",
  "title": {"en": "Counting", "ru": "Счёт"},
  "scenes": [
    {
      "character": "orson",
      "dialogue": {"en": "Hello!", "ru": "Привет!"},
      "showAnimals": [{"type": "butterfly", "emoji": "🦋", "count": 1}],
      "isQuestion": true
    }
  ]
}
```

## UI Guidelines for Children

- Large touch targets (minimum 60x60 dp)
- Rounded corners (BorderRadius.circular(24))
- Big fonts (minimum 18sp body text)
- Clear visual feedback on interactions

## Testing

```
test/
├── unit/
│   ├── core/database/     # Repository tests
│   └── features/*/bloc/   # BLoC tests (use bloc_test)
├── widget/                # Widget tests
└── integration/           # E2E tests
```

Use `mocktail` for mocking dependencies.

## Important Notes

- This is NOT a video app - lessons render in real-time
- Rive version is 0.14.0-dev.14 (Runtime v7), not the latest
- App should work offline-first
- Always use BLoC for state management, not setState for complex state
- Dispose resources properly (controllers, audio)
- Use const constructors to reduce rebuilds

## Existing Documentation

- `SYSTEM_PROMPT.md` - Comprehensive development guidelines
- `.claude/ARCHITECTURE.md` - Detailed architecture (Russian)
- `.claude/README.md` - Quick start guide
- `docs/TROUBLESHOOTING.md` - TTS and platform-specific issues