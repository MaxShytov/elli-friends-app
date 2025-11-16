// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get settings => 'Paramètres';

  @override
  String get learnNumbers => 'Apprendre les chiffres';

  @override
  String get learnLetters => 'Apprendre les lettres';

  @override
  String get learnShapes => 'Apprendre les formes';

  @override
  String get learnColors => 'Apprendre les couleurs';

  @override
  String get hello => 'Bonjour!';

  @override
  String get tapMe => 'Touche-moi!';

  @override
  String get languageSettings => 'Paramètres de langue';

  @override
  String get selectLanguage => 'Sélectionnez votre langue';

  @override
  String languageChanged(String language) {
    return 'Langue changée en $language';
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
