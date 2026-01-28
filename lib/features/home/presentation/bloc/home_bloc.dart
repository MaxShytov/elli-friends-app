import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../domain/entities/activity.dart';
import '../../../../core/services/audio_manager.dart';

/// BLoC for managing Home screen state and logic
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AudioManager audioManager;
  List<String> _randomGreetings = [];

  HomeBloc({required this.audioManager}) : super(const HomeInitial()) {
    on<HomeInitialized>(_onHomeInitialized);
    on<ActivityTapped>(_onActivityTapped);
    on<ElliTapped>(_onElliTapped);
    on<LanguageChanged>(_onLanguageChanged);
  }

  /// Handle home screen initialization
  Future<void> _onHomeInitialized(
    HomeInitialized event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      // Initialize the home screen with greeting
      // In a real app, you might load user data here
      await Future.delayed(const Duration(milliseconds: 500));

      // Load activities
      final activities = _loadActivities();

      // Store random greetings for Elli tap interactions
      _randomGreetings = event.randomGreetings;

      emit(HomeReady(
        greeting: event.greeting,
        characterMessage: 'What do you want to do?',
        elliIsAnimating: false,
        activities: activities,
      ));

      // Optionally play a welcome sound
      // await audioManager.playSound('welcome');
    } catch (e) {
      emit(HomeError('Failed to initialize home screen: $e'));
    }
  }

  /// Load activities (temporary hardcoded data)
  /// Note: titles will be localized in the UI layer
  List<Activity> _loadActivities() {
    return const [
      Activity(
        id: 'counting',
        title: 'counting', // Used as key for localization
        emoji: '🔢',
      ),
      Activity(
        id: 'subtraction',
        title: 'subtraction', // Used as key for localization
        emoji: '➖',
      ),
      Activity(
        id: 'colors_in_the_jungle_p1',
        title: 'colors_jungle_p1', // Used as key for localization
        emoji: '🍃',
      ),
      Activity(
        id: 'colors_in_the_jungle_p2',
        title: 'colors_jungle_p2', // Used as key for localization
        emoji: '🌺',
      ),
      Activity(
        id: 'shapes_in_the_jungle',
        title: 'shapes_jungle', // Used as key for localization
        emoji: '🔷',
      ),
      Activity(
        id: 'adding_fruits',
        title: 'adding_fruits', // Used as key for localization
        emoji: '🍎',
      ),
      Activity(
        id: 'english_greetings',
        title: 'english_greetings', // Used as key for localization
        emoji: '👋',
      ),
    ];
  }

  /// Handle activity button tap
  Future<void> _onActivityTapped(
    ActivityTapped event,
    Emitter<HomeState> emit,
  ) async {
    // Play click sound
    await audioManager.playSfx(SoundEffect.click);

    // Emit navigating state
    emit(HomeNavigating(event.activityType));

    // Note: Actual navigation will be handled by the UI layer
    // listening to the bloc state
  }

  /// Handle Elli character tap (for fun interaction)
  Future<void> _onElliTapped(
    ElliTapped event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeReady) {
      final currentState = state as HomeReady;

      // Animate Elli
      emit(currentState.copyWith(elliIsAnimating: true));

      // Play a fun sound
      await audioManager.playSfx(SoundEffect.click);

      // Speak a random greeting (use localized greetings from UI)
      if (_randomGreetings.isNotEmpty) {
        final randomGreeting = (_randomGreetings.toList()..shuffle()).first;
        await audioManager.speakDialogue(randomGreeting, character: 'elli');
      }

      // Reset animation after a delay
      await Future.delayed(const Duration(milliseconds: 500));
      emit(currentState.copyWith(elliIsAnimating: false));
    }
  }

  /// Handle language change
  Future<void> _onLanguageChanged(
    LanguageChanged event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeReady) {
      // Update language in audio manager
      await audioManager.changeLanguage(event.languageCode);

      // Note: The UI layer should reinitialize with new localized strings
      // by calling HomeInitialized with updated greeting parameters
    }
  }
}
