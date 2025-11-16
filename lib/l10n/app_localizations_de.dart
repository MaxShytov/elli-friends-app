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
}
