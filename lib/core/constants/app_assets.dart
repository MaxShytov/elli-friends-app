/// App assets paths
class AppAssets {
  AppAssets._();

  // Audio - Sound Effects
  static const String correctSound = 'assets/audio/sfx/correct.mp3';
  static const String wrongSound = 'assets/audio/sfx/wrong.mp3';
  static const String clickSound = 'assets/audio/sfx/click.mp3';
  static const String starSound = 'assets/audio/sfx/star.mp3';
  static const String successSound = 'assets/audio/sfx/success.mp3';
  static const String hintSound = 'assets/audio/sfx/hint.mp3';

  // Audio - Animal Sounds
  static const String butterflySound = 'assets/audio/animals/butterfly.mp3';
  static const String monkeySound = 'assets/audio/animals/monkey.mp3';
  static const String birdSound = 'assets/audio/animals/bird.mp3';
  static const String turtleSound = 'assets/audio/animals/turtle.mp3';
  static const String frogSound = 'assets/audio/animals/frog.mp3';

  // Audio - Background Music
  static const String jungleAmbient = 'assets/audio/music/jungle_ambient.mp3';
  static const String lessonBackground = 'assets/audio/music/lesson_background.mp3';
  static const String celebration = 'assets/audio/music/celebration.mp3';

  // Images - Characters
  static const String elliImage = 'assets/images/characters/elli.png';
  static const String bonoImage = 'assets/images/characters/bono.png';
  static const String hippoImage = 'assets/images/characters/hippo.png';

  // Images - Animals
  static const String animalsPath = 'assets/images/animals/';

  // Images - Backgrounds
  static const String backgroundsPath = 'assets/images/backgrounds/';

  // Data - Lessons
  static const String lessonCountingEn = 'assets/data/lessons/en/lesson_counting.json';
  static const String lessonCountingFr = 'assets/data/lessons/fr/lesson_counting.json';
  static const String lessonCountingDe = 'assets/data/lessons/de/lesson_counting.json';
  static const String lessonCountingIt = 'assets/data/lessons/it/lesson_counting.json';
  static const String lessonCountingMy = 'assets/data/lessons/my/lesson_counting.json';

  /// Get lesson path by language code
  static String getLessonPath(String languageCode, String lessonId) {
    return 'assets/data/lessons/$languageCode/$lessonId.json';
  }
}
