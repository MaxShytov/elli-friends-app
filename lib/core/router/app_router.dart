import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/lessons/presentation/pages/lesson_page.dart';
import '../../features/games/presentation/pages/game_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/tts_test_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/lesson/:lessonId',
      name: 'lesson',
      builder: (context, state) {
        final lessonId = state.pathParameters['lessonId']!;
        return LessonPage(lessonId: lessonId);
      },
    ),
    GoRoute(
      path: '/game/:gameId',
      name: 'game',
      builder: (context, state) {
        final gameId = state.pathParameters['gameId']!;
        return GamePage(gameId: gameId);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/tts-test',
      name: 'tts-test',
      builder: (context, state) => const TtsTestPage(),
    ),
  ],
);
