// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pico';

  @override
  String get predictButton => 'Predict';

  @override
  String get navHome => 'Home';

  @override
  String get navMatches => 'Matches';

  @override
  String get navTournaments => 'Tournaments';

  @override
  String get navProfile => 'Profile';

  @override
  String predictBy(String time) {
    return 'Predict by $time';
  }

  @override
  String get onboardingWelcomeTitle =>
      'Predict Football.\nCompete with Friends.';

  @override
  String get onboardingWelcomeSubtitle =>
      'Call match scores, bank Pico Points, and battle your friends on private & global leaderboards.';

  @override
  String get getStartedButton => 'Get Started';

  @override
  String get setupSpeedHint => 'Takes less than 1 minute to set up.';

  @override
  String get howPicoWorksTitle => 'How Pico Works';

  @override
  String get howPicoWorksSubtitle => 'Simple, fast, and built for matchdays.';

  @override
  String get step1Title => 'Predict the score';

  @override
  String get step1Description => 'Quick picks before kickoff';

  @override
  String get step2Title => 'Earn points & climb';

  @override
  String get step2Description => 'Score accurate calls each week';

  @override
  String get step3Title => 'Win tournament trophies';

  @override
  String get step3Description => 'Top friends and global ranks';

  @override
  String get nextStepHint => 'Next: Pick your favorite starting team (15 sec)';

  @override
  String stepIndicator(int current, int total) {
    return 'STEP $current/$total';
  }

  @override
  String get personalizationTitle => 'Pick Your Favorites';

  @override
  String get personalizationSubtitle =>
      'Choose your username and follow your favorite clubs & leagues.';

  @override
  String get customizeFeedKicker => 'CUSTOMIZE YOUR FEED';

  @override
  String get usernameLabel => 'Choose a Username';

  @override
  String get usernamePlaceholder => 'e.g. joao_striker';

  @override
  String get usernameErrorEmpty => 'Please introduce a username to continue.';

  @override
  String get usernameErrorTooShort => 'Username must be at least 3 characters';

  @override
  String get topLeaguesTitle => 'Top Leagues & Cups';

  @override
  String get clubsFollowTitle => 'Clubs You Follow';

  @override
  String get personalizationHelperNote =>
      'You can change your favorite team and join more tournaments anytime.';

  @override
  String get continueButton => 'Continue';

  @override
  String get skipButton => 'Skip';

  @override
  String get preferencesSyncHint =>
      'Preferences sync instantly across Pico League';

  @override
  String get savingPreferences => 'Saving your profile...';

  @override
  String mascotGreeting(String username) {
    return 'Big match tonight, $username! ⚽';
  }

  @override
  String get upcomingMatchesTitle => 'Upcoming Matches';

  @override
  String get noUpcomingMatches =>
      'No upcoming matches right now. Check back soon!';

  @override
  String get retryButton => 'Retry';

  @override
  String get homeMenuTitle => 'Settings & Menu';

  @override
  String get signOutButton => 'Sign Out';

  @override
  String get exitDialogTitle => 'Leaving the Pitch?';

  @override
  String get exitDialogMessage =>
      'Are you sure you want to quit Pico? Upcoming matches and predictions are waiting for you!';

  @override
  String get exitDialogStayButton => 'STAY & PREDICT';

  @override
  String get exitDialogLeaveButton => 'Leave Game';

  @override
  String get matchOfTheDayTitle => 'Match of the Day';

  @override
  String get viewAllMatches => 'View All';

  @override
  String moreMatchesAvailable(int count) {
    return '+$count more fixtures in Matches';
  }

  @override
  String get profileTitleKicker => 'Matchday Prophet';

  @override
  String get hitRateLabel => 'Hit Rate';

  @override
  String get matchesLabel => 'Matches';

  @override
  String get podiumsLabel => 'Podiums';

  @override
  String get clubRankLabel => 'Club Rank';

  @override
  String xpProgressToLevel(int level) {
    return 'XP Progress to LVL $level';
  }

  @override
  String get tournamentsAccordionTitle => 'Tournaments';

  @override
  String get tournamentsAccordionSubtitle => 'Active cups & weekly leagues';

  @override
  String tournamentsActiveCount(int count) {
    return '$count Active';
  }

  @override
  String get followingAccordionTitle => 'Following';

  @override
  String get followingAccordionSubtitle => 'Clubs, leagues & priority alerts';

  @override
  String followingPinnedCount(int count) {
    return '$count Pinned';
  }

  @override
  String get historyAccordionTitle => 'History';

  @override
  String get historyAccordionSubtitle =>
      'Predictions slip archive & past trophies';

  @override
  String historySummary(int count, int rate) {
    return '$count Matches · $rate%';
  }

  @override
  String get recentFormTitle => 'Recent Form (Last 10 Matches)';

  @override
  String recentFormSummary(int wins, int exact) {
    return '$wins Wins · $exact Exact';
  }

  @override
  String get settingsAccordionTitle => 'Settings';

  @override
  String get settingsAccordionSubtitle => 'Preferences, sound & notifications';

  @override
  String get pushNotificationsTitle => 'Push Notifications';

  @override
  String get matchdayHapticsTitle => 'Matchday Haptics';

  @override
  String get enabledPill => 'Enabled';

  @override
  String get onPill => 'On';

  @override
  String get shareMatchdayCard => 'Share Matchday Card';

  @override
  String get shareCardModalTitle => 'Matchday Trading Card';

  @override
  String get shareCardPrompt =>
      'Share your Pico profile card and stats with friends!';

  @override
  String get copyProfileSummary => 'Copy Card Summary';

  @override
  String get profileSummaryCopied => 'Profile summary copied to clipboard!';

  @override
  String get standingsButton => 'Standings';

  @override
  String pointsEarnedBadge(int points) {
    return '+$points Pts';
  }

  @override
  String streakPill(int count) {
    return '$count Streak';
  }

  @override
  String coinsPill(String count) {
    return '$count Coins';
  }

  @override
  String levelPill(int level) {
    return 'LVL $level';
  }
}
