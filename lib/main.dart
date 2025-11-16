// lib/main_simple.dart
// Simple version without l10n for testing

import 'package:flutter/material.dart';
import 'core/constants/supported_languages.dart';
import 'core/services/language_service.dart';
import 'core/services/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get saved language
  final savedLocale = await LanguageService.getSavedLanguage();

  // Initialize audio with saved language
  final audio = AudioManager();
  await audio.initialize(languageCode: savedLocale.languageCode);

  runApp(MyApp(initialLocale: savedLocale));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();

  // ignore: library_private_types_in_public_api
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    LanguageService.saveLanguage(locale);
    AudioManager().changeLanguage(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elli & Friends',
      locale: _locale,
      supportedLocales: SupportedLanguages.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Temporary strings map (will be replaced with generated l10n)
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'title': 'Elli & Friends',
      'welcome': 'Hello! I\'m Elli!',
      'subtitle': 'Let\'s learn together!',
      'lessons': 'Lessons',
      'games': 'Games',
      'progress': 'Progress',
      'settings': 'Settings',
      'language': 'Language',
    },
    'fr': {
      'title': 'Elli & Amis',
      'welcome': 'Bonjour! Je suis Elli!',
      'subtitle': 'Apprenons ensemble!',
      'lessons': 'Leçons',
      'games': 'Jeux',
      'progress': 'Progrès',
      'settings': 'Paramètres',
      'language': 'Langue',
    },
    'de': {
      'title': 'Elli & Freunde',
      'welcome': 'Hallo! Ich bin Elli!',
      'subtitle': 'Lass uns zusammen lernen!',
      'lessons': 'Lektionen',
      'games': 'Spiele',
      'progress': 'Fortschritt',
      'settings': 'Einstellungen',
      'language': 'Sprache',
    },
    'it': {
      'title': 'Elli & Amici',
      'welcome': 'Ciao! Sono Elli!',
      'subtitle': 'Impariamo insieme!',
      'lessons': 'Lezioni',
      'games': 'Giochi',
      'progress': 'Progressi',
      'settings': 'Impostazioni',
      'language': 'Lingua',
    },
    'my': {
      'title': 'Elli & သူငယ်ချင်းများ',
      'welcome': 'မင်္ဂလာပါ! ကျွန်တော် Elli ပါ!',
      'subtitle': 'အတူတူသင်ယူကြရအောင်!',
      'lessons': 'သင်ခန်းစာများ',
      'games': 'ဂိမ်းများ',
      'progress': 'တိုးတက်မှု',
      'settings': 'ဆက်တင်များ',
      'language': 'ဘာသာစကား',
    },
  };

  String _t(BuildContext context, String key) {
    final locale = Localizations.localeOf(context);
    return _strings[locale.languageCode]?[key] ?? _strings['en']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(context, 'title')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.pets,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                _t(context, 'welcome'),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _t(context, 'subtitle'),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.school),
                label: Text(_t(context, 'lessons')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.games),
                label: Text(_t(context, 'games')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.star),
                label: Text(_t(context, 'progress')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showLanguageDialog(context, currentLocale),
                icon: const Icon(Icons.settings),
                label: Text(_t(context, 'settings')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      _t(context, 'language'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      SupportedLanguages.getLanguageName(currentLocale.languageCode),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, Locale currentLocale) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t(context, 'language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SupportedLanguages.supportedLocales.map((locale) {
            final isSelected = locale.languageCode == currentLocale.languageCode;
            return ListTile(
              title: Text(SupportedLanguages.getLanguageName(locale.languageCode)),
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? Colors.green : Colors.grey,
              ),
              onTap: () {
                MyApp.of(context)?.setLocale(locale);
                Navigator.pop(dialogContext);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
