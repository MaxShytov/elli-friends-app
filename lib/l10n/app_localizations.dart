import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_my.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('it'),
    Locale('my'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Elli & Friends'**
  String get appTitle;

  /// Welcome message on home screen
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m Elli!'**
  String get homeWelcome;

  /// Subtitle on home screen
  ///
  /// In en, this message translates to:
  /// **'Let\'s learn together!'**
  String get homeSubtitle;

  /// No description provided for @btnLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get btnLessons;

  /// No description provided for @btnGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get btnGames;

  /// No description provided for @btnProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get btnProgress;

  /// No description provided for @btnSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get btnSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsMusic;

  /// No description provided for @settingsSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get settingsSoundEffects;

  /// No description provided for @settingsVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get settingsVoice;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @languageBurmese.
  ///
  /// In en, this message translates to:
  /// **'မြန်မာ'**
  String get languageBurmese;

  /// No description provided for @lessonCounting.
  ///
  /// In en, this message translates to:
  /// **'Counting'**
  String get lessonCounting;

  /// No description provided for @lessonAlphabet.
  ///
  /// In en, this message translates to:
  /// **'Alphabet'**
  String get lessonAlphabet;

  /// No description provided for @lessonShapes.
  ///
  /// In en, this message translates to:
  /// **'Shapes'**
  String get lessonShapes;

  /// No description provided for @lessonColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get lessonColors;

  /// No description provided for @gameCountingTitle.
  ///
  /// In en, this message translates to:
  /// **'Counting Game'**
  String get gameCountingTitle;

  /// No description provided for @gameStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get gameStart;

  /// No description provided for @gameRestart.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get gameRestart;

  /// No description provided for @feedbackCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get feedbackCorrect;

  /// No description provided for @feedbackWrong.
  ///
  /// In en, this message translates to:
  /// **'Try again!'**
  String get feedbackWrong;

  /// No description provided for @feedbackGreatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get feedbackGreatJob;

  /// No description provided for @progressStars.
  ///
  /// In en, this message translates to:
  /// **'Stars earned'**
  String get progressStars;

  /// No description provided for @progressLessonsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Lessons completed'**
  String get progressLessonsCompleted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'it', 'my'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
