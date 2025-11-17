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
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeBloc _bloc;
  Locale? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentLocale = Localizations.localeOf(context);

    // Check if locale changed
    if (_lastLocale == null || _lastLocale != currentLocale) {
      _lastLocale = currentLocale;

      // Recreate bloc with new localized strings
      final l10n = AppLocalizations.of(context)!;
      _bloc = HomeBloc(
        audioManager: AudioManager(),
      )..add(HomeInitialized(
        greeting: l10n.elliGreeting,
        randomGreetings: [
          l10n.elliGreeting,
          l10n.letsTogether,
          l10n.chooseActivity,
          l10n.happyToSee,
        ],
      ));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
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
      child: SingleChildScrollView(
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

              const SizedBox(height: AppDimensions.paddingLarge),

              // Activity grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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

              // TEST: Demo lesson button
              const SizedBox(height: AppDimensions.paddingLarge),
              ElevatedButton.icon(
                onPressed: () => context.push('/lesson/counting'),
                icon: const Icon(Icons.play_arrow),
                label: Text(AppLocalizations.of(context)!.lessonCountingDemo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.correct,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                    vertical: AppDimensions.paddingMedium,
                  ),
                ),
              ),

              // Settings button
              const SizedBox(height: AppDimensions.paddingSmall),
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

              // Bottom padding for scrolling
              const SizedBox(height: AppDimensions.paddingLarge),
            ],
          ),
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
