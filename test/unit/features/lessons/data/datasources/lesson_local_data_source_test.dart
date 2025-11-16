import 'package:elli_friends_app/features/lessons/data/datasources/lesson_local_data_source.dart';
import 'package:elli_friends_app/features/lessons/data/models/lesson_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonLocalDataSourceImpl dataSource;

  setUp(() {
    dataSource = LessonLocalDataSourceImpl();
  });

  group('LessonLocalDataSource', () {
    group('getLessonById', () {
      test('should return LessonModel when loading Russian asset file', () async {
        // Act - Load the Russian lesson_counting.json file from assets
        final result = await dataSource.getLessonById('counting', languageCode: 'ru');

        // Assert
        expect(result, isA<LessonModel>());
        expect(result.id, equals('lesson_counting'));
        expect(result.title, contains('Счёт'));
        expect(result.topic, equals('counting'));
        expect(result.difficulty, equals(1));
        expect(result.scenes.isNotEmpty, isTrue);
        expect(result.tags, contains('counting'));
      });

      test('should return LessonModel when loading English asset file', () async {
        // Act - Load the English lesson_counting.json file from assets
        final result = await dataSource.getLessonById('counting', languageCode: 'en');

        // Assert
        expect(result, isA<LessonModel>());
        expect(result.id, equals('lesson_counting'));
        expect(result.title, contains('Counting'));
        expect(result.topic, equals('counting'));
        expect(result.difficulty, equals(1));
        expect(result.scenes.isNotEmpty, isTrue);
        expect(result.tags, contains('counting'));
      });

      test('should throw Exception when lesson file does not exist', () async {
        // Act & Assert
        expect(
          () async => await dataSource.getLessonById('non_existent_lesson', languageCode: 'en'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getAllLessons', () {
      test('should return list of LessonModel with Russian lessons', () async {
        // Act
        final result = await dataSource.getAllLessons(languageCode: 'ru');

        // Assert
        expect(result, isA<List<LessonModel>>());
        expect(result.length, equals(1)); // Currently only 'counting' lesson
        expect(result[0].id, equals('lesson_counting'));
        expect(result[0].title, contains('Счёт'));
      });

      test('should return list of LessonModel with English lessons', () async {
        // Act
        final result = await dataSource.getAllLessons(languageCode: 'en');

        // Assert
        expect(result, isA<List<LessonModel>>());
        expect(result.length, equals(1)); // Currently only 'counting' lesson
        expect(result[0].id, equals('lesson_counting'));
        expect(result[0].title, contains('Counting'));
      });
    });
  });
}
