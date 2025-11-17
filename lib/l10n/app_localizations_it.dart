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
  String get lessonCountingDemo => '🦋 Lezione: Contare (Demo)';

  @override
  String get loadingLesson => 'Caricamento lezione...';

  @override
  String get lessonLoadError => 'Errore nel caricamento della lezione';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get skip => 'Salta';

  @override
  String get noData => 'Nessun dato';

  @override
  String lessonScenes(int count) {
    return 'Scene della lezione ($count)';
  }

  @override
  String get character => 'Personaggio';

  @override
  String get pause => '⏸️ Pausa';

  @override
  String get scene => 'Scena';

  @override
  String get startLesson => 'Inizia lezione';

  @override
  String get comingSoon =>
      'Prossimamente: Riproduzione interattiva della lezione! 🎉';

  @override
  String get topic => 'Argomento';

  @override
  String get level => 'Livello';

  @override
  String get lesson => 'Lezione';

  @override
  String get next => 'Avanti';

  @override
  String get back => 'Indietro';

  @override
  String get correct => 'Corretto!';

  @override
  String get excellent => 'Eccellente!';

  @override
  String youEarnedStars(int stars) {
    return 'Hai guadagnato $stars stelle!';
  }

  @override
  String get outOf => 'su';

  @override
  String get done => 'Fatto';

  @override
  String get again => 'Riprova';

  @override
  String get elliGreeting => 'Ciao! Sono Elli l\'Elefante!';

  @override
  String get letsTogether => 'Impariamo insieme!';

  @override
  String get chooseActivity => 'Scegli un\'attività!';

  @override
  String get happyToSee => 'Sono così felice di vederti!';

  @override
  String get testVoice => 'Testa la voce';

  @override
  String get start => 'Inizia';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Medio';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String difficultyLevel(int level) {
    return 'Livello $level';
  }
}
