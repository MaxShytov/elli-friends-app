import 'package:flutter/material.dart';

/// Lesson page for displaying individual lessons
class LessonPage extends StatelessWidget {
  final String lessonId;

  const LessonPage({
    super.key,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson: $lessonId'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              'Lesson $lessonId',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lesson content will be displayed here',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
