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
  String get learnSubtraction => 'Subtraktion';

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
  String get lessonCountingDemo => '🦋 Lektion: Zählen (Demo)';

  @override
  String get loadingLesson => 'Lektion wird geladen...';

  @override
  String get lessonLoadError => 'Fehler beim Laden der Lektion';

  @override
  String get tryAgain => 'Nochmal versuchen';

  @override
  String get skip => 'Überspringen';

  @override
  String get noData => 'Keine Daten';

  @override
  String lessonScenes(int count) {
    return 'Lektionsszenen ($count)';
  }

  @override
  String get character => 'Charakter';

  @override
  String get pause => '⏸️ Pause';

  @override
  String get scene => 'Szene';

  @override
  String get startLesson => 'Lektion starten';

  @override
  String get comingSoon => 'Demnächst: Interaktive Lektionswiedergabe! 🎉';

  @override
  String get topic => 'Thema';

  @override
  String get level => 'Stufe';

  @override
  String get lesson => 'Lektion';

  @override
  String get next => 'Weiter';

  @override
  String get back => 'Zurück';

  @override
  String get correct => 'Richtig!';

  @override
  String get excellent => 'Ausgezeichnet!';

  @override
  String youEarnedStars(int stars) {
    return 'Du hast $stars Sterne verdient!';
  }

  @override
  String get outOf => 'von';

  @override
  String get done => 'Fertig';

  @override
  String get again => 'Nochmal versuchen';

  @override
  String get elliGreeting => 'Hallo! Ich bin Elli der Elefant!';

  @override
  String get letsTogether => 'Lass uns zusammen lernen!';

  @override
  String get chooseActivity => 'Wähle eine Aktivität!';

  @override
  String get happyToSee => 'Ich freue mich so, dich zu sehen!';

  @override
  String get testVoice => 'Stimme testen';

  @override
  String get start => 'Start';

  @override
  String get difficultyEasy => 'Einfach';

  @override
  String get difficultyMedium => 'Mittel';

  @override
  String get difficultyHard => 'Schwer';

  @override
  String difficultyLevel(int level) {
    return 'Stufe $level';
  }

  @override
  String get orsonGreeting => 'Hallo, ich bin Orson die lila Katze';

  @override
  String get mervGreeting => 'Hallo, ich bin Merv der gelbe Welpe';
}
