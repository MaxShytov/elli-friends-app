import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/audio_manager.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/character_widget.dart';
import '../widgets/activity_button.dart';

/// Home screen of Elli & Friends app
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        audioManager: AudioManager(),
      )..add(const HomeInitialized()),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeNavigating) {
            _handleNavigation(context, state.activityType);
          } else if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.incorrect,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is HomeReady) {
            return _buildHomeContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeReady state) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.primary,
            width: 6,
          ),
        ),
        margin: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Elli Character
              GestureDetector(
                onTap: () {
                  context.read<HomeBloc>().add(const ElliTapped());
                },
                child: CharacterWidget(
                  isAnimating: state.elliIsAnimating,
                ),
              ),
              const SizedBox(height: 24),

              // Greeting Message
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.elliBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.borderSecondary,
                    width: 3,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      state.greeting,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.characterMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Encouragement Text
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.askForHint,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: const Text(
                  'Great job! Let\'s try...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Activity Buttons Grid (Top Row)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ActivityButton(
                    type: ActivityButtonType.watchAgain,
                    label: 'Watch\nagain',
                    icon: Icons.play_circle_outline,
                    onPressed: () => _onActivityTapped(context, 'watch'),
                  ),
                  ActivityButton(
                    type: ActivityButtonType.tryAgain,
                    label: 'Try\nagain',
                    icon: Icons.refresh,
                    onPressed: () => _onActivityTapped(context, 'try'),
                  ),
                  ActivityButton(
                    type: ActivityButtonType.askForHint,
                    label: 'Ask for\nhint',
                    icon: Icons.help_outline,
                    onPressed: () => _onActivityTapped(context, 'hint'),
                  ),
                  ActivityButton(
                    type: ActivityButtonType.seeMyScore,
                    label: 'See my\nscore',
                    icon: Icons.emoji_events,
                    onPressed: () => _onActivityTapped(context, 'score'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Round Activity Buttons (Bottom Row)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActivityButton(
                    type: ActivityButtonType.speak,
                    label: 'Speak',
                    icon: Icons.mic,
                    onPressed: () => _onActivityTapped(context, 'speak'),
                  ),
                  ActivityButton(
                    type: ActivityButtonType.draw,
                    label: 'Draw',
                    icon: Icons.edit,
                    onPressed: () => _onActivityTapped(context, 'draw'),
                  ),
                  ActivityButton(
                    type: ActivityButtonType.think,
                    label: 'Think',
                    icon: Icons.psychology,
                    onPressed: () => _onActivityTapped(context, 'think'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onActivityTapped(BuildContext context, String activityType) {
    context.read<HomeBloc>().add(ActivityTapped(activityType));
  }

  void _handleNavigation(BuildContext context, String activityType) {
    // TODO: Implement navigation to different screens based on activity type
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $activityType...'),
        backgroundColor: AppColors.correct,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
