// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get settings => 'ဆက်တင်များ';

  @override
  String get learnNumbers => 'ဂဏန်းများကို လေ့လာပါ';

  @override
  String get learnLetters => 'အက္ခရာများကို လေ့လာပါ';

  @override
  String get learnShapes => 'ပုံသဏ္ဍာန်များကို လေ့လာပါ';

  @override
  String get learnColors => 'အရောင်များကို လေ့လာပါ';

  @override
  String get hello => 'မင်္ဂလာပါ!';

  @override
  String get tapMe => 'ငါ့ကို နှိပ်ပါ!';

  @override
  String get languageSettings => 'ဘာသာစကား ဆက်တင်များ';

  @override
  String get selectLanguage => 'သင့်ဘာသာစကားကို ရွေးချယ်ပါ';

  @override
  String languageChanged(String language) {
    return '$language သို့ ဘာသာစကား ပြောင်းလဲပြီးပါပြီ';
  }
}
