import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../lessons/data/datasources/lesson_drift_data_source.dart';
import '../bloc/editor_bloc.dart';
import '../bloc/editor_event.dart';
import '../bloc/editor_state.dart';
import 'lesson_editor_page.dart';

/// Main editor page showing list of lessons to edit
class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditorBloc(
        dataSource: LessonDriftDataSourceImpl(AppDatabase.instance),
      )..add(const LoadLessonsForEditing()),
      child: const _EditorPageContent(),
    );
  }
}

class _EditorPageContent extends StatelessWidget {
  const _EditorPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Editor'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<EditorBloc, EditorState>(
        builder: (context, state) {
          if (state is EditorLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EditorError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.incorrect),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<EditorBloc>().add(const LoadLessonsForEditing());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is EditorLessonsList) {
            return _LessonsList(lessons: state.lessons);
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}

class _LessonsList extends StatelessWidget {
  final List lessons;

  const _LessonsList({required this.lessons});

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No lessons found'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withValues(alpha: 0.2),
              child: const Icon(Icons.book, color: Colors.purple),
            ),
            title: Text(
              lesson.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${lesson.scenes.length} scenes • ${lesson.topic}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.edit, color: Colors.purple),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LessonEditorPage(lessonId: lesson.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
