// lib/main.dart
// Elli & Friends - Main entry point

import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем аудио
  final audioManager = AudioManager();
  await audioManager.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Elli & Friends',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
