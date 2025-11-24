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
  String get learnSubtraction => 'Soustraction';

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
  String get lessonCountingDemo => '🦋 Leçon: Compter (Démo)';

  @override
  String get loadingLesson => 'Chargement de la leçon...';

  @override
  String get lessonLoadError => 'Erreur de chargement de la leçon';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get skip => 'Passer';

  @override
  String get noData => 'Aucune donnée';

  @override
  String lessonScenes(int count) {
    return 'Scènes de la leçon ($count)';
  }

  @override
  String get character => 'Personnage';

  @override
  String get pause => '⏸️ Pause';

  @override
  String get scene => 'Scène';

  @override
  String get startLesson => 'Commencer la leçon';

  @override
  String get comingSoon => 'Bientôt: Lecture interactive de la leçon! 🎉';

  @override
  String get topic => 'Sujet';

  @override
  String get level => 'Niveau';

  @override
  String get lesson => 'Leçon';

  @override
  String get next => 'Suivant';

  @override
  String get back => 'Retour';

  @override
  String get correct => 'Correct!';

  @override
  String get excellent => 'Excellent!';

  @override
  String youEarnedStars(int stars) {
    return 'Vous avez gagné $stars étoiles!';
  }

  @override
  String get outOf => 'sur';

  @override
  String get done => 'Terminé';

  @override
  String get again => 'Réessayer';

  @override
  String get elliGreeting => 'Salut! Je suis Elli l\'Éléphant!';

  @override
  String get letsTogether => 'Apprenons ensemble!';

  @override
  String get chooseActivity => 'Choisis une activité!';

  @override
  String get happyToSee => 'Je suis si heureuse de te voir!';

  @override
  String get testVoice => 'Tester la voix';

  @override
  String get start => 'Commencer';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Moyen';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String difficultyLevel(int level) {
    return 'Niveau $level';
  }

  @override
  String get orsonGreeting => 'Salut, je suis Orson le chat violet';

  @override
  String get mervGreeting => 'Salut, je suis Merv le chiot jaune';

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
}
