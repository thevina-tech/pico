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

  /// Bottom navigation Shop tab label
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get navShop;

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

  /// Button label for Google Sign-In on onboarding screen 2
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

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

  /// Informational helper text below selectors in personalization screen
  ///
  /// In en, this message translates to:
  /// **'You can change your favorite team and join more tournaments anytime.'**
  String get personalizationHelperNote;

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

  /// Button label to perform authentication and proceed
  ///
  /// In en, this message translates to:
  /// **'Sign in to Continue'**
  String get signInToContinue;

  /// Headline for username and auth step
  ///
  /// In en, this message translates to:
  /// **'What Should We Call You?'**
  String get step3AuthTitle;

  /// Subtitle for username and auth step
  ///
  /// In en, this message translates to:
  /// **'Pick a username for leaderboards and friend leagues.'**
  String get step3AuthSubtitle;

  /// Headline for team selection step
  ///
  /// In en, this message translates to:
  /// **'Choose Favorite Team'**
  String get chooseFavoriteTeamTitle;

  /// Subtitle for team selection step
  ///
  /// In en, this message translates to:
  /// **'Select your club to personalize your feed and upcoming matches.'**
  String get chooseFavoriteTeamSubtitle;

  /// Placeholder for team search field
  ///
  /// In en, this message translates to:
  /// **'Search clubs...'**
  String get searchTeamsPlaceholder;

  /// Headline for league selection step
  ///
  /// In en, this message translates to:
  /// **'Choose Leagues'**
  String get chooseLeaguesTitle;

  /// Subtitle for league selection step
  ///
  /// In en, this message translates to:
  /// **'Select 1 or 2 competitions to follow and compete in.'**
  String get chooseLeaguesSubtitle;

  /// Action button to finish onboarding
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishButton;

  /// Validation message when no team is selected
  ///
  /// In en, this message translates to:
  /// **'Please select 1 team to continue.'**
  String get oneTeamRequired;

  /// Validation message when no leagues are selected
  ///
  /// In en, this message translates to:
  /// **'Please select 1 or 2 leagues to continue.'**
  String get twoLeaguesRequired;

  /// Validation toast when attempting to select a 3rd league
  ///
  /// In en, this message translates to:
  /// **'You can select up to 2 leagues.'**
  String get maxLeaguesReached;

  /// Error message when username already exists in database
  ///
  /// In en, this message translates to:
  /// **'This username is already taken. Please choose another one.'**
  String get usernameTakenError;

  /// Badge showing 1 team selected
  ///
  /// In en, this message translates to:
  /// **'1/1 Selected'**
  String get selectedTeamBadge;

  /// Badge showing selected leagues count
  ///
  /// In en, this message translates to:
  /// **'{count}/2 Selected'**
  String leaguesSelectedBadge(int count);

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

  /// Empty state title for upcoming matches
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

  /// Sign out button label
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutButton;

  /// Title of the exit confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Exit App?'**
  String get exitDialogTitle;

  /// Message explaining consequences of quitting Pico
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit?'**
  String get exitDialogMessage;

  /// Primary action to stay in the game and keep predicting
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get exitDialogStayButton;

  /// Secondary action to exit/quit the game
  ///
  /// In en, this message translates to:
  /// **'Exit'**
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

  /// Predict match CTA button
  ///
  /// In en, this message translates to:
  /// **'PREDICT'**
  String get predictAction;

  /// Label for exact score prediction
  ///
  /// In en, this message translates to:
  /// **'Exact score'**
  String get exactScore;

  /// Headline for exact score prediction
  ///
  /// In en, this message translates to:
  /// **'Exact Score Prediction'**
  String get exactScoreTitle;

  /// Label for choosing match winner
  ///
  /// In en, this message translates to:
  /// **'Pick Winner'**
  String get pickWinner;

  /// Label for step 1 header in prediction bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Pick the Winner'**
  String get pickTheWinner;

  /// Question asking which team wins
  ///
  /// In en, this message translates to:
  /// **'Who wins?'**
  String get whoWins;

  /// Home team outcome label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeOutcome;

  /// Draw outcome label
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get drawOutcome;

  /// Away team outcome label
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get awayOutcome;

  /// Primary button to submit prediction
  ///
  /// In en, this message translates to:
  /// **'Save Prediction (+5 Points)'**
  String get savePredictionCta;

  /// Button to edit an existing prediction
  ///
  /// In en, this message translates to:
  /// **'Modify Prediction'**
  String get modifyPrediction;

  /// Title when a prediction is confirmed or locked
  ///
  /// In en, this message translates to:
  /// **'Prediction Locked! ⚽'**
  String get predictionLockedTitle;

  /// Status text when match prediction is locked
  ///
  /// In en, this message translates to:
  /// **'Prediction locked · Kickoff at {time}'**
  String predictionLockedBanner(String time);

  /// Error message when prediction window has closed
  ///
  /// In en, this message translates to:
  /// **'Predictions are closed for this match'**
  String get predictionWindowClosed;

  /// Helper text explaining 10-minute lock rule
  ///
  /// In en, this message translates to:
  /// **'Predictions lock exactly 10 minutes before kickoff.'**
  String get predictionLockNote;

  /// Header for points explanation
  ///
  /// In en, this message translates to:
  /// **'Potential Pico Points'**
  String get potentialPointsHeader;

  /// Breakdown of potential Pico Points
  ///
  /// In en, this message translates to:
  /// **'+5 for exact score · +3 for correct winner'**
  String get potentialPointsBreakdown;

  /// Inline prediction label
  ///
  /// In en, this message translates to:
  /// **'Quick Predict'**
  String get quickPredict;

  /// Confirmation toast after submitting prediction
  ///
  /// In en, this message translates to:
  /// **'Prediction locked in! Good luck.'**
  String get predictionSavedToast;

  /// Title for tournaments screen
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get tournamentsTitle;

  /// Subtitle for tournaments screen
  ///
  /// In en, this message translates to:
  /// **'Climb the leaderboards or compete with friends'**
  String get tournamentsSubtitle;

  /// Tab label for user's joined and owned leagues
  ///
  /// In en, this message translates to:
  /// **'My Leagues'**
  String get myLeaguesTab;

  /// Tab label for discovering public tournaments
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTab;

  /// Action button in tournaments header
  ///
  /// In en, this message translates to:
  /// **'+ Create / Join'**
  String get createOrJoinAction;

  /// Title for Create Private League screen
  ///
  /// In en, this message translates to:
  /// **'Create Private League'**
  String get createPrivateLeagueTitle;

  /// Subtitle for Create Private League screen
  ///
  /// In en, this message translates to:
  /// **'Compete against friends, banter, and crown your group champion.'**
  String get createPrivateLeagueSubtitle;

  /// Title for Join Private League screen
  ///
  /// In en, this message translates to:
  /// **'Join Private League'**
  String get joinPrivateLeagueTitle;

  /// Subtitle for Join Private League screen
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-character code shared by your friend.'**
  String get joinPrivateLeagueSubtitle;

  /// Label for league name input
  ///
  /// In en, this message translates to:
  /// **'LEAGUE NAME'**
  String get leagueNameLabel;

  /// Placeholder for league name input
  ///
  /// In en, this message translates to:
  /// **'e.g., Friday Football Kings'**
  String get leagueNamePlaceholder;

  /// Label for base competition dropdown selector
  ///
  /// In en, this message translates to:
  /// **'BASE TOURNAMENT / COMPETITION'**
  String get baseTournamentLabel;

  /// Helper note explaining base competition linkage
  ///
  /// In en, this message translates to:
  /// **'Matches and standings are linked to this competition.'**
  String get baseTournamentHelper;

  /// Badge in create league screen
  ///
  /// In en, this message translates to:
  /// **'Free Instant Setup'**
  String get freeSetupBadge;

  /// CTA button to create private league
  ///
  /// In en, this message translates to:
  /// **'Create Private League'**
  String get createLeagueButton;

  /// CTA button to join private league
  ///
  /// In en, this message translates to:
  /// **'Join Private League'**
  String get joinLeagueButton;

  /// Label for invite code input
  ///
  /// In en, this message translates to:
  /// **'ENTER 6-CHARACTER CODE'**
  String get enterLeagueCodeLabel;

  /// Button to paste from clipboard
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get pasteCode;

  /// Toast confirming code copied
  ///
  /// In en, this message translates to:
  /// **'Invite code copied to clipboard!'**
  String get codeCopiedToast;

  /// Message template to share invite code
  ///
  /// In en, this message translates to:
  /// **'Join my private league on Pico! Use code: {code}'**
  String shareInviteMessage(String code);

  /// Label for invite code badge
  ///
  /// In en, this message translates to:
  /// **'INVITE CODE'**
  String get inviteCodeLabel;

  /// Button to copy code
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCodeButton;

  /// Button to share code
  ///
  /// In en, this message translates to:
  /// **'Share Invite'**
  String get shareCodeButton;

  /// Empty state title when user has no private leagues
  ///
  /// In en, this message translates to:
  /// **'No Private Leagues Yet'**
  String get emptyPrivateLeaguesTitle;

  /// Empty state subtitle for private leagues
  ///
  /// In en, this message translates to:
  /// **'Create a league for your friends or join one with an invite code.'**
  String get emptyPrivateLeaguesSubtitle;

  /// Badge for public tournaments
  ///
  /// In en, this message translates to:
  /// **'PICO TOURNAMENT'**
  String get publicTournamentBadge;

  /// Success modal title after creating private league
  ///
  /// In en, this message translates to:
  /// **'League Created! 🎉'**
  String get leagueCreatedSuccessTitle;

  /// Success modal title after joining private league
  ///
  /// In en, this message translates to:
  /// **'You\'re In! ⚽'**
  String get leagueJoinedSuccessTitle;

  /// Success modal subtitle after joining private league
  ///
  /// In en, this message translates to:
  /// **'You have joined {leagueName}'**
  String leagueJoinedSuccessSubtitle(String leagueName);

  /// Error displayed when invite code is not found
  ///
  /// In en, this message translates to:
  /// **'Invalid invite code. Please check the code and try again.'**
  String get invalidLeagueCodeError;

  /// Error displayed when user is already in the league
  ///
  /// In en, this message translates to:
  /// **'You are already a member of this league.'**
  String get alreadyMemberOfLeagueError;

  /// Error displayed when creator tries to rejoin own league
  ///
  /// In en, this message translates to:
  /// **'You created this league and are already its owner.'**
  String get creatorCannotRejoinError;

  /// Validation error when invite code length is not 6
  ///
  /// In en, this message translates to:
  /// **'Code must be exactly 6 characters (e.g., K9X2P1)'**
  String get leagueCodeFormatError;

  /// Done action button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// Security note on private league creation
  ///
  /// In en, this message translates to:
  /// **'Only players with your invite code can join'**
  String get privateLeagueSecurityNote;

  /// Note under selected base competition
  ///
  /// In en, this message translates to:
  /// **'Base Competition'**
  String get baseTournamentNote;

  /// Count of available competitions
  ///
  /// In en, this message translates to:
  /// **'{count} available'**
  String competitionsAvailableCount(int count);

  /// Badge in join league screen
  ///
  /// In en, this message translates to:
  /// **'FRIENDS & COLLEAGUES'**
  String get friendsAndColleaguesBadge;

  /// Subtitle in join league screen
  ///
  /// In en, this message translates to:
  /// **'Private Community'**
  String get privateCommunitySubtitle;

  /// Title of the base tournament selection bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Select Base Tournament ({count} Available)'**
  String selectBaseTournamentSheetTitle(int count);

  /// App bar title for public tournament screen
  ///
  /// In en, this message translates to:
  /// **'Tournament Details'**
  String get tournamentDetailsTitle;

  /// App bar title for private tournament screen
  ///
  /// In en, this message translates to:
  /// **'Private League'**
  String get privateLeagueDetailsTitle;

  /// Header for the invite code banner
  ///
  /// In en, this message translates to:
  /// **'LEAGUE INVITE CODE'**
  String get inviteCodeBannerTitle;

  /// Subtitle encouraging sharing the league code
  ///
  /// In en, this message translates to:
  /// **'Share with friends to compete together'**
  String get inviteCodeBannerSubtitle;

  /// Share message for native share sheet
  ///
  /// In en, this message translates to:
  /// **'Join my private football prediction league \"{leagueName}\" on Pico! Use invite code: {code}'**
  String shareInviteCodeMessage(String leagueName, String code);

  /// Section header for owner admin controls
  ///
  /// In en, this message translates to:
  /// **'ADMIN CONTROLS'**
  String get adminControlsTitle;

  /// Button to delete a private league
  ///
  /// In en, this message translates to:
  /// **'Delete League'**
  String get deleteLeagueButton;

  /// Title of delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Private League?'**
  String get deleteLeagueConfirmTitle;

  /// Body of delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This action is permanent. All members will be removed and standings will be erased.'**
  String get deleteLeagueConfirmBody;

  /// Confirm button text for deleting league
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLeagueAction;

  /// Button to remove a member
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeMemberButton;

  /// Title of member removal dialog
  ///
  /// In en, this message translates to:
  /// **'Remove Member?'**
  String get removeMemberConfirmTitle;

  /// Body of member removal dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {username} from this league?'**
  String removeMemberConfirmBody(String username);

  /// Button to leave a private league
  ///
  /// In en, this message translates to:
  /// **'Leave League'**
  String get leaveLeagueButton;

  /// Title of leave confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Leave League?'**
  String get leaveLeagueConfirmTitle;

  /// Body of leave confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave {leagueName}? You will need the invite code to rejoin.'**
  String leaveLeagueConfirmBody(String leagueName);

  /// Confirm button text for leaving league
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveLeagueAction;

  /// Tab for standings / leaderboard
  ///
  /// In en, this message translates to:
  /// **'Standings'**
  String get leaderboardTab;

  /// Tab for tournament matches
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matchesTab;

  /// Section header for upcoming matches
  ///
  /// In en, this message translates to:
  /// **'Upcoming Matches'**
  String get upcomingMatchesSection;

  /// Section header for finished matches
  ///
  /// In en, this message translates to:
  /// **'Completed Matches'**
  String get finishedMatchesSection;

  /// Placeholder when leaderboard is empty
  ///
  /// In en, this message translates to:
  /// **'No participants yet'**
  String get noParticipantsYet;

  /// Placeholder when competition has no matches
  ///
  /// In en, this message translates to:
  /// **'No matches found for this competition'**
  String get noMatchesForCompetition;

  /// Toast when league is deleted
  ///
  /// In en, this message translates to:
  /// **'League deleted successfully'**
  String get leagueDeletedToast;

  /// Toast when member is removed
  ///
  /// In en, this message translates to:
  /// **'Member removed'**
  String get memberRemovedToast;

  /// Toast when user leaves league
  ///
  /// In en, this message translates to:
  /// **'You left the league'**
  String get leftLeagueToast;

  /// Badge for league creator
  ///
  /// In en, this message translates to:
  /// **'CREATOR'**
  String get creatorBadge;

  /// Badge for league member
  ///
  /// In en, this message translates to:
  /// **'MEMBER'**
  String get memberBadge;

  /// Generic cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Points abbreviation in leaderboard
  ///
  /// In en, this message translates to:
  /// **'PTS'**
  String get pointsAbbreviation;

  /// Header showing top 100 participants in public tournament leaderboard
  ///
  /// In en, this message translates to:
  /// **'TOP 100 PLAYERS'**
  String get top100LeaderboardHeader;

  /// Label for Pico Points currency in leaderboard
  ///
  /// In en, this message translates to:
  /// **'Pico Points'**
  String get picoPointsLabel;

  /// Header for rank column
  ///
  /// In en, this message translates to:
  /// **'RANK'**
  String get rankHeader;

  /// Header for player column
  ///
  /// In en, this message translates to:
  /// **'PLAYER'**
  String get playerHeader;

  /// Tab for matches currently in progress
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get feedTabLive;

  /// Tab for upcoming matches within 14 days
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get feedTabUpcoming;

  /// Tab for finished matches within last 7 days
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get feedTabFinished;

  /// Teaser countdown button label in days
  ///
  /// In en, this message translates to:
  /// **'Opens in {days}d'**
  String teaserOpensInDays(int days);

  /// Teaser countdown button label in hours
  ///
  /// In en, this message translates to:
  /// **'Opens in {hours}h'**
  String teaserOpensInHours(int hours);

  /// Teaser countdown button label in minutes
  ///
  /// In en, this message translates to:
  /// **'Opens in {minutes}m'**
  String teaserOpensInMinutes(int minutes);

  /// Subtext explaining when prediction window opens for teaser cards
  ///
  /// In en, this message translates to:
  /// **'Prediction window opens 3 days before kickoff'**
  String get teaserCountdownSubtext;

  /// Pico Points badge for exact score settlement
  ///
  /// In en, this message translates to:
  /// **'+5 Points'**
  String get pointsOutcomeExact;

  /// Pico Points badge for correct winner settlement
  ///
  /// In en, this message translates to:
  /// **'+3 Points'**
  String get pointsOutcomeWinner;

  /// Pico Points badge for incorrect prediction settlement
  ///
  /// In en, this message translates to:
  /// **'0 Points'**
  String get pointsOutcomeIncorrect;

  /// Badge when match finished without user prediction
  ///
  /// In en, this message translates to:
  /// **'No Prediction'**
  String get pointsOutcomeNone;

  /// Empty state title for live matches tab
  ///
  /// In en, this message translates to:
  /// **'No live matches right now'**
  String get noLiveMatches;

  /// Empty state subtitle for live matches tab
  ///
  /// In en, this message translates to:
  /// **'Check back during matchdays for real-time fixtures.'**
  String get noLiveMatchesSub;

  /// Empty state title for upcoming matches tab
  ///
  /// In en, this message translates to:
  /// **'No upcoming matches in the next 14 days'**
  String get feedNoUpcomingMatches;

  /// Empty state subtitle for upcoming matches tab
  ///
  /// In en, this message translates to:
  /// **'Upcoming fixtures will appear here once scheduled.'**
  String get noUpcomingMatchesSub;

  /// Empty state title for finished matches tab
  ///
  /// In en, this message translates to:
  /// **'No finished matches in the last 7 days'**
  String get noFinishedMatches;

  /// Empty state subtitle for finished matches tab
  ///
  /// In en, this message translates to:
  /// **'Recently concluded matches and points will be shown here.'**
  String get noFinishedMatchesSub;

  /// Eyebrow badge on the join tournament CTA banner
  ///
  /// In en, this message translates to:
  /// **'JOIN THE COMPETITION'**
  String get joinTournamentBannerBadge;

  /// Title on the join tournament CTA banner
  ///
  /// In en, this message translates to:
  /// **'Predict & Compete'**
  String get joinTournamentBannerTitle;

  /// Subtitle on the join tournament CTA banner
  ///
  /// In en, this message translates to:
  /// **'Join this tournament to predict upcoming matches, score Pico Points, and climb the public standings.'**
  String get joinTournamentBannerSub;

  /// Action button text to enroll in tournament
  ///
  /// In en, this message translates to:
  /// **'Join Tournament'**
  String get joinTournamentAction;

  /// Success message after enrolling in tournament
  ///
  /// In en, this message translates to:
  /// **'You joined {tournamentName}! Predictions unlocked.'**
  String joinTournamentSuccessToast(String tournamentName);

  /// Badge indicating user is already joined in tournament
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joinedBadge;

  /// Short join action label
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinAction;

  /// Banner message on matches tab when user is in preview mode
  ///
  /// In en, this message translates to:
  /// **'Preview Mode · Join this tournament to unlock predictions'**
  String get previewModeBanner;

  /// Button label when user needs to join to predict
  ///
  /// In en, this message translates to:
  /// **'Join to Predict'**
  String get joinAndPredictAction;

  /// Prompt when unauthenticated user tries to join tournament
  ///
  /// In en, this message translates to:
  /// **'Sign in to join tournaments and submit predictions.'**
  String get signInToJoinTournament;

  /// Secondary button label in prediction sheet to view full match page
  ///
  /// In en, this message translates to:
  /// **'View Full Prediction Page →'**
  String get viewFullPredictionPage;

  /// Banner explaining scoring rule in prediction sheet
  ///
  /// In en, this message translates to:
  /// **'Exact score = +5 Pico Points · Correct winner = +3 Pico Points'**
  String get scoringRuleBanner;

  /// Toast message after saving prediction from bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Prediction locked in! (+5 Points) ⚽'**
  String get predictionLockedSuccessToast;

  /// Error toast when saving prediction fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save prediction. Please try again.'**
  String get predictionSaveFailed;

  /// Label for disabled button on finished matches
  ///
  /// In en, this message translates to:
  /// **'Match Finished'**
  String get matchFinishedLabel;

  /// Tab or filter chip for all matches
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get feedTabAll;

  /// Text indicating kickoff lock time
  ///
  /// In en, this message translates to:
  /// **'Locks {time}'**
  String matchLocksAt(String time);

  /// Sub-label for total matches card in profile
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get matchesTotalSub;

  /// Best streak indicator in profile
  ///
  /// In en, this message translates to:
  /// **'Best: {count}'**
  String bestStreak(int count);

  /// Positive hit rate trend
  ///
  /// In en, this message translates to:
  /// **'↑ +{rate}%'**
  String hitRateTrendUp(int rate);

  /// Section title for Achievements
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// See all button label
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Title for on fire achievement badge
  ///
  /// In en, this message translates to:
  /// **'On Fire'**
  String get achievementOnFireTitle;

  /// Description for on fire achievement badge
  ///
  /// In en, this message translates to:
  /// **'{count} streak'**
  String achievementOnFireDesc(int count);

  /// Title for sharpshooter achievement badge
  ///
  /// In en, this message translates to:
  /// **'Sharpshooter'**
  String get achievementSharpshooterTitle;

  /// Description for sharpshooter achievement badge
  ///
  /// In en, this message translates to:
  /// **'{rate}% hit rate'**
  String achievementSharpshooterDesc(int rate);

  /// Title for podium finisher achievement badge
  ///
  /// In en, this message translates to:
  /// **'Podium'**
  String get achievementPodiumTitle;

  /// Description for podium finisher achievement badge
  ///
  /// In en, this message translates to:
  /// **'{count} podiums'**
  String achievementPodiumDesc(int count);

  /// Title for 10 streak achievement badge
  ///
  /// In en, this message translates to:
  /// **'10 Streak'**
  String get achievementStreak10Title;

  /// Locked indicator for achievement badge
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get achievementLockedLabel;

  /// Title for Help & Support quick action
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupportTitle;

  /// Subtitle for Help & Support quick action
  ///
  /// In en, this message translates to:
  /// **'Rules, scoring guide & contact'**
  String get helpAndSupportSubtitle;

  /// Aria label for account settings icon button
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettingsAria;

  /// Title for game rules dialog
  ///
  /// In en, this message translates to:
  /// **'Game Rules & Scoring'**
  String get picoRulesTitle;

  /// Subtitle for game rules dialog
  ///
  /// In en, this message translates to:
  /// **'Fair play, server-side locks & transparent scoring'**
  String get picoRulesSubtitle;

  /// Title for Division 10 (0-49 PP)
  ///
  /// In en, this message translates to:
  /// **'Division 10'**
  String get division10Title;

  /// Title for Division 9 (50-119 PP)
  ///
  /// In en, this message translates to:
  /// **'Division 9'**
  String get division9Title;

  /// Title for Division 8 (120-219 PP)
  ///
  /// In en, this message translates to:
  /// **'Division 8'**
  String get division8Title;

  /// Title for Division 7 (220-349 PP)
  ///
  /// In en, this message translates to:
  /// **'Division 7'**
  String get division7Title;

  /// Title for Division 6 (350-499 PP)
  ///
  /// In en, this message translates to:
  /// **'Division 6'**
  String get division6Title;

  /// Title for Division 5 (500-699 PP)
  ///
  /// In en, this message translates to:
  /// **'Division 5'**
  String get division5Title;

  /// Title for Division 4 (700-949 PP)
  ///
  /// In en, this message translates to:
  /// **'Division 4'**
  String get division4Title;

  /// Title for Division 3 (950-1249 PP)
  ///
  /// In en, this message translates to:
  /// **'Division 3'**
  String get division3Title;

  /// Title for Division 2 (1250-1599 PP)
  ///
  /// In en, this message translates to:
  /// **'Division 2'**
  String get division2Title;

  /// Title for Division 1 (1600-1999 PP)
  ///
  /// In en, this message translates to:
  /// **'Division 1'**
  String get division1Title;

  /// Title for Elite Division (2000+ PP)
  ///
  /// In en, this message translates to:
  /// **'Elite Division'**
  String get divisionEliteTitle;

  /// Label for unified Prediction Points currency
  ///
  /// In en, this message translates to:
  /// **'Prediction Points'**
  String get predictionPointsLabel;

  /// Abbreviation for Prediction Points
  ///
  /// In en, this message translates to:
  /// **'PP'**
  String get predictionPointsAbbr;

  /// Label for current division tier
  ///
  /// In en, this message translates to:
  /// **'Current Division'**
  String get currentDivisionLabel;

  /// Title for division ladder section or view
  ///
  /// In en, this message translates to:
  /// **'Division Ladder'**
  String get divisionLadderTitle;

  /// Subtitle describing the division ladder system
  ///
  /// In en, this message translates to:
  /// **'Climb tiers with accurate match predictions'**
  String get divisionLadderSubtitle;

  /// Progress towards the next division
  ///
  /// In en, this message translates to:
  /// **'{current} / {target} pts to {nextDivision}'**
  String pointsToNextDivisionThreshold(
    String current,
    String target,
    String nextDivision,
  );

  /// Remaining points needed for next division
  ///
  /// In en, this message translates to:
  /// **'{points} pts to {nextDivision}'**
  String pointsToNextDivision(String points, String nextDivision);

  /// Display text when user has achieved Elite Division
  ///
  /// In en, this message translates to:
  /// **'{points} pts (Elite Division)'**
  String eliteDivisionStatus(String points);

  /// Points outcome badge for correct winner and goal difference
  ///
  /// In en, this message translates to:
  /// **'+3 Points'**
  String get pointsOutcomeGoalDiff;

  /// Points outcome badge for correct winner only
  ///
  /// In en, this message translates to:
  /// **'+1 Point'**
  String get pointsOutcomeOne;

  /// Compact scoring rules explanation
  ///
  /// In en, this message translates to:
  /// **'Exact = +5 PP · Outcome + Diff = +3 PP · Outcome = +1 PP'**
  String get scoringRuleBannerSprint7;

  /// Subtitle describing the sign out option
  ///
  /// In en, this message translates to:
  /// **'Log out of your Pico session'**
  String get signOutSubtitle;

  /// Title for the settings screen and profile menu option
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Subtitle for the settings option on profile screen
  ///
  /// In en, this message translates to:
  /// **'Account, sign out & preferences'**
  String get settingsSubtitle;

  /// Label for the share the app button on profile screen
  ///
  /// In en, this message translates to:
  /// **'Share the App'**
  String get shareTheAppButton;

  /// Default text shared when user taps Share the App
  ///
  /// In en, this message translates to:
  /// **'Join me on Pico to predict football matches! https://play.google.com/store/apps/details?id=com.devdaumienebi.yonunca'**
  String get shareAppMessage;

  /// Menu title for deleting the user's account
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountOption;

  /// Subtitle describing the destructive nature of delete account
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account and data'**
  String get deleteAccountSubtitle;

  /// Title for the destructive account deletion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountConfirmTitle;

  /// Body message for the destructive account deletion confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This will permanently delete your predictions, league memberships, and account data. This cannot be undone.'**
  String get deleteAccountConfirmBody;

  /// Button label to confirm account deletion
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountAction;

  /// Error message when account deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account. Please try again.'**
  String get deleteAccountError;

  /// Toast message confirming account deletion
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get accountDeletedToast;

  /// Menu title for GDPR/CPRA ad choices and consent management
  ///
  /// In en, this message translates to:
  /// **'Ad Choices & Privacy'**
  String get adChoicesTitle;

  /// Subtitle explaining the user can modify ad personalization preferences
  ///
  /// In en, this message translates to:
  /// **'Review or change your ad personalization consent'**
  String get adChoicesSubtitle;

  /// Header title for Pico scoring rules breakdown
  ///
  /// In en, this message translates to:
  /// **'PICO SCORING RULES'**
  String get picoScoringRules;

  /// Label for exact score prediction outcome
  ///
  /// In en, this message translates to:
  /// **'Exact Score'**
  String get scoringRuleExactTitle;

  /// Description for exact score outcome
  ///
  /// In en, this message translates to:
  /// **'Predict the exact final scoreline'**
  String get scoringRuleExactDesc;

  /// Label for outcome plus goal difference prediction
  ///
  /// In en, this message translates to:
  /// **'Winner + Goal Diff'**
  String get scoringRuleGoalDiffTitle;

  /// Description for outcome plus goal difference
  ///
  /// In en, this message translates to:
  /// **'Correct winner and goal margin'**
  String get scoringRuleGoalDiffDesc;

  /// Label for correct winner outcome
  ///
  /// In en, this message translates to:
  /// **'Correct Winner'**
  String get scoringRuleWinnerOnlyTitle;

  /// Description for correct winner outcome
  ///
  /// In en, this message translates to:
  /// **'Correct winner, other scoreline'**
  String get scoringRuleWinnerOnlyDesc;

  /// Error message when private league has reached member limit
  ///
  /// In en, this message translates to:
  /// **'This league is full (Max 25 members).'**
  String get leagueCapacityReachedError;

  /// Error validation for private league name length
  ///
  /// In en, this message translates to:
  /// **'League name must be between 3 and 30 characters.'**
  String get leagueNameLengthError;

  /// Success snackbar message when private league is created
  ///
  /// In en, this message translates to:
  /// **'League created successfully!'**
  String get leagueCreatedSuccessToast;

  /// Validation message when username contains non-alphanumeric characters or spaces
  ///
  /// In en, this message translates to:
  /// **'Username must be alphanumeric with no spaces'**
  String get usernameAlphanumericError;

  /// Error when store link fails to open
  ///
  /// In en, this message translates to:
  /// **'Could not open store link.'**
  String get couldNotOpenStoreLink;

  /// Error when email client cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open email client. Contact: {email}'**
  String couldNotOpenEmailClient(String email);

  /// Snackbar prompt asking user to sign in with Google
  ///
  /// In en, this message translates to:
  /// **'Please sign in with Google to continue.'**
  String get signInWithGooglePrompt;

  /// Snackbar prompt asking user to sign in with Google to finish setup
  ///
  /// In en, this message translates to:
  /// **'Please sign in with Google to complete your account setup.'**
  String get signInWithGoogleSetupPrompt;

  /// Error message when teams list cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load teams: {error}'**
  String failedToLoadTeams(String error);

  /// Error message when competitions list cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Failed to load competitions: {error}'**
  String failedToLoadCompetitions(String error);

  /// Empty state search message for clubs
  ///
  /// In en, this message translates to:
  /// **'No clubs found matching \"{query}\"'**
  String noClubsFound(String query);

  /// Error when league deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete league: {error}'**
  String failedToDeleteLeague(String error);

  /// Error when leaving league fails
  ///
  /// In en, this message translates to:
  /// **'Failed to leave league: {error}'**
  String failedToLeaveLeague(String error);

  /// Success message when an admin kicks a member
  ///
  /// In en, this message translates to:
  /// **'{username} has been removed from the league.'**
  String memberRemovedFromLeague(String username);

  /// Error when removing a member fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove member: {error}'**
  String failedToKickMember(String error);

  /// Error message when sending chat message fails
  ///
  /// In en, this message translates to:
  /// **'Failed to send message: {error}'**
  String failedToSendMessage(String error);

  /// Error message when sign out fails
  ///
  /// In en, this message translates to:
  /// **'Sign out failed: {error}'**
  String signOutFailed(String error);

  /// Greeting message on home screen
  ///
  /// In en, this message translates to:
  /// **'Hey {username}! 👋'**
  String homeGreeting(String username);

  /// Call to action message under greeting on home screen
  ///
  /// In en, this message translates to:
  /// **'Ready to predict today\'s biggest clash?'**
  String get homeReadyToPredict;
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
