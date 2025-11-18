// lib/main.dart
// Elli & Friends - Main entry point

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rive/rive.dart' as rive;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/audio_manager.dart';
import 'core/services/locale_service.dart';
import 'core/constants/supported_languages.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Rive Native for Runtime Version 7 support (not on web)
  if (!kIsWeb) {
    await rive.RiveNative.init();
  }

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize locale service
  final localeService = LocaleService();
  await localeService.initialize();

  // Initialize audio with the saved language
  final audioManager = AudioManager();
  await audioManager.initialize(languageCode: localeService.currentLocale.languageCode);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocaleService _localeService = LocaleService();

  @override
  void initState() {
    super.initState();
    // Listen to locale changes
    _localeService.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    _localeService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {
      // Rebuild when locale changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Elli & Friends',
      theme: AppTheme.lightTheme,
      locale: _localeService.currentLocale,
      supportedLocales: SupportedLanguages.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
