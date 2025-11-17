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
  String get lessonCountingDemo => '🦋 သင်ခန်းစာ: ရေတွက်ခြင်း (သရုပ်ပြ)';

  @override
  String get loadingLesson => 'သင်ခန်းစာ တင်နေသည်...';

  @override
  String get lessonLoadError => 'သင်ခန်းစာ တင်ရာတွင် အမှား';

  @override
  String get tryAgain => 'ထပ်ကြိုးစားပါ';

  @override
  String get skip => 'ကျော်သွားပါ';

  @override
  String get noData => 'အချက်အလက် မရှိပါ';

  @override
  String lessonScenes(int count) {
    return 'သင်ခန်းစာ မြင်ကွင်းများ ($count)';
  }

  @override
  String get character => 'ဇာတ်ကောင်';

  @override
  String get pause => '⏸️ ခေတ္တရပ်ရန်';

  @override
  String get scene => 'မြင်ကွင်း';

  @override
  String get startLesson => 'သင်ခန်းစာ စတင်ရန်';

  @override
  String get comingSoon => 'မကြာမီ: အပြန်အလှန် သင်ခန်းစာ ဖွင့်ခြင်း! 🎉';

  @override
  String get topic => 'အကြောင်းအရာ';

  @override
  String get level => 'အဆင့်';

  @override
  String get lesson => 'သင်ခန်းစာ';

  @override
  String get next => 'နောက်တစ်ခု';

  @override
  String get back => 'နောက်သို့';

  @override
  String get correct => 'မှန်ကန်သည်!';

  @override
  String get excellent => 'အလွန်ကောင်းမွန်သည်!';

  @override
  String youEarnedStars(int stars) {
    return 'သင် $stars ကြယ်များ ရရှိခဲ့သည်!';
  }

  @override
  String get outOf => 'မှ';

  @override
  String get done => 'ပြီးပါပြီ';

  @override
  String get again => 'ထပ်ကြိုးစားပါ';

  @override
  String get elliGreeting => 'မင်္ဂလာပါ! ငါ အယ်လီ ဆင်ကြီးပါ!';

  @override
  String get letsTogether => 'အတူတူ လေ့လာကြရအောင်!';

  @override
  String get chooseActivity => 'လှုပ်ရှားမှု တစ်ခု ရွေးပါ!';

  @override
  String get happyToSee => 'မင်းကို တွေ့ရတာ အရမ်း ဝမ်းသာပါတယ်!';

  @override
  String get testVoice => 'အသံ စမ်းသပ်ပါ';

  @override
  String get start => 'စတင်ပါ';

  @override
  String get difficultyEasy => 'လွယ်ကူ';

  @override
  String get difficultyMedium => 'အလယ်အလတ်';

  @override
  String get difficultyHard => 'ခက်ခဲ';

  @override
  String difficultyLevel(int level) {
    return 'အဆင့် $level';
  }
}
