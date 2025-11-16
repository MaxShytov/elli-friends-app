import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../../../core/services/audio_manager.dart';

/// BLoC for managing Home screen state and logic
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AudioManager audioManager;

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

      emit(const HomeReady(
        greeting: 'Hi! I\'m Elli the Elephant!',
        characterMessage: 'What do you want to do?',
        elliIsAnimating: false,
      ));

      // Optionally play a welcome sound
      // await audioManager.playSound('welcome');
    } catch (e) {
      emit(HomeError('Failed to initialize home screen: $e'));
    }
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

      // Speak a greeting
      final greetings = [
        'Hi! I\'m Elli the Elephant!',
        'Let\'s learn together!',
        'Choose an activity!',
        'I\'m so happy to see you!',
      ];
      final randomGreeting = (greetings..shuffle()).first;

      await audioManager.speakDialogue(randomGreeting, character: 'elli');

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

      // Refresh the home screen with new language
      add(const HomeInitialized());
    }
  }
}
