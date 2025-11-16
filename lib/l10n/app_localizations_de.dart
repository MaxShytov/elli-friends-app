// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settings => 'Einstellungen';

  @override
  String get learnNumbers => 'Zahlen lernen';

  @override
  String get learnLetters => 'Buchstaben lernen';

  @override
  String get learnShapes => 'Formen lernen';

  @override
  String get learnColors => 'Farben lernen';

  @override
  String get hello => 'Hallo!';

  @override
  String get tapMe => 'Tippe mich an!';

  @override
  String get languageSettings => 'Spracheinstellungen';

  @override
  String get selectLanguage => 'Wähle deine Sprache';

  @override
  String languageChanged(String language) {
    return 'Sprache geändert auf $language';
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
