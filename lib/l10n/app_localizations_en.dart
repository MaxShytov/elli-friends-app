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
}
