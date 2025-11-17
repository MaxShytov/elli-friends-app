import 'package:elli_friends_app/features/lessons/data/models/lesson_model.dart';
import 'package:elli_friends_app/features/lessons/domain/entities/lesson.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LessonModel', () {
    const tLessonModel = LessonModel(
      id: 'test_lesson',
      title: 'Test Lesson',
      topic: 'testing',
      description: 'A test lesson',
      difficulty: 1,
      scenes: [
        SceneModel(
          character: 'bono',
          dialogue: 'Hello!',
          duration: 2,
          tone: 'friendly',
        ),
      ],
      tags: ['test', 'sample'],
    );

    test('should be a subclass of Lesson entity', () {
      expect(tLessonModel, isA<Lesson>());
    });

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        final jsonMap = {
          'id': 'test_lesson',
          'title': 'Test Lesson',
          'topic': 'testing',
          'description': 'A test lesson',
          'difficulty': 1,
          'scenes': [
            {
              'character': 'bono',
              'dialogue': 'Hello!',
              'duration': 2,
              'tone': 'friendly',
            }
          ],
          'tags': ['test', 'sample'],
        };

        final result = LessonModel.fromJson(jsonMap);

        expect(result, equals(tLessonModel));
      });

      test('should handle optional tags as empty list', () {
        final jsonMap = {
          'id': 'test_lesson',
          'title': 'Test Lesson',
          'topic': 'testing',
          'description': 'A test lesson',
          'difficulty': 1,
          'scenes': [],
        };

        final result = LessonModel.fromJson(jsonMap);

        expect(result.tags, equals([]));
      });

      test('should parse scenes with animals', () {
        final jsonMap = {
          'id': 'test_lesson',
          'title': 'Test Lesson',
          'topic': 'testing',
          'description': 'A test lesson',
          'difficulty': 1,
          'scenes': [
            {
              'dialogue': 'Look at the animals!',
              'animals': [
                {
                  'type': 'butterfly',
                  'emoji': '🦋',
                  'count': 3,
                }
              ],
            }
          ],
          'tags': [],
        };

        final result = LessonModel.fromJson(jsonMap);

        expect(result.scenes.length, equals(1));
        expect(result.scenes[0].animals?.length, equals(1));
        expect(result.scenes[0].animals![0].type, equals('butterfly'));
        expect(result.scenes[0].animals![0].emoji, equals('🦋'));
        expect(result.scenes[0].animals![0].count, equals(3));
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        final result = tLessonModel.toJson();

        final expectedMap = {
          'id': 'test_lesson',
          'title': 'Test Lesson',
          'topic': 'testing',
          'description': 'A test lesson',
          'difficulty': 1,
          'scenes': [
            {
              'character': 'bono',
              'dialogue': 'Hello!',
              'duration': 2,
              'tone': 'friendly',
              'animals': null,
              'isQuestion': false,
              'isPause': false,
              'correctAnswer': null,
              'waitForAnswer': false,
              'showPreviousAnimals': false,
            }
          ],
          'tags': ['test', 'sample'],
        };

        expect(result, equals(expectedMap));
      });
    });

    group('fromJson and toJson round trip', () {
      test('should maintain data integrity', () {
        final json = tLessonModel.toJson();
        final result = LessonModel.fromJson(json);

        expect(result, equals(tLessonModel));
      });
    });
  });

  group('SceneModel', () {
    const tSceneModel = SceneModel(
      character: 'bono',
      dialogue: 'Hello!',
      duration: 2,
      tone: 'friendly',
    );

    test('should be a subclass of Scene entity', () {
      expect(tSceneModel, isA<Scene>());
    });

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        final jsonMap = {
          'character': 'bono',
          'dialogue': 'Hello!',
          'duration': 2,
          'tone': 'friendly',
        };

        final result = SceneModel.fromJson(jsonMap);

        expect(result.character, equals('bono'));
        expect(result.dialogue, equals('Hello!'));
        expect(result.duration, equals(2));
        expect(result.tone, equals('friendly'));
      });

      test('should handle boolean fields with defaults', () {
        final jsonMap = {
          'character': 'bono',
          'dialogue': 'Hello!',
        };

        final result = SceneModel.fromJson(jsonMap);

        expect(result.isQuestion, equals(false));
        expect(result.isPause, equals(false));
        expect(result.waitForAnswer, equals(false));
      });

      test('should parse animals list', () {
        final jsonMap = {
          'dialogue': 'Look!',
          'animals': [
            {
              'type': 'monkey',
              'emoji': '🐒',
              'count': 2,
            }
          ],
        };

        final result = SceneModel.fromJson(jsonMap);

        expect(result.animals?.length, equals(1));
        expect(result.animals![0].type, equals('monkey'));
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        final result = tSceneModel.toJson();

        final expectedMap = {
          'character': 'bono',
          'dialogue': 'Hello!',
          'duration': 2,
          'tone': 'friendly',
          'animals': null,
          'isQuestion': false,
          'isPause': false,
          'correctAnswer': null,
          'waitForAnswer': false,
          'showPreviousAnimals': false,
        };

        expect(result, equals(expectedMap));
      });
    });
  });

  group('AnimalModel', () {
    const tAnimalModel = AnimalModel(
      type: 'butterfly',
      emoji: '🦋',
      count: 1,
    );

    test('should be a subclass of Animal entity', () {
      expect(tAnimalModel, isA<Animal>());
    });

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        final jsonMap = {
          'type': 'butterfly',
          'emoji': '🦋',
          'count': 1,
        };

        final result = AnimalModel.fromJson(jsonMap);

        expect(result, equals(tAnimalModel));
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        final result = tAnimalModel.toJson();

        final expectedMap = {
          'type': 'butterfly',
          'emoji': '🦋',
          'count': 1,
        };

        expect(result, equals(expectedMap));
      });
    });

    group('fromJson and toJson round trip', () {
      test('should maintain data integrity', () {
        final json = tAnimalModel.toJson();
        final result = AnimalModel.fromJson(json);

        expect(result, equals(tAnimalModel));
      });
    });
  });
}
