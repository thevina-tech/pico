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

  @override
  String get predictAction => 'PREDICT';

  @override
  String get exactScore => 'Exact score';

  @override
  String get exactScoreTitle => 'Exact Score Prediction';

  @override
  String get pickWinner => 'Pick Winner';

  @override
  String get pickTheWinner => 'Pick the Winner';

  @override
  String get whoWins => 'Who wins?';

  @override
  String get homeOutcome => 'Home';

  @override
  String get drawOutcome => 'Draw';

  @override
  String get awayOutcome => 'Away';

  @override
  String get savePredictionCta => 'Save Prediction (+10 XP)';

  @override
  String get modifyPrediction => 'Modify Prediction';

  @override
  String get predictionLockedTitle => 'Prediction Locked! ⚽';

  @override
  String predictionLockedBanner(String time) {
    return 'Prediction locked · Kickoff at $time';
  }

  @override
  String get predictionWindowClosed => 'Predictions are closed for this match';

  @override
  String get predictionLockNote =>
      'Predictions lock exactly 10 minutes before kickoff.';

  @override
  String get potentialPointsHeader => 'Potential Pico Points';

  @override
  String get potentialPointsBreakdown =>
      '+5 for exact score · +3 for correct winner';

  @override
  String get quickPredict => 'Quick Predict';

  @override
  String get predictionSavedToast => 'Prediction locked in! Good luck.';

  @override
  String get tournamentsTitle => 'Tournaments';

  @override
  String get tournamentsSubtitle => 'Compete with friends · No real money';

  @override
  String get myLeaguesTab => 'My Leagues';

  @override
  String get discoverTab => 'Discover';

  @override
  String get createOrJoinAction => '+ Create / Join';

  @override
  String get createPrivateLeagueTitle => 'Create Private League';

  @override
  String get createPrivateLeagueSubtitle =>
      'Compete against friends, banter, and crown your group champion.';

  @override
  String get joinPrivateLeagueTitle => 'Join Private League';

  @override
  String get joinPrivateLeagueSubtitle =>
      'Enter the 6-character code shared by your friend.';

  @override
  String get leagueNameLabel => 'LEAGUE NAME';

  @override
  String get leagueNamePlaceholder => 'e.g., Friday Football Kings';

  @override
  String get baseTournamentLabel => 'BASE TOURNAMENT / COMPETITION';

  @override
  String get baseTournamentHelper =>
      'Matches and standings are linked to this competition.';

  @override
  String get freeSetupBadge => 'Free Instant Setup';

  @override
  String get createLeagueButton => 'Create Private League';

  @override
  String get joinLeagueButton => 'Join Private League';

  @override
  String get enterLeagueCodeLabel => 'ENTER 6-CHARACTER CODE';

  @override
  String get pasteCode => 'Paste';

  @override
  String get codeCopiedToast => 'Invite code copied to clipboard!';

  @override
  String shareInviteMessage(String code) {
    return 'Join my private league on Pico! Use code: $code';
  }

  @override
  String get inviteCodeLabel => 'INVITE CODE';

  @override
  String get copyCodeButton => 'Copy Code';

  @override
  String get shareCodeButton => 'Share Invite';

  @override
  String get emptyPrivateLeaguesTitle => 'No Private Leagues Yet';

  @override
  String get emptyPrivateLeaguesSubtitle =>
      'Create a league for your friends or join one with an invite code.';

  @override
  String get officialTournamentBadge => 'OFFICIAL TOURNAMENT';

  @override
  String get leagueCreatedSuccessTitle => 'League Created! 🎉';

  @override
  String get leagueJoinedSuccessTitle => 'You\'re In! ⚽';

  @override
  String leagueJoinedSuccessSubtitle(String leagueName) {
    return 'You have joined $leagueName';
  }

  @override
  String get invalidLeagueCodeError =>
      'Invalid invite code. Please check the code and try again.';

  @override
  String get alreadyMemberOfLeagueError =>
      'You are already a member of this league.';

  @override
  String get creatorCannotRejoinError =>
      'You created this league and are already its owner.';

  @override
  String get leagueCodeFormatError =>
      'Code must be exactly 6 characters (e.g., K9X2P1)';

  @override
  String get doneButton => 'Done';

  @override
  String get privateLeagueSecurityNote =>
      'Only players with your invite code can join';

  @override
  String get officialBaseTournamentNote => 'Official Base Tournament';

  @override
  String competitionsAvailableCount(int count) {
    return '$count available';
  }

  @override
  String get friendsAndColleaguesBadge => 'FRIENDS & COLLEAGUES';

  @override
  String get privateCommunitySubtitle => 'Private Community';

  @override
  String selectBaseTournamentSheetTitle(int count) {
    return 'Select Base Tournament ($count Available)';
  }

  @override
  String get tournamentDetailsTitle => 'Tournament Details';

  @override
  String get privateLeagueDetailsTitle => 'Private League';

  @override
  String get inviteCodeBannerTitle => 'LEAGUE INVITE CODE';

  @override
  String get inviteCodeBannerSubtitle =>
      'Share with friends to compete together';

  @override
  String shareInviteCodeMessage(String leagueName, String code) {
    return 'Join my private football prediction league \"$leagueName\" on Pico! Use invite code: $code';
  }

  @override
  String get adminControlsTitle => 'ADMIN CONTROLS';

  @override
  String get deleteLeagueButton => 'Delete League';

  @override
  String get deleteLeagueConfirmTitle => 'Delete Private League?';

  @override
  String get deleteLeagueConfirmBody =>
      'This action is permanent. All members will be removed and standings will be erased.';

  @override
  String get deleteLeagueAction => 'Delete';

  @override
  String get removeMemberButton => 'Remove';

  @override
  String get removeMemberConfirmTitle => 'Remove Member?';

  @override
  String removeMemberConfirmBody(String username) {
    return 'Are you sure you want to remove $username from this league?';
  }

  @override
  String get leaveLeagueButton => 'Leave League';

  @override
  String get leaveLeagueConfirmTitle => 'Leave League?';

  @override
  String leaveLeagueConfirmBody(String leagueName) {
    return 'Are you sure you want to leave $leagueName? You will need the invite code to rejoin.';
  }

  @override
  String get leaveLeagueAction => 'Leave';

  @override
  String get leaderboardTab => 'Standings';

  @override
  String get matchesTab => 'Matches';

  @override
  String get upcomingMatchesSection => 'Upcoming Matches';

  @override
  String get finishedMatchesSection => 'Completed Matches';

  @override
  String get noParticipantsYet => 'No participants yet';

  @override
  String get noMatchesForCompetition => 'No matches found for this competition';

  @override
  String get leagueDeletedToast => 'League deleted successfully';

  @override
  String get memberRemovedToast => 'Member removed';

  @override
  String get leftLeagueToast => 'You left the league';

  @override
  String get creatorBadge => 'CREATOR';

  @override
  String get memberBadge => 'MEMBER';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get pointsAbbreviation => 'PTS';

  @override
  String get rankHeader => 'RANK';

  @override
  String get playerHeader => 'PLAYER';

  @override
  String get feedTabLive => 'Live';

  @override
  String get feedTabUpcoming => 'Upcoming';

  @override
  String get feedTabFinished => 'Finished';

  @override
  String teaserOpensInDays(int days) {
    return 'Opens in ${days}d';
  }

  @override
  String teaserOpensInHours(int hours) {
    return 'Opens in ${hours}h';
  }

  @override
  String teaserOpensInMinutes(int minutes) {
    return 'Opens in ${minutes}m';
  }

  @override
  String get teaserCountdownSubtext =>
      'Prediction window opens 3 days before kickoff';

  @override
  String get pointsOutcomeExact => '+5 Points';

  @override
  String get pointsOutcomeWinner => '+3 Points';

  @override
  String get pointsOutcomeIncorrect => '0 Points';

  @override
  String get pointsOutcomeNone => 'No Prediction';

  @override
  String get noLiveMatches => 'No live matches right now';

  @override
  String get noLiveMatchesSub =>
      'Check back during matchdays for real-time fixtures.';

  @override
  String get feedNoUpcomingMatches => 'No upcoming matches in the next 14 days';

  @override
  String get noUpcomingMatchesSub =>
      'Upcoming fixtures will appear here once scheduled.';

  @override
  String get noFinishedMatches => 'No finished matches in the last 7 days';

  @override
  String get noFinishedMatchesSub =>
      'Recently concluded matches and points will be shown here.';

  @override
  String get joinTournamentBannerBadge => 'JOIN THE COMPETITION';

  @override
  String get joinTournamentBannerTitle => 'Predict & Compete';

  @override
  String get joinTournamentBannerSub =>
      'Join this tournament to predict upcoming matches, score Pico Points, and climb the public standings.';

  @override
  String get joinTournamentAction => 'Join Tournament';

  @override
  String joinTournamentSuccessToast(String tournamentName) {
    return 'You joined $tournamentName! Predictions unlocked.';
  }

  @override
  String get joinedBadge => 'Joined';

  @override
  String get joinAction => 'Join';

  @override
  String get previewModeBanner =>
      'Preview Mode · Join this tournament to unlock predictions';

  @override
  String get joinAndPredictAction => 'Join to Predict';

  @override
  String get signInToJoinTournament =>
      'Sign in to join tournaments and submit predictions.';

  @override
  String get viewFullPredictionPage => 'View Full Prediction Page →';

  @override
  String get scoringRuleBanner =>
      'Exact score = +5 Pico Points · Correct winner = +3 Pico Points';

  @override
  String get predictionLockedSuccessToast => 'Prediction locked in! (+10 XP) ⚽';

  @override
  String get predictionSaveFailed =>
      'Failed to save prediction. Please try again.';

  @override
  String get matchFinishedLabel => 'Match Finished';

  @override
  String get feedTabAll => 'All';

  @override
  String matchLocksAt(String time) {
    return 'Locks $time';
  }
}
