import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/services/audio_manager.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/character_widget.dart';
import '../widgets/activity_card.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          children: [
            // Elli character with greeting
            CharacterWidget(
              emoji: '🐘',
              greeting: state.greeting,
              isAnimating: state.elliIsAnimating,
              onTap: () {
                context.read<HomeBloc>().add(const ElliTapped());
              },
            ),

            const SizedBox(height: AppDimensions.paddingXLarge),

            // Activity grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppDimensions.paddingMedium,
                  mainAxisSpacing: AppDimensions.paddingMedium,
                  childAspectRatio: 1.0,
                ),
                itemCount: state.activities.length,
                itemBuilder: (context, index) {
                  final activity = state.activities[index];
                  return ActivityCard(
                    activity: activity,
                    onTap: () {
                      context.push('/lesson/${activity.id}');
                    },
                  );
                },
              ),
            ),

            // Settings button
            const SizedBox(height: AppDimensions.paddingMedium),
            OutlinedButton.icon(
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.settings),
              label: Text(AppLocalizations.of(context)!.settings),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical: AppDimensions.paddingMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, String activityType) {
    // Navigation is now handled directly in ActivityCard via go_router
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $activityType...'),
        backgroundColor: AppColors.correct,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
