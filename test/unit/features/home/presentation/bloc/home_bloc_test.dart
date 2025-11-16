import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:elli_friends_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:elli_friends_app/features/home/presentation/bloc/home_event.dart';
import 'package:elli_friends_app/features/home/presentation/bloc/home_state.dart';
import 'package:elli_friends_app/core/services/audio_manager.dart';

// Mock classes
class MockAudioManager extends Mock implements AudioManager {}

void main() {
  late HomeBloc homeBloc;
  late MockAudioManager mockAudioManager;

  setUpAll(() {
    // Register fallback values for enums
    registerFallbackValue(SoundEffect.click);
  });

  setUp(() {
    mockAudioManager = MockAudioManager();

    // Set up default mock behaviors
    when(() => mockAudioManager.playSfx(any()))
        .thenAnswer((_) async => {});
    when(() => mockAudioManager.speakDialogue(any(), character: any(named: 'character')))
        .thenAnswer((_) async => {});
    when(() => mockAudioManager.changeLanguage(any()))
        .thenAnswer((_) async => {});

    homeBloc = HomeBloc(audioManager: mockAudioManager);
  });

  tearDown(() {
    homeBloc.close();
  });

  group('HomeBloc', () {
    test('initial state is HomeInitial', () {
      expect(homeBloc.state, equals(const HomeInitial()));
    });

    group('HomeInitialized', () {
      blocTest<HomeBloc, HomeState>(
        'emits [HomeLoading, HomeReady] when HomeInitialized is added',
        build: () => homeBloc,
        act: (bloc) => bloc.add(const HomeInitialized()),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          const HomeLoading(),
          isA<HomeReady>()
            .having((state) => state.greeting, 'greeting', isNotEmpty)
            .having((state) => state.characterMessage, 'characterMessage', isNotEmpty)
            .having((state) => state.elliIsAnimating, 'elliIsAnimating', false)
            .having((state) => state.activities, 'activities', hasLength(4)),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'HomeReady state contains correct activities',
        build: () => homeBloc,
        act: (bloc) => bloc.add(const HomeInitialized()),
        wait: const Duration(milliseconds: 600),
        verify: (bloc) {
          final state = bloc.state as HomeReady;
          final activities = state.activities;

          // Check first activity (unlocked)
          expect(activities[0].id, 'counting');
          expect(activities[0].emoji, '🔢');
          expect(activities[0].isLocked, false);

          // Check second activity (locked)
          expect(activities[1].id, 'letters');
          expect(activities[1].emoji, '🔤');
          expect(activities[1].isLocked, true);
          expect(activities[1].requiredStars, 10);

          // Check third activity (locked)
          expect(activities[2].id, 'shapes');
          expect(activities[2].emoji, '🔷');
          expect(activities[2].isLocked, true);
          expect(activities[2].requiredStars, 20);

          // Check fourth activity (locked)
          expect(activities[3].id, 'colors');
          expect(activities[3].emoji, '🎨');
          expect(activities[3].isLocked, true);
          expect(activities[3].requiredStars, 30);
        },
      );
    });

    group('ActivityTapped', () {
      blocTest<HomeBloc, HomeState>(
        'emits HomeNavigating when ActivityTapped is added',
        build: () => homeBloc,
        act: (bloc) => bloc.add(const ActivityTapped('counting')),
        expect: () => [
          const HomeNavigating('counting'),
        ],
        verify: (_) {
          verify(() => mockAudioManager.playSfx(SoundEffect.click)).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'plays click sound when activity is tapped',
        build: () => homeBloc,
        act: (bloc) => bloc.add(const ActivityTapped('letters')),
        verify: (_) {
          verify(() => mockAudioManager.playSfx(SoundEffect.click)).called(1);
        },
      );
    });

    group('ElliTapped', () {
      blocTest<HomeBloc, HomeState>(
        'animates Elli and plays sound when ElliTapped is added in HomeReady state',
        build: () => homeBloc,
        seed: () => const HomeReady(
          greeting: 'Hi! I\'m Elli the Elephant!',
          characterMessage: 'What do you want to do?',
          elliIsAnimating: false,
          activities: [],
        ),
        act: (bloc) => bloc.add(const ElliTapped()),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<HomeReady>().having((state) => state.elliIsAnimating, 'elliIsAnimating', true),
          isA<HomeReady>().having((state) => state.elliIsAnimating, 'elliIsAnimating', false),
        ],
        verify: (_) {
          verify(() => mockAudioManager.playSfx(SoundEffect.click)).called(1);
          verify(() => mockAudioManager.speakDialogue(any(), character: 'elli')).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'does not animate when not in HomeReady state',
        build: () => homeBloc,
        act: (bloc) => bloc.add(const ElliTapped()),
        expect: () => [],
      );
    });

    group('LanguageChanged', () {
      blocTest<HomeBloc, HomeState>(
        'changes language and reinitializes when LanguageChanged is added in HomeReady state',
        build: () => homeBloc,
        seed: () => const HomeReady(
          greeting: 'Hi! I\'m Elli the Elephant!',
          characterMessage: 'What do you want to do?',
          elliIsAnimating: false,
          activities: [],
        ),
        act: (bloc) => bloc.add(const LanguageChanged('ru')),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          const HomeLoading(),
          isA<HomeReady>(),
        ],
        verify: (_) {
          verify(() => mockAudioManager.changeLanguage('ru')).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'does not change language when not in HomeReady state',
        build: () => homeBloc,
        act: (bloc) => bloc.add(const LanguageChanged('ru')),
        expect: () => [],
      );
    });
  });
}
