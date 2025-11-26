// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get settings => 'ቅንብሮች';

  @override
  String get learnNumbers => 'ቁጥሮችን ተማር';

  @override
  String get learnSubtraction => 'መቀነስ';

  @override
  String get learnLetters => 'ፊደሎችን ተማር';

  @override
  String get learnShapes => 'ቅርጾችን ተማር';

  @override
  String get learnColors => 'ቀለሞችን ተማር';

  @override
  String get hello => 'ሰላም!';

  @override
  String get tapMe => 'ንካኝ!';

  @override
  String get languageSettings => 'የቋንቋ ቅንብሮች';

  @override
  String get selectLanguage => 'ቋንቋህን ምረጥ';

  @override
  String languageChanged(String language) {
    return 'ቋንቋ ወደ $language ተቀይሯል';
  }

  @override
  String get lessonCountingDemo => '🦋 ትምህርት: መቁጠር (ማሳያ)';

  @override
  String get loadingLesson => 'ትምህርት በመጫን ላይ...';

  @override
  String get lessonLoadError => 'ትምህርቱን በመጫን ላይ ስህተት';

  @override
  String get tryAgain => 'እንደገና ሞክር';

  @override
  String get skip => 'ዝለል';

  @override
  String get noData => 'መረጃ የለም';

  @override
  String lessonScenes(int count) {
    return 'የትምህርት ትዕይንቶች ($count)';
  }

  @override
  String get character => 'ገጸ ባህርይ';

  @override
  String get pause => '⏸️ ቆም';

  @override
  String get scene => 'ትዕይንት';

  @override
  String get startLesson => 'ትምህርት ጀምር';

  @override
  String get comingSoon => 'በቅርቡ: መስተጋብራዊ ትምህርት! 🎉';

  @override
  String get topic => 'ርዕስ';

  @override
  String get level => 'ደረጃ';

  @override
  String get lesson => 'ትምህርት';

  @override
  String get next => 'ቀጣይ';

  @override
  String get back => 'ተመለስ';

  @override
  String get correct => 'ትክክል!';

  @override
  String get excellent => 'እጅግ በጣም ጥሩ!';

  @override
  String youEarnedStars(int stars) {
    return '$stars ኮከቦች አግኝተሃል!';
  }

  @override
  String get outOf => 'ከ';

  @override
  String get done => 'ተጠናቀቀ';

  @override
  String get again => 'እንደገና ሞክር';

  @override
  String get elliGreeting => 'ሰላም! እኔ ኤሊ ዝሆን ነኝ!';

  @override
  String get letsTogether => 'አብረን እንማር!';

  @override
  String get chooseActivity => 'እንቅስቃሴ ምረጥ!';

  @override
  String get happyToSee => 'ስላየሁህ በጣም ደስ ብሎኛል!';

  @override
  String get testVoice => 'ድምጽ ሞክር';

  @override
  String get start => 'ጀምር';

  @override
  String get difficultyEasy => 'ቀላል';

  @override
  String get difficultyMedium => 'መካከለኛ';

  @override
  String get difficultyHard => 'ከባድ';

  @override
  String difficultyLevel(int level) {
    return 'ደረጃ $level';
  }

  @override
  String get orsonGreeting => 'ሰላም፣ እኔ ኦርሰን ወይን ጥቁር ድመት ነኝ';

  @override
  String get mervGreeting => 'ሰላም፣ እኔ ሜርቭ ቢጫ ቡችላ ነኝ';

  @override
  String get developerSettings => 'የገንቢ ቅንብሮች';

  @override
  String get resetLessonData => 'የትምህርት መረጃ ዳግም አስጀምር';

  @override
  String get resetLessonDataConfirm => 'ሁሉንም የትምህርት መረጃ ወደ ነባሪ ዳግም ያስጀምር?';

  @override
  String get resetSuccess => 'መረጃ በተሳካ ሁኔታ ዳግም ተጀምሯል';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String get reset => 'ዳግም አስጀምር';
}
