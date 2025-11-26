import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_my.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('it'),
    Locale('my'),
    Locale('ru'),
  ];

  /// Settings button label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Activity title for learning numbers
  ///
  /// In en, this message translates to:
  /// **'Learn Numbers'**
  String get learnNumbers;

  /// Activity title for learning subtraction
  ///
  /// In en, this message translates to:
  /// **'Subtraction'**
  String get learnSubtraction;

  /// Activity title for learning letters
  ///
  /// In en, this message translates to:
  /// **'Learn Letters'**
  String get learnLetters;

  /// Activity title for learning shapes
  ///
  /// In en, this message translates to:
  /// **'Learn Shapes'**
  String get learnShapes;

  /// Activity title for learning colors
  ///
  /// In en, this message translates to:
  /// **'Learn Colors'**
  String get learnColors;

  /// Greeting message
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// Character tap prompt
  ///
  /// In en, this message translates to:
  /// **'Tap me!'**
  String get tapMe;

  /// Language settings section title
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// Language selection prompt
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get selectLanguage;

  /// Language change confirmation message
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChanged(String language);

  /// Demo counting lesson button label
  ///
  /// In en, this message translates to:
  /// **'🦋 Lesson: Counting (Demo)'**
  String get lessonCountingDemo;

  /// Loading message for lesson page
  ///
  /// In en, this message translates to:
  /// **'Loading lesson...'**
  String get loadingLesson;

  /// Error message when lesson fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading lesson'**
  String get lessonLoadError;

  /// Try again button label
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Skip button label
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No data available message
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// Lesson scenes count header
  ///
  /// In en, this message translates to:
  /// **'Lesson Scenes ({count})'**
  String lessonScenes(int count);

  /// Character label
  ///
  /// In en, this message translates to:
  /// **'Character'**
  String get character;

  /// Pause scene indicator
  ///
  /// In en, this message translates to:
  /// **'⏸️ Pause'**
  String get pause;

  /// Generic scene label
  ///
  /// In en, this message translates to:
  /// **'Scene'**
  String get scene;

  /// Start lesson button label
  ///
  /// In en, this message translates to:
  /// **'Start Lesson'**
  String get startLesson;

  /// Coming soon message for interactive features
  ///
  /// In en, this message translates to:
  /// **'Coming soon: Interactive lesson playback! 🎉'**
  String get comingSoon;

  /// Topic label
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get topic;

  /// Level/difficulty label
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// Lesson label
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get lesson;

  /// Next button label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Correct answer feedback
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// Completion dialog title
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get excellent;

  /// Stars earned message
  ///
  /// In en, this message translates to:
  /// **'You earned {stars} stars!'**
  String youEarnedStars(int stars);

  /// Out of separator for scores
  ///
  /// In en, this message translates to:
  /// **'out of'**
  String get outOf;

  /// Done button label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Play again button label
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get again;

  /// Elli's greeting on home screen
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m Elli the Elephant!'**
  String get elliGreeting;

  /// Elli's encouraging message
  ///
  /// In en, this message translates to:
  /// **'Let\'s learn together!'**
  String get letsTogether;

  /// Prompt to choose an activity
  ///
  /// In en, this message translates to:
  /// **'Choose an activity!'**
  String get chooseActivity;

  /// Elli's happy greeting
  ///
  /// In en, this message translates to:
  /// **'I\'m so happy to see you!'**
  String get happyToSee;

  /// Button to test TTS voice
  ///
  /// In en, this message translates to:
  /// **'Test Voice'**
  String get testVoice;

  /// Start button label for lessons
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Easy difficulty level
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// Medium difficulty level
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// Hard difficulty level
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// Generic difficulty level
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String difficultyLevel(int level);

  /// Orson's character greeting
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m Orson the purple cat'**
  String get orsonGreeting;

  /// Merv's character greeting
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m Merv the yellow puppy'**
  String get mervGreeting;

  /// Developer settings section title
  ///
  /// In en, this message translates to:
  /// **'Developer Settings'**
  String get developerSettings;

  /// Reset lesson data button label
  ///
  /// In en, this message translates to:
  /// **'Reset Lesson Data'**
  String get resetLessonData;

  /// Reset data confirmation message
  ///
  /// In en, this message translates to:
  /// **'Reset all lesson data to defaults?'**
  String get resetLessonDataConfirm;

  /// Data reset success message
  ///
  /// In en, this message translates to:
  /// **'Data reset successfully'**
  String get resetSuccess;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Reset button label
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'am',
    'de',
    'en',
    'fr',
    'it',
    'my',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'my':
      return AppLocalizationsMy();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
