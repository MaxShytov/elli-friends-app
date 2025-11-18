// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get settings => 'Настройки';

  @override
  String get learnNumbers => 'Учим цифры';

  @override
  String get learnSubtraction => 'Вычитание';

  @override
  String get learnLetters => 'Учим буквы';

  @override
  String get learnShapes => 'Учим фигуры';

  @override
  String get learnColors => 'Учим цвета';

  @override
  String get hello => 'Привет!';

  @override
  String get tapMe => 'Нажми на меня!';

  @override
  String get languageSettings => 'Настройки языка';

  @override
  String get selectLanguage => 'Выберите свой язык';

  @override
  String languageChanged(String language) {
    return 'Язык изменён на $language';
  }

  @override
  String get lessonCountingDemo => '🦋 Урок: Счёт (Демо)';

  @override
  String get loadingLesson => 'Загрузка урока...';

  @override
  String get lessonLoadError => 'Ошибка загрузки урока';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get skip => 'Пропустить';

  @override
  String get noData => 'Нет данных';

  @override
  String lessonScenes(int count) {
    return 'Сцены урока ($count)';
  }

  @override
  String get character => 'Персонаж';

  @override
  String get pause => '⏸️ Пауза';

  @override
  String get scene => 'Сцена';

  @override
  String get startLesson => 'Начать урок';

  @override
  String get comingSoon => 'Скоро: интерактивное проигрывание урока! 🎉';

  @override
  String get topic => 'Тема';

  @override
  String get level => 'Уровень';

  @override
  String get lesson => 'Урок';

  @override
  String get next => 'Дальше';

  @override
  String get back => 'Назад';

  @override
  String get correct => 'Правильно!';

  @override
  String get excellent => 'Отлично!';

  @override
  String youEarnedStars(int stars) {
    return 'Вы заработали $stars звёзд!';
  }

  @override
  String get outOf => 'из';

  @override
  String get done => 'Готово';

  @override
  String get again => 'Ещё раз';

  @override
  String get elliGreeting => 'Привет! Я Элли, слониха!';

  @override
  String get letsTogether => 'Давай учиться вместе!';

  @override
  String get chooseActivity => 'Выбери занятие!';

  @override
  String get happyToSee => 'Я так рада тебя видеть!';

  @override
  String get testVoice => 'Тест голоса';

  @override
  String get start => 'Начать';

  @override
  String get difficultyEasy => 'Легко';

  @override
  String get difficultyMedium => 'Средне';

  @override
  String get difficultyHard => 'Сложно';

  @override
  String difficultyLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String get orsonGreeting => 'Привет, я фиолетовый кот Orson';

  @override
  String get mervGreeting => 'Привет, я жёлтый пёсик Merv';
}
