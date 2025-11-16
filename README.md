# 🐘 Elli & Friends

Educational web application for kids to learn through interactive lessons and games.

## 🌍 Multi-Language Support

Elli & Friends supports **5 languages**:
- 🇬🇧 **English** (en)
- 🇫🇷 **French** (Français - fr)
- 🇩🇪 **German** (Deutsch - de)
- 🇮🇹 **Italian** (Italiano - it)
- 🇲🇲 **Burmese** (မြန်မာ - my)

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.35.7 or higher
- Chrome browser for web development

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

3. Run on web:
```bash
flutter run -d chrome
```

## 📁 Project Structure

```
lib/
├── main.dart                          # Main entry point (simplified version)
├── main_with_l10n.dart               # Full version with generated l10n
├── core/
│   ├── constants/
│   │   └── supported_languages.dart   # Language configuration
│   └── services/
│       ├── audio_manager.dart         # Audio & TTS management
│       └── language_service.dart      # Language preferences
└── l10n/                              # Localization files
    ├── app_en.arb
    ├── app_fr.arb
    ├── app_de.arb
    ├── app_it.arb
    └── app_my.arb

assets/
└── data/
    └── lessons/                       # Lesson content
        ├── en/
        ├── fr/
        ├── de/
        ├── it/
        └── my/
```

## 🎮 Features

- 🌐 **Multi-language interface** - Switch between 5 languages on the fly
- 🔊 **Text-to-Speech** - Voice narration in all supported languages
- 📚 **Interactive Lessons** - Educational content for kids
- 🎨 **Colorful UI** - Child-friendly design
- 💾 **Progress Tracking** - Save and restore language preferences

## 🛠️ Development

### Build for Web
```bash
flutter build web
```

### Test Different Languages
The app automatically detects your system language or lets you choose from the settings menu.

## 📝 Adding a New Language

1. Create new ARB file:
```bash
lib/l10n/app_es.arb  # For Spanish
```

2. Add locale to [supported_languages.dart](/Users/User/Development/elli_friends_app/lib/core/constants/supported_languages.dart)

3. Create lesson files:
```bash
mkdir assets/data/lessons/es
```

4. Update [pubspec.yaml](/Users/User/Development/elli_friends_app/pubspec.yaml) assets section

## 🐛 Known Issues

- Localization generation requires running the app first (files are generated automatically)
- Some TTS features are iOS-only (gracefully handled on web)

## 📄 License

MIT License - feel free to use for educational purposes

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

Made with ❤️ for kids learning around the world
