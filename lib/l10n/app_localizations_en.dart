// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get learnNumbers => 'Learn Numbers';

  @override
  String get learnSubtraction => 'Subtraction';

  @override
  String get learnLetters => 'Learn Letters';

  @override
  String get learnShapes => 'Learn Shapes';

  @override
  String get learnColors => 'Learn Colors';

  @override
  String get hello => 'Hello!';

  @override
  String get tapMe => 'Tap me!';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get selectLanguage => 'Select your language';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get lessonCountingDemo => '🦋 Lesson: Counting (Demo)';

  @override
  String get loadingLesson => 'Loading lesson...';

  @override
  String get lessonLoadError => 'Error loading lesson';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get skip => 'Skip';

  @override
  String get noData => 'No data';

  @override
  String lessonScenes(int count) {
    return 'Lesson Scenes ($count)';
  }

  @override
  String get character => 'Character';

  @override
  String get pause => '⏸️ Pause';

  @override
  String get scene => 'Scene';

  @override
  String get startLesson => 'Start Lesson';

  @override
  String get comingSoon => 'Coming soon: Interactive lesson playback! 🎉';

  @override
  String get topic => 'Topic';

  @override
  String get level => 'Level';

  @override
  String get lesson => 'Lesson';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get correct => 'Correct!';

  @override
  String get excellent => 'Excellent!';

  @override
  String youEarnedStars(int stars) {
    return 'You earned $stars stars!';
  }

  @override
  String get outOf => 'out of';

  @override
  String get done => 'Done';

  @override
  String get again => 'Try Again';

  @override
  String get elliGreeting => 'Hi! I\'m Elli the Elephant!';

  @override
  String get letsTogether => 'Let\'s learn together!';

  @override
  String get chooseActivity => 'Choose an activity!';

  @override
  String get happyToSee => 'I\'m so happy to see you!';

  @override
  String get testVoice => 'Test Voice';

  @override
  String get start => 'Start';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String difficultyLevel(int level) {
    return 'Level $level';
  }

  @override
  String get orsonGreeting => 'Hi, I\'m Orson the purple cat';

  @override
  String get mervGreeting => 'Hi, I\'m Merv the yellow puppy';

  @override
  String get developerSettings => 'Developer Settings';

  @override
  String get resetLessonData => 'Reset Lesson Data';

  @override
  String get resetLessonDataConfirm => 'Reset all lesson data to defaults?';

  @override
  String get resetSuccess => 'Data reset successfully';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get colorsInJungleP1 => 'Colors in the Jungle 1';

  @override
  String get colorsInJungleP2 => 'Colors in the Jungle 2';

  @override
  String get shapesInJungle => 'Shapes in the Jungle';

  @override
  String get addingFruits => 'Adding Fruits';

  @override
  String get englishGreetings => 'English Greetings';
}
