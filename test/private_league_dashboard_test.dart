import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/features/matches/domain/competition.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/predictions/data/prediction_repository.dart';
import 'package:pico/features/predictions/domain/prediction.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/league_message.dart';
import 'package:pico/features/tournaments/domain/private_league.dart';
import 'package:pico/features/tournaments/domain/private_league_member.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';
import 'package:pico/features/tournaments/domain/tournament_participant.dart';
import 'package:pico/features/tournaments/presentation/private_league_dashboard_screen.dart';
import 'package:pico/shared/components/match_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _FakeTournamentRepo implements TournamentRepository {
  final List<PrivateLeague> leagues = [];
  final Map<String, List<PrivateLeagueMember>> membersMap = {};
  final Map<String, List<LeagueMessage>> messagesMap = {};

  @override
  Future<List<Competition>> getCompetitions() async => [
        const Competition(
          id: '10',
          name: 'Premier League',
          shortName: 'Premier League',
          flag: '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
        ),
        const Competition(
          id: '1',
          name: 'La Liga',
          shortName: 'La Liga',
          flag: '🇪🇸',
        ),
      ];

  @override
  Future<List<Tournament>> getPublicTournaments() async => [];

  @override
  Future<List<Tournament>> getEnrolledTournaments(String userId) async => [];

  @override
  Future<void> enrollInDefaultTournaments({
    required String userId,
    required List<String> leagueIds,
  }) async {}

  @override
  Future<void> enrollInTournament({
    required String userId,
    required String tournamentId,
  }) async {}

  @override
  Future<List<TournamentParticipant>> getParticipantsForUser(String userId) async => [];

  @override
  Future<Tournament?> getTournamentById(String tournamentId) async => null;

  @override
  Future<List<TournamentParticipant>> getTournamentLeaderboard(String tournamentId) async => [];

  @override
  Future<List<PrivateLeague>> getUserPrivateLeagues(String userId) async => leagues;

  @override
  Future<PrivateLeague?> getPrivateLeagueById(String leagueId) async =>
      leagues.where((l) => l.id == leagueId).firstOrNull;

  @override
  Future<PrivateLeague> createPrivateLeague({
    required String name,
    required String competitionId,
    required String userId,
    String description = '',
  }) async =>
      throw UnimplementedError();

  @override
  Future<PrivateLeague> joinPrivateLeagueByCode({
    required String inviteCode,
    required String userId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<List<PrivateLeagueMember>> getPrivateLeagueMembers(String leagueId) async =>
      membersMap[leagueId] ?? [];

  @override
  Future<void> deletePrivateLeague({
    required String leagueId,
    required String userId,
  }) async {
    leagues.removeWhere((l) => l.id == leagueId);
  }

  @override
  Future<void> removeMemberFromPrivateLeague({
    required String leagueId,
    required String targetUserId,
    required String adminUserId,
  }) async {
    membersMap[leagueId]?.removeWhere((m) => m.userId == targetUserId);
  }

  @override
  Future<void> leavePrivateLeague({
    required String leagueId,
    required String userId,
  }) async {
    membersMap[leagueId]?.removeWhere((m) => m.userId == userId);
  }

  @override
  Future<List<LeagueMessage>> getLeagueMessages(String leagueId, {int limit = 50}) async =>
      List<LeagueMessage>.from(messagesMap[leagueId] ?? []);

  @override
  Future<LeagueMessage> sendLeagueMessage({
    required String leagueId,
    required String userId,
    required String message,
    String? username,
    String? avatarUrl,
  }) async {
    final msg = LeagueMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      leagueId: leagueId,
      userId: userId,
      message: message,
      createdAt: DateTime.now(),
      username: username ?? 'Player',
      avatarUrl: avatarUrl,
    );
    messagesMap.putIfAbsent(leagueId, () => []).insert(0, msg);
    return msg;
  }
}

class _FakePredictionRepo implements PredictionRepository {
  final Map<String, Prediction> storage = {};

  @override
  Future<List<Prediction>> getUserPredictions(String userId) async {
    return storage.values.where((p) => p.userId == userId).toList();
  }

  @override
  Future<Map<String, int>> getUserSettlementPoints(String userId) async => {};

  @override
  Future<Prediction?> getPredictionForMatch({
    required String userId,
    required String matchId,
  }) async =>
      storage['$userId:$matchId'];

