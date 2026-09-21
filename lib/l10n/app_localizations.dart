import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('en'),
    Locale('es'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Pico'**
  String get appTitle;

  /// Label for the predict CTA button
  ///
  /// In en, this message translates to:
  /// **'Predict'**
  String get predictButton;

  /// Bottom navigation Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation Matches tab label
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get navMatches;

  /// Bottom navigation Tournaments tab label
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get navTournaments;

  /// Bottom navigation Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Kickoff deadline hint
  ///
  /// In en, this message translates to:
  /// **'Predict by {time}'**
  String predictBy(String time);

  /// Headline for the onboarding welcome screen
  ///
  /// In en, this message translates to:
  /// **'Predict Football.\nCompete with Friends.'**
  String get onboardingWelcomeTitle;

  /// Subtitle describing the value proposition
  ///
  /// In en, this message translates to:
  /// **'Call match scores, bank Pico Points, and battle your friends on private & global leaderboards.'**
  String get onboardingWelcomeSubtitle;

  /// CTA button label to start guest mode
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStartedButton;

  /// Hint reassuring the user about setup speed
  ///
  /// In en, this message translates to:
  /// **'Takes less than 1 minute to set up.'**
  String get setupSpeedHint;

  /// Title for Onboarding Screen 2 explaining How Pico Works
  ///
  /// In en, this message translates to:
  /// **'How Pico Works'**
  String get howPicoWorksTitle;

  /// Subtitle for How Pico Works explainer screen
  ///
  /// In en, this message translates to:
  /// **'Simple, fast, and built for matchdays.'**
  String get howPicoWorksSubtitle;

  /// Title for concept 1 in How Pico Works
  ///
  /// In en, this message translates to:
  /// **'Predict the score'**
  String get step1Title;

  /// Description for concept 1 in How Pico Works
  ///
  /// In en, this message translates to:
  /// **'Quick picks before kickoff'**
  String get step1Description;

  /// Title for concept 2 in How Pico Works
  ///
  /// In en, this message translates to:
  /// **'Earn points & climb'**
  String get step2Title;

  /// Description for concept 2 in How Pico Works
  ///
  /// In en, this message translates to:
  /// **'Score accurate calls each week'**
  String get step2Description;

  /// Title for concept 3 in How Pico Works
  ///
  /// In en, this message translates to:
  /// **'Win tournament trophies'**
  String get step3Title;

  /// Description for concept 3 in How Pico Works
  ///
  /// In en, this message translates to:
  /// **'Top friends and global ranks'**
  String get step3Description;

  /// Hint beneath CTA button indicating next step
  ///
  /// In en, this message translates to:
  /// **'Next: Pick your favorite starting team (15 sec)'**
  String get nextStepHint;

  /// Segmented step counter in onboarding
  ///
  /// In en, this message translates to:
  /// **'STEP {current}/{total}'**
  String stepIndicator(int current, int total);

  /// Title of the personalization screen
  ///
  /// In en, this message translates to:
  /// **'Pick Your Favorites'**
  String get personalizationTitle;

  /// Subtitle of the personalization screen
  ///
  /// In en, this message translates to:
  /// **'Choose your username and follow your favorite clubs & leagues.'**
  String get personalizationSubtitle;

  /// Small uppercase kicker above personalization title
  ///
  /// In en, this message translates to:
  /// **'CUSTOMIZE YOUR FEED'**
  String get customizeFeedKicker;

  /// Label for the username text input
  ///
  /// In en, this message translates to:
  /// **'Choose a Username'**
  String get usernameLabel;

  /// Placeholder hint for username text input
  ///
  /// In en, this message translates to:
  /// **'e.g. joao_striker'**
  String get usernamePlaceholder;

  /// Error when username is blank
  ///
  /// In en, this message translates to:
  /// **'Please introduce a username to continue.'**
  String get usernameErrorEmpty;

  /// Error when username is fewer than 3 chars
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameErrorTooShort;

  /// Section header for leagues selection
  ///
  /// In en, this message translates to:
  /// **'Top Leagues & Cups'**
  String get topLeaguesTitle;

  /// Section header for clubs selection
  ///
  /// In en, this message translates to:
  /// **'Clubs You Follow'**
  String get clubsFollowTitle;

  /// Primary continue action button label
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Action label to skip step
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// Small footer note under continue button
  ///
  /// In en, this message translates to:
  /// **'Preferences sync instantly across Pico League'**
  String get preferencesSyncHint;

  /// Loading indicator text when saving profile
  ///
  /// In en, this message translates to:
  /// **'Saving your profile...'**
  String get savingPreferences;

  /// Daily greeting from the Pico mascot
  ///
  /// In en, this message translates to:
  /// **'Big match tonight, {username}! ⚽'**
  String mascotGreeting(String username);

  /// Header title for the upcoming matches list
  ///
  /// In en, this message translates to:
  /// **'Upcoming Matches'**
  String get upcomingMatchesTitle;

  /// Empty state text for matches feed
  ///
  /// In en, this message translates to:
  /// **'No upcoming matches right now. Check back soon!'**
  String get noUpcomingMatches;

  /// Action label to retry a failed network request
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// Title of the home hamburger menu
  ///
  /// In en, this message translates to:
  /// **'Settings & Menu'**
  String get homeMenuTitle;

  /// Action label to sign out
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutButton;

  /// Title of the exit confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Leaving the Pitch?'**
  String get exitDialogTitle;

  /// Message explaining consequences of quitting Pico
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to quit Pico? Upcoming matches and predictions are waiting for you!'**
  String get exitDialogMessage;

  /// Primary action to stay in the game and keep predicting
  ///
  /// In en, this message translates to:
  /// **'STAY & PREDICT'**
  String get exitDialogStayButton;

  /// Secondary action to exit/quit the game
  ///
  /// In en, this message translates to:
  /// **'Leave Game'**
  String get exitDialogLeaveButton;

  /// Section header for the single featured match on Home
  ///
  /// In en, this message translates to:
  /// **'Match of the Day'**
  String get matchOfTheDayTitle;

  /// Action label to view all matches on the Matches screen
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAllMatches;

  /// Banner text indicating remaining fixtures in the Matches screen
  ///
  /// In en, this message translates to:
  /// **'+{count} more fixtures in Matches'**
  String moreMatchesAvailable(int count);

  /// Tactical rank title under username in profile trading card
  ///
  /// In en, this message translates to:
  /// **'Matchday Prophet'**
  String get profileTitleKicker;

  /// Label for accuracy stat in profile
  ///
  /// In en, this message translates to:
  /// **'Hit Rate'**
  String get hitRateLabel;

  /// Label for total matches stat in profile
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matchesLabel;

  /// Label for podium finishes stat in profile
  ///
  /// In en, this message translates to:
  /// **'Podiums'**
  String get podiumsLabel;

  /// Label for club leaderboard rank in profile
  ///
  /// In en, this message translates to:
  /// **'Club Rank'**
  String get clubRankLabel;

  /// XP progress title showing next level
  ///
  /// In en, this message translates to:
  /// **'XP Progress to LVL {level}'**
  String xpProgressToLevel(int level);

  /// Title of the Tournaments accordion section
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get tournamentsAccordionTitle;

  /// Subtitle of the Tournaments accordion section
  ///
  /// In en, this message translates to:
  /// **'Active cups & weekly leagues'**
  String get tournamentsAccordionSubtitle;

  /// Badge showing active tournaments count
  ///
  /// In en, this message translates to:
  /// **'{count} Active'**
  String tournamentsActiveCount(int count);

  /// Title of the Following accordion section
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingAccordionTitle;

  /// Subtitle of the Following accordion section
  ///
  /// In en, this message translates to:
  /// **'Clubs, leagues & priority alerts'**
  String get followingAccordionSubtitle;

  /// Badge showing pinned items count
  ///
  /// In en, this message translates to:
  /// **'{count} Pinned'**
  String followingPinnedCount(int count);

  /// Title of the History accordion section
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyAccordionTitle;

  /// Subtitle of the History accordion section
  ///
  /// In en, this message translates to:
  /// **'Predictions slip archive & past trophies'**
  String get historyAccordionSubtitle;

  /// Badge in history accordion header
  ///
  /// In en, this message translates to:
  /// **'{count} Matches · {rate}%'**
  String historySummary(int count, int rate);

  /// Header for recent prediction form strip
  ///
  /// In en, this message translates to:
  /// **'Recent Form (Last 10 Matches)'**
  String get recentFormTitle;

  /// Sub-header summary for recent form
  ///
  /// In en, this message translates to:
  /// **'{wins} Wins · {exact} Exact'**
  String recentFormSummary(int wins, int exact);

  /// Title of Settings accordion section
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsAccordionTitle;

  /// Subtitle of Settings accordion section
  ///
  /// In en, this message translates to:
  /// **'Preferences, sound & notifications'**
  String get settingsAccordionSubtitle;

  /// Title of push notification setting
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotificationsTitle;

  /// Title of matchday haptics setting
  ///
  /// In en, this message translates to:
  /// **'Matchday Haptics'**
  String get matchdayHapticsTitle;

  /// Enabled status pill
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabledPill;

  /// On status pill
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get onPill;

  /// CTA button label to share profile card
  ///
  /// In en, this message translates to:
  /// **'Share Matchday Card'**
  String get shareMatchdayCard;

  /// Title of the share trading card bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Matchday Trading Card'**
  String get shareCardModalTitle;

  /// Prompt text in the share card sheet
  ///
  /// In en, this message translates to:
  /// **'Share your Pico profile card and stats with friends!'**
  String get shareCardPrompt;

  /// Button to copy trading card summary
  ///
  /// In en, this message translates to:
  /// **'Copy Card Summary'**
  String get copyProfileSummary;

  /// Snackbar feedback after copying summary
  ///
  /// In en, this message translates to:
  /// **'Profile summary copied to clipboard!'**
  String get profileSummaryCopied;

  /// Standings link button label
  ///
  /// In en, this message translates to:
  /// **'Standings'**
  String get standingsButton;

  /// Points earned badge
  ///
  /// In en, this message translates to:
  /// **'+{points} Pts'**
  String pointsEarnedBadge(int points);

  /// Streak indicator pill
  ///
  /// In en, this message translates to:
  /// **'{count} Streak'**
  String streakPill(int count);

  /// Coins indicator pill
  ///
  /// In en, this message translates to:
  /// **'{count} Coins'**
  String coinsPill(String count);

  /// Level badge text
  ///
  /// In en, this message translates to:
  /// **'LVL {level}'**
  String levelPill(int level);
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
