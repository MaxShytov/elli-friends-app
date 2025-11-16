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
