# Elli & Friends

Educational mobile application for kids to learn through interactive lessons and games with animated characters.

## Multi-Language Support

Elli & Friends supports **6 languages**:
- English (en)
- Русский (ru)
- Français (fr)
- Deutsch (de)
- Italiano (it)
- မြန်မာ - Burmese (my)

## Quick Start

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2+
- Chrome browser for web development
- Xcode for iOS/macOS development (optional)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/MaxShytov/elli-friends-app.git
cd elli-friends-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate localization files:
```bash
flutter gen-l10n
```

4. Run the app:
```bash
# Web
flutter run -d chrome

# macOS
flutter run -d macos

# iOS Simulator
flutter run -d ios
```

## Project Structure

```
lib/
├── main.dart                          # Main entry point
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           # Color palette
│   │   ├── app_dimensions.dart       # Sizes and spacing
│   │   ├── app_assets.dart           # Asset paths
│   │   └── supported_languages.dart  # Language configuration
│   ├── theme/
│   │   ├── app_theme.dart            # App theme (MD3)
│   │   └── app_text_styles.dart      # Text styles
│   ├── router/
│   │   └── app_router.dart           # Navigation (GoRouter)
│   └── services/
│       ├── audio_manager.dart        # Audio & TTS management
│       ├── locale_service.dart       # Locale management
│       └── language_service.dart     # Language preferences
├── features/
│   ├── home/                         # Home screen with Elli
│   ├── lessons/                      # Interactive lessons
│   ├── games/                        # Mini-games
│   ├── settings/                     # Settings & TTS test
│   ├── progress/                     # Progress tracking
│   └── demo/                         # Mascots demo page
├── shared/
│   ├── widgets/                      # Reusable widgets
│   │   ├── animated_character_widget.dart
│   │   └── animated_ellie_widget.dart
│   └── animations/                   # Shared animations
└── l10n/                             # Localization ARB files
    ├── app_en.arb
    ├── app_ru.arb
    ├── app_fr.arb
    ├── app_de.arb
    ├── app_it.arb
    └── app_my.arb

assets/
├── audio/
│   ├── sfx/                          # Sound effects
│   ├── animals/                      # Animal sounds
│   └── music/                        # Background music
├── images/
│   ├── characters/                   # Character images
│   ├── animals/                      # Animal images
│   └── backgrounds/                  # Background images
├── animations/                       # Rive animation files (.riv)
│   ├── elli.riv
│   ├── orson.riv
│   └── ...
└── data/
    └── lessons/                      # Lesson JSON files
        ├── lesson_counting.json
        └── lesson_subtraction.json

test/
├── unit/                             # Unit tests
│   ├── core/
│   └── features/
│       ├── home/
│       ├── lessons/
│       └── games/
├── widget/                           # Widget tests
└── integration/                      # E2E tests
```

## Features

- **Multi-language interface** — Switch between 6 languages on the fly
- **Text-to-Speech** — Voice narration in all supported languages
- **Interactive Lessons** — Educational content with animated characters
- **Mini-games** — Counting and subtraction games
- **Rive Animations** — Smooth character animations with emotions
- **Progress Tracking** — Save learning progress
- **Child-friendly UI** — Large touch targets, colorful design

## Characters

| Character | Role | Animation File |
|-----------|------|----------------|
| **Elli** | Friendly elephant, main guide on home screen | `elli.riv` |
| **Orson** | Wise lion teacher for lessons | `orson.riv` |
| **Bono** | Elephant helper | `bono.riv` |
| **Hippo** | Curious hippo | `hippo.riv` |

## Architecture

The app follows **Clean Architecture** with **BLoC** pattern:

```
Presentation Layer (UI, Widgets, BLoC)
        ↓ ↑
Domain Layer (Entities, UseCases, Repositories)
        ↓ ↑
Data Layer (Models, Repository Impl, DataSources)
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture documentation.

## Development

### Build Commands

```bash
# Run on web
flutter run -d chrome

# Run on macOS
flutter run -d macos

# Build for web
flutter build web

# Build for iOS
flutter build ios

# Build for Android
flutter build apk
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/features/home/presentation/bloc/home_bloc_test.dart

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Generate localization
flutter gen-l10n
```

## Adding a New Language

1. Create new ARB file:
```bash
# Example for Spanish
touch lib/l10n/app_es.arb
```

2. Add translations to the ARB file (copy structure from `app_en.arb`)

3. Add locale to [supported_languages.dart](lib/core/constants/supported_languages.dart):
```dart
static const spanish = SupportedLanguage(
  locale: Locale('es'),
  name: 'Español',
  nativeName: 'Español',
  ttsLocale: 'es-ES',
);
```

4. Add lesson translations to JSON files in `assets/data/lessons/`

5. Regenerate localization:
```bash
flutter gen-l10n
```

## Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_bloc | ^8.1.3 | State management |
| go_router | ^12.0.0 | Navigation |
| audioplayers | ^5.2.1 | Audio playback |
| flutter_tts | ^3.8.3 | Text-to-Speech |
| rive | 0.14.0-dev.14 | Character animations |
| shared_preferences | ^2.2.2 | Local storage |
| equatable | ^2.0.5 | Value equality |

## Documentation

- [Architecture](ARCHITECTURE.md) — App architecture and design patterns
- [System Prompt](../SYSTEM_PROMPT.md) — Development guidelines
- [Troubleshooting](../docs/TROUBLESHOOTING.md) — Common issues and solutions
- [Sprint Summaries](../docs/sprints/) — Development sprint archives

## Troubleshooting

See [docs/TROUBLESHOOTING.md](../docs/TROUBLESHOOTING.md) for:
- TTS (Text-to-Speech) issues
- Multi-language support
- Web platform specifics
- Xcode setup for macOS
- Rive animation issues

## License

MIT License — feel free to use for educational purposes

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

Made with love for kids learning around the world
