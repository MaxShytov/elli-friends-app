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
}