  @override
  Future<Prediction> savePrediction({
    required String userId,
    required String matchId,
    required int homeScore,
    required int awayScore,
    required String predictedWinner,
  }) async {
    final pred = Prediction(
      id: 'pred_${matchId}_$userId',
      userId: userId,
      matchId: matchId,
      homeScore: homeScore,
      awayScore: awayScore,
      predictedWinner: predictedWinner,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    storage['$userId:$matchId'] = pred;
    return pred;
  }
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._userId);
  final String _userId;

  @override
  PicoAuthState build() {
    return PicoAuthAuthenticated(
      user: supa.User(
        id: _userId,
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      ),
      isPersonalized: true,
    );
  }
}

class _FakeCurrentUserProfileNotifier extends CurrentUserProfile {
  @override
  Future<UserProfile> build() async {
    return const UserProfile(
      id: 'user_owner_123',
      email: 'owner@pico.app',
      username: 'PicoCaptain',
      level: 10,
      xp: 1200,
      streak: 5,
      coins: 50,
    );
  }
}

Widget _buildTestHarness({
  required Widget child,
  required _FakeTournamentRepo tournamentRepo,
  required _FakePredictionRepo predictionRepo,
  List<PicoMatch> matches = const [],
  String currentUserId = 'user_owner_123',
}) {
  return ProviderScope(
    overrides: [
      tournamentRepositoryProvider.overrideWithValue(tournamentRepo),
      predictionRepositoryProvider.overrideWithValue(predictionRepo),
      authProvider.overrideWith(() => _FakeAuthNotifier(currentUserId)),
      currentUserProfileProvider.overrideWith(() => _FakeCurrentUserProfileNotifier()),
      competitionMatchesProvider('10').overrideWith((ref) async => matches),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('Private League Dashboard: Unified Clan Dashboard', () {
    late _FakeTournamentRepo tournamentRepo;
    late _FakePredictionRepo predictionRepo;
    late PrivateLeague premierLeagueGroup;

    setUp(() {
      tournamentRepo = _FakeTournamentRepo();
      predictionRepo = _FakePredictionRepo();

      premierLeagueGroup = PrivateLeague(
        id: 'pl_dashboard_1',
        name: 'The Invincibles',
        ownerId: 'user_owner_123',
        adminId: 'user_owner_123',
        competitionId: '10',
        inviteCode: 'INVINC',
        createdAt: DateTime.now(),
        memberCount: 2,
      );

      tournamentRepo.leagues.add(premierLeagueGroup);
      tournamentRepo.membersMap[premierLeagueGroup.id] = [
        PrivateLeagueMember(
          privateLeagueId: premierLeagueGroup.id,
          userId: 'user_owner_123',
          username: 'PicoCaptain',
          picoPoints: 85,
          joinedAt: DateTime.now(),
        ),
        PrivateLeagueMember(
          privateLeagueId: premierLeagueGroup.id,
          userId: 'user_member_456',
          username: 'GunnerMate',
          picoPoints: 60,
          joinedAt: DateTime.now(),
        ),
      ];

      tournamentRepo.messagesMap[premierLeagueGroup.id] = [
        LeagueMessage(
          id: 'msg_1',
          leagueId: premierLeagueGroup.id,
          userId: 'user_owner_123',
          message: 'Welcome to The Invincibles!',
          createdAt: DateTime.now(),
          username: 'PicoCaptain',
        ),
      ];
    });

    testWidgets('Renders all 3 tabs: Chat, Matches, and Standings', (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: PrivateLeagueDashboardScreen(
            leagueId: premierLeagueGroup.id,
            initialLeague: premierLeagueGroup,
          ),
          tournamentRepo: tournamentRepo,
          predictionRepo: predictionRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Top Tab Bar buttons
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('Standings'), findsOneWidget);

      // Default landing view is Chat
      expect(find.text('Welcome to The Invincibles!'), findsOneWidget);
      expect(find.text('Message league...'), findsOneWidget);
    });

    testWidgets('Switches to Matches tab and dynamically filters matches by competition_id', (tester) async {
      final match1 = PicoMatch(
        id: 'match_epl_1',
        competitionId: '10',
        homeTeamName: 'Arsenal',
        awayTeamName: 'Chelsea',
        kickoffAt: DateTime.now().add(const Duration(hours: 2)),
        status: MatchStatus.upcoming,
      );

      await tester.pumpWidget(
        _buildTestHarness(
          child: PrivateLeagueDashboardScreen(
            leagueId: premierLeagueGroup.id,
            initialLeague: premierLeagueGroup,
          ),
          tournamentRepo: tournamentRepo,
          predictionRepo: predictionRepo,
          matches: [match1],
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Matches" tab
      await tester.tap(find.text('Matches'));
      await tester.pumpAndSettle();

      // Verify competition match is shown
      expect(find.text('Arsenal'), findsOneWidget);
      expect(find.text('Chelsea'), findsOneWidget);
      expect(find.byType(MatchCard), findsOneWidget);
    });

    testWidgets('Enforces Single Source of Truth: Globally predicted match reflects inside League Matches tab', (tester) async {
      final matchId = 'match_epl_sync_1';
      final match = PicoMatch(
        id: matchId,
        competitionId: '10',
        homeTeamName: 'Liverpool',
        awayTeamName: 'Man City',
        kickoffAt: DateTime.now().add(const Duration(hours: 4)),
        status: MatchStatus.upcoming,
      );

      // Simulate prediction made globally elsewhere in the app (Home or Matches screen)
      await predictionRepo.savePrediction(
        userId: 'user_owner_123',
        matchId: matchId,
        homeScore: 3,
        awayScore: 1,
        predictedWinner: 'home',
      );

      await tester.pumpWidget(
        _buildTestHarness(
          child: PrivateLeagueDashboardScreen(
            leagueId: premierLeagueGroup.id,
            initialLeague: premierLeagueGroup,
            initialTabIndex: 1, // Start directly on Matches tab
          ),
          tournamentRepo: tournamentRepo,
          predictionRepo: predictionRepo,
          matches: [match],
        ),
      );
      await tester.pumpAndSettle();

      // Match card should reflect the existing global prediction: "3 - 1"
      expect(find.text('3 - 1'), findsOneWidget);
      expect(find.text('Liverpool'), findsOneWidget);
      expect(find.text('Man City'), findsOneWidget);
    });

    testWidgets('Switches to Standings tab: Strictly displays the Leaderboard standings', (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: PrivateLeagueDashboardScreen(
            leagueId: premierLeagueGroup.id,
            initialLeague: premierLeagueGroup,
          ),
          tournamentRepo: tournamentRepo,
          predictionRepo: predictionRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Tap Standings tab
      await tester.tap(find.text('Standings'));
      await tester.pumpAndSettle();

      // Verify Standings title is present
      expect(find.text('STANDINGS'), findsOneWidget);

      // Verify Invite code banner and Admin controls card are NOT in the Standings tab
      expect(find.text('LEAGUE INVITE CODE'), findsNothing);

      // Verify Members Leaderboard is displayed
      expect(find.text('PicoCaptain'), findsOneWidget);
      expect(find.text('GunnerMate'), findsOneWidget);
      expect(find.text('85'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('CREATOR'), findsWidgets);
    });

    testWidgets('Top right button is a settings icon and opens LeagueDetailsSheet with admin controls', (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: PrivateLeagueDashboardScreen(
            leagueId: premierLeagueGroup.id,
            initialLeague: premierLeagueGroup,
          ),
          tournamentRepo: tournamentRepo,
          predictionRepo: predictionRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Top right settings button exists with Icons.settings_rounded
      final settingsBtn = find.byKey(const Key('league_settings_button'));
      expect(settingsBtn, findsOneWidget);
      expect(find.descendant(of: settingsBtn, matching: find.byIcon(Icons.settings_rounded)), findsOneWidget);

      // App bar does NOT display "x Active Members"
      expect(find.textContaining('Active Members'), findsNothing);

      // Tap settings button opens sheet
      await tester.tap(settingsBtn);
      await tester.pumpAndSettle();

      // In LeagueDetailsSheet:
      // Verify Invite code box
      expect(find.text('INVINC'), findsOneWidget);
      expect(find.text('INVITE CODE'), findsOneWidget);

      // Verify Admin Controls (owner is user_owner_123)
      expect(find.text('ADMIN CONTROLS'), findsOneWidget);
      expect(find.text('Delete League'), findsOneWidget);

      // Verify base league is displayed
      expect(find.textContaining('Base: Premier League'), findsOneWidget);
    });

    testWidgets('Tapping league title in app bar also opens LeagueDetailsSheet', (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: PrivateLeagueDashboardScreen(
            leagueId: premierLeagueGroup.id,
            initialLeague: premierLeagueGroup,
          ),
          tournamentRepo: tournamentRepo,
          predictionRepo: predictionRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Tap the league name
      await tester.tap(find.text('The Invincibles'));
      await tester.pumpAndSettle();

      // Sheet is opened
      expect(find.text('INVINC'), findsOneWidget);
      expect(find.text('INVITE CODE'), findsOneWidget);
      expect(find.text('ADMIN CONTROLS'), findsOneWidget);
    });

    testWidgets('Tactile 3D Tab Buttons render with Column stacking Icon over Text and responsive 3D styling', (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: PrivateLeagueDashboardScreen(
            leagueId: premierLeagueGroup.id,
            initialLeague: premierLeagueGroup,
          ),
          tournamentRepo: tournamentRepo,
          predictionRepo: predictionRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Find icons inside tab buttons
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.sports_soccer_rounded), findsOneWidget);

      // Verify Column stacks Icon above Text in each button
      final chatText = find.text('Chat');
      final chatIcon = find.descendant(
        of: find.ancestor(of: chatText, matching: find.byType(Column)),
        matching: find.byIcon(Icons.chat_bubble_outline_rounded),
      );
      expect(chatIcon, findsOneWidget);
      expect(tester.getTopLeft(chatIcon).dy < tester.getTopLeft(chatText).dy, isTrue);

      final standingsText = find.text('Standings');
      final standingsIcon = find.descendant(
        of: find.ancestor(of: standingsText, matching: find.byType(Column)),
        matching: find.byIcon(Icons.leaderboard_rounded),
      );
      expect(standingsIcon, findsOneWidget);
      expect(tester.getTopLeft(standingsIcon).dy < tester.getTopLeft(standingsText).dy, isTrue);

      // Default tab index is 0 (Chat) -> active
      // Tapping Matches changes active tab
      await tester.tap(find.text('Matches'));
      await tester.pumpAndSettle();

      final matchesText = find.text('Matches');
      final matchesIcon = find.descendant(
        of: find.ancestor(of: matchesText, matching: find.byType(Column)),
        matching: find.byIcon(Icons.sports_soccer_rounded),
      );
      expect(matchesIcon, findsOneWidget);
      expect(tester.getTopLeft(matchesIcon).dy < tester.getTopLeft(matchesText).dy, isTrue);
    });

    testWidgets('Matches Tab filters out matches not belonging to league competition_id', (tester) async {
      final eplMatch = PicoMatch(
        id: 'match_epl_valid',
        competitionId: '10', // Matches league.competitionId
        homeTeamName: 'Arsenal',
        awayTeamName: 'Chelsea',
        kickoffAt: DateTime.now().add(const Duration(hours: 2)),
        status: MatchStatus.upcoming,
      );

      final laLigaMatch = PicoMatch(
        id: 'match_laliga_invalid',
        competitionId: '1', // Does NOT match league.competitionId ('10')
        homeTeamName: 'Real Madrid',
        awayTeamName: 'Barcelona',
        kickoffAt: DateTime.now().add(const Duration(hours: 3)),
        status: MatchStatus.upcoming,
      );

      await tester.pumpWidget(
        _buildTestHarness(
          child: PrivateLeagueDashboardScreen(
            leagueId: premierLeagueGroup.id,
            initialLeague: premierLeagueGroup,
            initialTabIndex: 1, // Start on Matches tab
          ),
          tournamentRepo: tournamentRepo,
          predictionRepo: predictionRepo,
          matches: [eplMatch, laLigaMatch],
        ),
      );
      await tester.pumpAndSettle();

      // Only EPL match is shown, La Liga match is strictly filtered out
      expect(find.text('Arsenal'), findsOneWidget);
      expect(find.text('Chelsea'), findsOneWidget);
      expect(find.text('Real Madrid'), findsNothing);
      expect(find.text('Barcelona'), findsNothing);
    });

    testWidgets('Displays 25-Member capacity in LeagueDetailsSheet ("Members: 2/25")', (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          child: PrivateLeagueDashboardScreen(
            leagueId: premierLeagueGroup.id,
            initialLeague: premierLeagueGroup,
          ),
          tournamentRepo: tournamentRepo,
          predictionRepo: predictionRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Tap on AppBar to open LeagueDetailsSheet
      await tester.tap(find.text('The Invincibles'));
      await tester.pumpAndSettle();

      // Verify capacity is displayed as "Members: 2/25"
      expect(find.text('Members: 2/25'), findsOneWidget);
    });
  });
}
