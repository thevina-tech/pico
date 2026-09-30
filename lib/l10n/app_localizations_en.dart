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
  String get navShop => 'Shop';

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
  String get continueWithGoogle => 'Continue with Google';

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
  String get signInToContinue => 'Sign in to Continue';

  @override
  String get step3AuthTitle => 'What Should We Call You?';

  @override
  String get step3AuthSubtitle =>
      'Pick a username for leaderboards and friend leagues.';

  @override
  String get chooseFavoriteTeamTitle => 'Choose Favorite Team';

  @override
  String get chooseFavoriteTeamSubtitle =>
      'Select your club to personalize your feed and upcoming matches.';

  @override
  String get searchTeamsPlaceholder => 'Search clubs...';

  @override
  String get chooseLeaguesTitle => 'Choose Leagues';

  @override
  String get chooseLeaguesSubtitle =>
      'Select 1 or 2 competitions to follow and compete in.';

  @override
  String get finishButton => 'Finish';

  @override
  String get oneTeamRequired => 'Please select 1 team to continue.';

  @override
  String get twoLeaguesRequired => 'Please select 1 or 2 leagues to continue.';

  @override
  String get maxLeaguesReached => 'You can select up to 2 leagues.';

  @override
  String get usernameTakenError =>
      'This username is already taken. Please choose another one.';

  @override
  String get selectedTeamBadge => '1/1 Selected';

  @override
  String leaguesSelectedBadge(int count) {
    return '$count/2 Selected';
  }

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
  String get exitDialogTitle => 'Exit App?';

  @override
  String get exitDialogMessage => 'Are you sure you want to exit?';

  @override
  String get exitDialogStayButton => 'Stay';

  @override
  String get exitDialogLeaveButton => 'Exit';

  @override
  String get matchOfTheDayTitle => 'Match of the Day';

  @override
  String get viewAllMatches => 'View All';

  @override
  String moreMatchesAvailable(int count) {
    return '+$count more fixtures in Matches';
  }

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
  String get savePredictionCta => 'Save Prediction (+5 Points)';

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
  String get tournamentsSubtitle =>
      'Climb the leaderboards or compete with friends';

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
  String get publicTournamentBadge => 'PICO TOURNAMENT';

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
  String get baseTournamentNote => 'Base Competition';

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
  String get top100LeaderboardHeader => 'TOP 100 PLAYERS';

  @override
  String get picoPointsLabel => 'Pico Points';

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
  String get predictionLockedSuccessToast =>
      'Prediction locked in! (+5 Points) ⚽';

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

  @override
  String get matchesTotalSub => 'Total';

  @override
  String bestStreak(int count) {
    return 'Best: $count';
  }

  @override
  String hitRateTrendUp(int rate) {
    return '↑ +$rate%';
  }

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get seeAll => 'See all';

  @override
  String get achievementOnFireTitle => 'On Fire';

  @override
  String achievementOnFireDesc(int count) {
    return '$count streak';
  }

  @override
  String get achievementSharpshooterTitle => 'Sharpshooter';

  @override
  String achievementSharpshooterDesc(int rate) {
    return '$rate% hit rate';
  }

  @override
  String get achievementPodiumTitle => 'Podium';

  @override
  String achievementPodiumDesc(int count) {
    return '$count podiums';
  }

  @override
  String get achievementStreak10Title => '10 Streak';

  @override
  String get achievementLockedLabel => 'Locked';

  @override
  String get helpAndSupportTitle => 'Help & Support';

  @override
  String get helpAndSupportSubtitle => 'Rules, scoring guide & contact';

  @override
  String get accountSettingsAria => 'Account Settings';

  @override
  String get picoRulesTitle => 'Game Rules & Scoring';

  @override
  String get picoRulesSubtitle =>
      'Fair play, server-side locks & transparent scoring';

  @override
  String get division10Title => 'Division 10';

  @override
  String get division9Title => 'Division 9';

  @override
  String get division8Title => 'Division 8';

  @override
  String get division7Title => 'Division 7';

  @override
  String get division6Title => 'Division 6';

  @override
  String get division5Title => 'Division 5';

  @override
  String get division4Title => 'Division 4';

  @override
  String get division3Title => 'Division 3';

  @override
  String get division2Title => 'Division 2';

  @override
  String get division1Title => 'Division 1';

  @override
  String get divisionEliteTitle => 'Elite Division';

  @override
  String get predictionPointsLabel => 'Prediction Points';

  @override
  String get predictionPointsAbbr => 'PP';

  @override
  String get currentDivisionLabel => 'Current Division';

  @override
  String get divisionLadderTitle => 'Division Ladder';

  @override
  String get divisionLadderSubtitle =>
      'Climb tiers with accurate match predictions';

  @override
  String pointsToNextDivisionThreshold(
    String current,
    String target,
    String nextDivision,
  ) {
    return '$current / $target pts to $nextDivision';
  }

  @override
  String pointsToNextDivision(String points, String nextDivision) {
    return '$points pts to $nextDivision';
  }

  @override
  String eliteDivisionStatus(String points) {
    return '$points pts (Elite Division)';
  }

  @override
  String get pointsOutcomeGoalDiff => '+3 Points';

  @override
  String get pointsOutcomeOne => '+1 Point';

  @override
  String get scoringRuleBannerSprint7 =>
      'Exact = +5 PP · Outcome + Diff = +3 PP · Outcome = +1 PP';

  @override
  String get signOutSubtitle => 'Log out of your Pico session';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Account, sign out & preferences';

  @override
  String get shareTheAppButton => 'Share the App';

  @override
  String get shareAppMessage =>
      'Join me on Pico to predict football matches! https://play.google.com/store/apps/details?id=com.devdaumienebi.yonunca';

  @override
  String get deleteAccountOption => 'Delete Account';

  @override
  String get deleteAccountSubtitle =>
      'Permanently remove your account and data';

  @override
  String get deleteAccountConfirmTitle => 'Delete Account?';

  @override
  String get deleteAccountConfirmBody =>
      'Are you sure? This will permanently delete your predictions, league memberships, and account data. This cannot be undone.';

  @override
  String get deleteAccountAction => 'Delete Account';

  @override
  String get deleteAccountError =>
      'Failed to delete account. Please try again.';

  @override
  String get accountDeletedToast => 'Your account has been deleted.';

  @override
  String get adChoicesTitle => 'Ad Choices & Privacy';

  @override
  String get adChoicesSubtitle =>
      'Review or change your ad personalization consent';

  @override
  String get picoScoringRules => 'PICO SCORING RULES';

  @override
  String get scoringRuleExactTitle => 'Exact Score';

  @override
  String get scoringRuleExactDesc => 'Predict the exact final scoreline';

  @override
  String get scoringRuleGoalDiffTitle => 'Winner + Goal Diff';

  @override
  String get scoringRuleGoalDiffDesc => 'Correct winner and goal margin';

  @override
  String get scoringRuleWinnerOnlyTitle => 'Correct Winner';

  @override
  String get scoringRuleWinnerOnlyDesc => 'Correct winner, other scoreline';

  @override
  String get leagueCapacityReachedError =>
      'This league is full (Max 25 members).';

  @override
  String get leagueNameLengthError =>
      'League name must be between 3 and 30 characters.';

  @override
  String get leagueCreatedSuccessToast => 'League created successfully!';

  @override
  String get usernameAlphanumericError =>
      'Username must be alphanumeric with no spaces';

  @override
  String get couldNotOpenStoreLink => 'Could not open store link.';

  @override
  String couldNotOpenEmailClient(String email) {
    return 'Could not open email client. Contact: $email';
  }

  @override
  String get signInWithGooglePrompt =>
      'Please sign in with Google to continue.';

  @override
  String get signInWithGoogleSetupPrompt =>
      'Please sign in with Google to complete your account setup.';

  @override
  String failedToLoadTeams(String error) {
    return 'Failed to load teams: $error';
  }

  @override
  String failedToLoadCompetitions(String error) {
    return 'Failed to load competitions: $error';
  }

  @override
  String noClubsFound(String query) {
    return 'No clubs found matching \"$query\"';
  }

  @override
  String failedToDeleteLeague(String error) {
    return 'Failed to delete league: $error';
  }

  @override
  String failedToLeaveLeague(String error) {
    return 'Failed to leave league: $error';
  }

  @override
  String memberRemovedFromLeague(String username) {
    return '$username has been removed from the league.';
  }

  @override
  String failedToKickMember(String error) {
    return 'Failed to remove member: $error';
  }

  @override
  String failedToSendMessage(String error) {
    return 'Failed to send message: $error';
  }

  @override
  String signOutFailed(String error) {
    return 'Sign out failed: $error';
  }

  @override
  String homeGreeting(String username) {
    return 'Hey $username! 👋';
  }

  @override
  String get homeReadyToPredict => 'Ready to predict today\'s biggest clash?';
}
