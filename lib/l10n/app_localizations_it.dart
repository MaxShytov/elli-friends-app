// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get settings => 'Impostazioni';

  @override
  String get learnNumbers => 'Impara i numeri';

  @override
  String get learnLetters => 'Impara le lettere';

  @override
  String get learnShapes => 'Impara le forme';

  @override
  String get learnColors => 'Impara i colori';

  @override
  String get hello => 'Ciao!';

  @override
  String get tapMe => 'Toccami!';

  @override
  String get languageSettings => 'Impostazioni lingua';

  @override
  String get selectLanguage => 'Seleziona la tua lingua';

  @override
  String languageChanged(String language) {
    return 'Lingua cambiata in $language';
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
