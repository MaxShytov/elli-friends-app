// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  /// Get app state to change language from anywhere
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

  /// Change app language
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

      // Localization
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
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
              l10n.homeWelcome,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.homeSubtitle,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.school),
              label: Text(l10n.btnLessons),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.games),
              label: Text(l10n.btnGames),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.star),
              label: Text(l10n.btnProgress),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showLanguageDialog(context, currentLocale, l10n),
              icon: const Icon(Icons.settings),
              label: Text(l10n.btnSettings),
            ),
            const SizedBox(height: 24),
            Text(
              'Current: ${SupportedLanguages.getLanguageName(currentLocale.languageCode)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    Locale currentLocale,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SupportedLanguages.supportedLocales.map((locale) {
            return RadioListTile<String>(
              title: Text(_getLanguageDisplayName(l10n, locale.languageCode)),
              value: locale.languageCode,
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  MyApp.of(context)?.setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getLanguageDisplayName(AppLocalizations l10n, String code) {
    switch (code) {
      case 'en':
        return l10n.languageEnglish;
      case 'fr':
        return l10n.languageFrench;
      case 'de':
        return l10n.languageGerman;
      case 'it':
        return l10n.languageItalian;
      case 'my':
        return l10n.languageBurmese;
      default:
        return code;
    }
  }
}
