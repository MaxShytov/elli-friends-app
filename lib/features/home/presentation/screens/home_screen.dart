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
import '../widgets/animated_character_widget.dart';
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
        title: const Text(
          'Elli & Friends',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.pets,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elli & Friends',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.settings),
              onTap: () {
                Navigator.pop(context); // Close drawer
                context.push('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Mascots Demo'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                context.push('/mascots-demo');
              },
            ),
          ],
        ),
      ),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
            children: [
              // Animated character with greeting
              const AnimatedCharacterWidget(),

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
                      // Navigate to lesson page
                      context.push('/lesson/${activity.id}');
                    },
                  );
                },
              ),

              // TEST: Demo lesson buttons
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

              const SizedBox(height: AppDimensions.paddingSmall),
              ElevatedButton.icon(
                onPressed: () => context.push('/lesson/subtraction'),
                icon: const Icon(Icons.remove),
                label: const Text('Subtraction with Orson'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
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
