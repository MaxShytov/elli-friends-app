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
}
