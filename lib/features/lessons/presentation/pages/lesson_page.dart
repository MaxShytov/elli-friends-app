import 'package:flutter/material.dart';
import '../../data/datasources/lesson_local_data_source.dart';
import '../../data/repositories/lesson_repository_impl.dart';
import '../../domain/usecases/get_lesson.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Lesson page for displaying individual lessons
class LessonPage extends StatefulWidget {
  final String lessonId;

  const LessonPage({
    super.key,
    required this.lessonId,
  });

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  GetLesson? _getLesson;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _lessonData;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize or reload lesson if locale changes
    final currentLocale = Localizations.localeOf(context).languageCode;
    final dataSource = LessonLocalDataSourceImpl();
    final repository = LessonRepositoryImpl(dataSource, languageCode: currentLocale);
    _getLesson = GetLesson(repository);

    // Load lesson only on first initialization
    if (!_isInitialized) {
      _isInitialized = true;
      _loadLesson();
    }
  }

  Future<void> _loadLesson() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final lesson = await _getLesson!(widget.lessonId);

      setState(() {
        _lessonData = {
          'id': lesson.id,
          'title': lesson.title,
          'topic': lesson.topic,
          'description': lesson.description,
          'difficulty': lesson.difficulty,
          'tags': lesson.tags,
          'sceneCount': lesson.scenes.length,
          'scenes': lesson.scenes,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_lessonData?['title'] ?? 'Lesson'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.incorrect,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.lessonLoadError,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadLesson,
                child: Text(AppLocalizations.of(context)!.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (_lessonData == null) {
      return Center(
        child: Text(AppLocalizations.of(context)!.noData),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson header
          Card(
            color: AppColors.cardBg,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _lessonData!['title'],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lessonData!['description'],
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        '${AppLocalizations.of(context)!.topic}: ${_lessonData!['topic']}',
                        Icons.book,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        '${AppLocalizations.of(context)!.level}: ${_lessonData!['difficulty']}',
                        Icons.star,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: (_lessonData!['tags'] as List<String>)
                        .map((tag) => Chip(
                              label: Text(tag),
                              backgroundColor: AppColors.correct.withValues(alpha: 0.2),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Scenes preview
          Text(
            AppLocalizations.of(context)!.lessonScenes(_lessonData!['sceneCount'] as int),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ...(_lessonData!['scenes'] as List).asMap().entries.map((entry) {
            final index = entry.key;
            final scene = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  scene.dialogue ?? scene.character ?? AppLocalizations.of(context)!.scene,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: scene.character != null
                    ? Text('${AppLocalizations.of(context)!.character}: ${scene.character}')
                    : scene.isPause
                        ? Text(AppLocalizations.of(context)!.pause)
                        : null,
                trailing: scene.animals != null && scene.animals!.isNotEmpty
                    ? Text(
                        scene.animals!.map((a) => a.emoji).join(' '),
                        style: const TextStyle(fontSize: 24),
                      )
                    : null,
              ),
            );
          }),

          const SizedBox(height: 24),

          // Start lesson button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.comingSoon),
                    backgroundColor: AppColors.correct,
                  ),
                );
              },
              icon: const Icon(Icons.play_circle_filled),
              label: Text(AppLocalizations.of(context)!.startLesson),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.correct,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label),
      backgroundColor: Colors.white,
    );
  }
}
