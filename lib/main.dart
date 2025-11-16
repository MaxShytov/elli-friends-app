// lib/main.dart
// Elli & Friends - Main entry point

import 'package:flutter/material.dart';
import 'core/constants/supported_languages.dart';
import 'core/services/language_service.dart';
import 'core/services/audio_manager.dart';
import 'features/home/presentation/screens/home_screen.dart';

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
