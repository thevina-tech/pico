import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/features/matches/domain/competition.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/league_message.dart';
import 'package:pico/features/tournaments/domain/private_league.dart';
import 'package:pico/features/tournaments/domain/private_league_member.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';
import 'package:pico/features/tournaments/domain/tournament_participant.dart';
import 'package:pico/features/tournaments/presentation/league_chat_screen.dart';
import 'package:pico/features/tournaments/presentation/widgets/league_details_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

/// Fake implementation of TournamentRepository for League Chat & Room tests
class _FakeLeagueChatTournamentRepository implements TournamentRepository {
  final List<PrivateLeague> leagues = [];
  final Map<String, List<PrivateLeagueMember>> membersMap = {};
  final Map<String, List<LeagueMessage>> messagesMap = {};
  bool leaveLeagueCalled = false;
  String? removedUserId;

  @override
  Future<List<Competition>> getCompetitions() async => [
        const Competition(
          id: '10',
          name: 'Premier League',
          shortName: 'Premier League',
          flag: '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
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
  }) async {
    final league = PrivateLeague(
      id: 'pl_test',
      name: name,
      ownerId: userId,
      adminId: userId,
      competitionId: competitionId,
      inviteCode: 'TEST01',
      createdAt: DateTime.now(),
    );
    leagues.add(league);
    return league;
  }

  @override
  Future<PrivateLeague> joinPrivateLeagueByCode({
    required String inviteCode,
    required String userId,
  }) async =>
      leagues.first;

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
    removedUserId = targetUserId;
    membersMap[leagueId]?.removeWhere((m) => m.userId == targetUserId);
  }

  @override
  Future<void> leavePrivateLeague({
    required String leagueId,
    required String userId,
  }) async {
    leaveLeagueCalled = true;
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
      id: 'user_admin_123',
      email: 'admin@pico.app',
      username: 'PicoAdmin',
      level: 5,
      xp: 450,
      streak: 3,
      coins: 20,
    );
  }
}

Widget _buildTestHarness({
  required Widget child,
  required _FakeLeagueChatTournamentRepository repo,
  String currentUserId = 'user_admin_123',
}) {
  return ProviderScope(
    key: ValueKey(currentUserId),
    overrides: [
      tournamentRepositoryProvider.overrideWithValue(repo),
      authProvider.overrideWith(() => _FakeAuthNotifier(currentUserId)),
      currentUserProfileProvider.overrideWith(() => _FakeCurrentUserProfileNotifier()),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('Private League Room: LeagueMessage Domain & Serialization', () {
    test('LeagueMessage serializes to and from JSON correctly', () {
      final now = DateTime.now();
      final message = LeagueMessage(
        id: 'msg_001',
        leagueId: 'pl_100',
        userId: 'user_100',
        message: 'Hello rivals! Ready for the match?',
        createdAt: now,
        username: 'KingStriker',
        avatarUrl: 'https://example.com/avatar.png',
      );

      final json = message.toJson();
      expect(json['id'], 'msg_001');
      expect(json['league_id'], 'pl_100');
      expect(json['user_id'], 'user_100');
      expect(json['message'], 'Hello rivals! Ready for the match?');
      expect(json['username'], 'KingStriker');
      expect(json['avatar_url'], 'https://example.com/avatar.png');

      final deserialized = LeagueMessage.fromJson(json);
      expect(deserialized.id, message.id);
      expect(deserialized.message, message.message);
      expect(deserialized.username, 'KingStriker');
      expect(deserialized.avatarUrl, 'https://example.com/avatar.png');
    });

    test('PrivateLeague effectiveAdminId returns adminId or falls back to ownerId', () {
      const leagueWithAdmin = PrivateLeague(
        id: 'pl_01',
        name: 'Super League',
        ownerId: 'owner_1',
        adminId: 'promoted_admin_2',
        inviteCode: 'CODE01',
      );
      expect(leagueWithAdmin.effectiveAdminId, 'promoted_admin_2');

      const leagueWithoutAdmin = PrivateLeague(
        id: 'pl_02',
        name: 'Friends League',
        ownerId: 'owner_original',
        inviteCode: 'CODE02',
      );
      expect(leagueWithoutAdmin.effectiveAdminId, 'owner_original');
    });
  });

  group('Private League Room: LeagueChatScreen Layout & Chat', () {
    testWidgets('Renders interactive AppBar with crest, title, and member count', (tester) async {
      final repo = _FakeLeagueChatTournamentRepository();
      final league = PrivateLeague(
        id: 'pl_room_1',
        name: 'Clash Prediction League',
        ownerId: 'user_admin_123',
        adminId: 'user_admin_123',
        competitionId: '10',
        inviteCode: 'CLASH7',
        createdAt: DateTime.now(),
        memberCount: 3,
      );
      repo.leagues.add(league);
      repo.membersMap[league.id] = [
        PrivateLeagueMember(
          privateLeagueId: league.id,
          userId: 'user_admin_123',
          username: 'PicoAdmin',
          picoPoints: 60,
          joinedAt: DateTime.now(),
        ),
        PrivateLeagueMember(
          privateLeagueId: league.id,
          userId: 'user_rival_456',
          username: 'RivalStriker',
          picoPoints: 40,
          joinedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        _buildTestHarness(
          child: LeagueChatScreen(
            leagueId: league.id,
            initialLeague: league,
          ),
          repo: repo,
        ),
      );
      await tester.pumpAndSettle();

      // Verify League title in AppBar
      expect(find.text('Clash Prediction League'), findsOneWidget);

      // Verify Active Members count
      expect(find.text('2 Active Members'), findsOneWidget);

      // Verify message input field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Message league...'), findsOneWidget);
    });

    testWidgets('Displays chat bubbles for current user and other members', (tester) async {
      final repo = _FakeLeagueChatTournamentRepository();
      final league = PrivateLeague(
        id: 'pl_room_2',
        name: 'Premier Banter',
        ownerId: 'user_admin_123',
        inviteCode: 'BANTER',
        createdAt: DateTime.now(),
      );
      repo.leagues.add(league);

      // Add messages: 1 from current user, 1 from rival
      repo.messagesMap[league.id] = [
        LeagueMessage(
          id: 'msg_2',
          leagueId: league.id,
          userId: 'user_admin_123',
          message: 'I predicted 2-1 for Madrid!',
          createdAt: DateTime.now(),
          username: 'PicoAdmin',
        ),
        LeagueMessage(
          id: 'msg_1',
          leagueId: league.id,
          userId: 'user_rival_456',
          message: 'No way, Barcelona is winning 3-0',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          username: 'RivalPlayer',
        ),
      ];

      await tester.pumpWidget(
        _buildTestHarness(
          child: LeagueChatScreen(
            leagueId: league.id,
            initialLeague: league,
          ),
          repo: repo,
        ),
      );
      await tester.pumpAndSettle();

      // Verify both messages are rendered
      expect(find.text('I predicted 2-1 for Madrid!'), findsOneWidget);
      expect(find.text('No way, Barcelona is winning 3-0'), findsOneWidget);

      // Verify rival username is rendered on their bubble
      expect(find.text('RivalPlayer'), findsOneWidget);
    });

    testWidgets('Submitting text in input field sends message', (tester) async {
      final repo = _FakeLeagueChatTournamentRepository();
      final league = PrivateLeague(
        id: 'pl_room_3',
        name: 'Test Send Room',
        ownerId: 'user_admin_123',
        inviteCode: 'SND001',
        createdAt: DateTime.now(),
      );
      repo.leagues.add(league);

      await tester.pumpWidget(
        _buildTestHarness(
          child: LeagueChatScreen(
            leagueId: league.id,
            initialLeague: league,
          ),
          repo: repo,
        ),
      );
      await tester.pumpAndSettle();

      // Enter text in input field
      await tester.enterText(find.byType(TextField), 'Testing gamey send button!');
      await tester.pump();

      // Tap send button
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      // Verify message is added to messagesMap and rendered in UI
      expect(repo.messagesMap[league.id], isNotEmpty);
      expect(repo.messagesMap[league.id]!.first.message, 'Testing gamey send button!');
      expect(find.text('Testing gamey send button!'), findsOneWidget);
    });

    testWidgets('Tapping AppBar title opens LeagueDetailsSheet', (tester) async {
      final repo = _FakeLeagueChatTournamentRepository();
      final league = PrivateLeague(
        id: 'pl_room_4',
        name: 'Trigger Tap League',
        ownerId: 'user_admin_123',
        adminId: 'user_admin_123',
        inviteCode: 'TRG999',
        createdAt: DateTime.now(),
      );
      repo.leagues.add(league);
      repo.membersMap[league.id] = [
        PrivateLeagueMember(
          privateLeagueId: league.id,
          userId: 'user_admin_123',
          username: 'PicoAdmin',
          picoPoints: 75,
          joinedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        _buildTestHarness(
          child: LeagueChatScreen(
            leagueId: league.id,
            initialLeague: league,
          ),
          repo: repo,
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the AppBar title region
      await tester.tap(find.text('Trigger Tap League'));
      await tester.pumpAndSettle();

      // Verify LeagueDetailsSheet is displayed
      expect(find.byType(LeagueDetailsSheet), findsOneWidget);
      expect(find.text('INVITE CODE'), findsOneWidget);
      expect(find.text('TRG999'), findsOneWidget);
      expect(find.text('LEADERBOARD'), findsOneWidget);
      expect(find.text('Leave League'), findsOneWidget);
    });
  });

  group('Private League Room: LeagueDetailsSheet (Leaderboard & Settings)', () {
    testWidgets('Renders Leaderboard ordered by points descending with ranks', (tester) async {
      final repo = _FakeLeagueChatTournamentRepository();
      final league = PrivateLeague(
        id: 'pl_sheet_1',
        name: 'Standing Champions',
        ownerId: 'user_admin_123',
        adminId: 'user_admin_123',
        inviteCode: 'WIN777',
        createdAt: DateTime.now(),
      );

      final members = [
        PrivateLeagueMember(
          privateLeagueId: league.id,
          userId: 'user_second',
          username: 'SilverPlayer',
          picoPoints: 35,
          joinedAt: DateTime.now(),
        ),
        PrivateLeagueMember(
          privateLeagueId: league.id,
          userId: 'user_admin_123',
          username: 'GoldLeader',
          picoPoints: 90,
          joinedAt: DateTime.now(),
        ),
        PrivateLeagueMember(
          privateLeagueId: league.id,
          userId: 'user_third',
          username: 'BronzePlayer',
          picoPoints: 15,
          joinedAt: DateTime.now(),
        ),
      ];
      repo.membersMap[league.id] = members;

      await tester.pumpWidget(
        _buildTestHarness(
          child: Scaffold(
            body: LeagueDetailsSheet(
              league: league,
              initialMembers: members,
            ),
          ),
          repo: repo,
        ),
      );
      await tester.pumpAndSettle();

      // Verify ranks #1, #2, #3
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('#2'), findsOneWidget);
      expect(find.text('#3'), findsOneWidget);

      // Verify usernames and points
      expect(find.text('GoldLeader'), findsOneWidget);
      expect(find.text('90 PTS'), findsOneWidget);
      expect(find.text('SilverPlayer'), findsOneWidget);
      expect(find.text('35 PTS'), findsOneWidget);
      expect(find.text('BronzePlayer'), findsOneWidget);
      expect(find.text('15 PTS'), findsOneWidget);

      // Verify (You) tag on current user
      expect(find.text('(You)'), findsOneWidget);
    });

    testWidgets('Admin user sees Kick icon next to rivals; non-admin does not', (tester) async {
      final repo = _FakeLeagueChatTournamentRepository();
      final league = PrivateLeague(
        id: 'pl_sheet_admin',
        name: 'Admin Control Room',
        ownerId: 'user_admin_123',
        adminId: 'user_admin_123',
        inviteCode: 'ADM123',
        createdAt: DateTime.now(),
      );

      final members = [
        PrivateLeagueMember(
          privateLeagueId: league.id,
          userId: 'user_admin_123',
          username: 'PicoAdmin',
          picoPoints: 50,
          joinedAt: DateTime.now(),
        ),
        PrivateLeagueMember(
          privateLeagueId: league.id,
          userId: 'user_rival_999',
          username: 'SpamUser',
          picoPoints: 0,
          joinedAt: DateTime.now(),
        ),
      ];
      repo.membersMap[league.id] = members;

      // 1. Render as Admin: Should see Kick icon
      await tester.pumpWidget(
        _buildTestHarness(
          child: Scaffold(
            body: LeagueDetailsSheet(
              league: league,
              initialMembers: members,
            ),
          ),
          repo: repo,
          currentUserId: 'user_admin_123', // Matches league.effectiveAdminId
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_remove_rounded), findsOneWidget);

      // 2. Render as regular member: Should NOT see Kick icon
      await tester.pumpWidget(
        _buildTestHarness(
          child: Scaffold(
            body: LeagueDetailsSheet(
              league: league,
              initialMembers: members,
            ),
          ),
          repo: repo,
          currentUserId: 'user_rival_999', // Regular member
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_remove_rounded), findsNothing);
    });

    testWidgets('Tapping Kick icon prompts confirmation and removes member', (tester) async {
      final repo = _FakeLeagueChatTournamentRepository();
      final league = PrivateLeague(
        id: 'pl_kick_test',
        name: 'Kick Test League',
        ownerId: 'user_admin_123',
        adminId: 'user_admin_123',
        inviteCode: 'KCK001',
        createdAt: DateTime.now(),
      );

      final members = [
        PrivateLeagueMember(
          privateLeagueId: league.id,
          userId: 'user_admin_123',
          username: 'PicoAdmin',
          picoPoints: 50,
          joinedAt: DateTime.now(),
        ),
        PrivateLeagueMember(
          privateLeagueId: league.id,
          userId: 'user_kickable',
          username: 'BadSport',
          picoPoints: 10,
          joinedAt: DateTime.now(),
        ),
      ];
      repo.membersMap[league.id] = members;

      await tester.pumpWidget(
        _buildTestHarness(
          child: Scaffold(
            body: LeagueDetailsSheet(
              league: league,
              initialMembers: members,
            ),
          ),
          repo: repo,
          currentUserId: 'user_admin_123',
        ),
      );
      await tester.pumpAndSettle();

      // Tap Kick icon
      await tester.tap(find.byIcon(Icons.person_remove_rounded));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Kick BadSport?'), findsOneWidget);

      // Confirm Kick
      await tester.tap(find.text('Kick'));
      await tester.pumpAndSettle();

      // Verify repository method called
      expect(repo.removedUserId, 'user_kickable');
    });

    testWidgets('Leave League button prompts confirmation dialog and calls RPC', (tester) async {
      final repo = _FakeLeagueChatTournamentRepository();
      final league = PrivateLeague(
        id: 'pl_leave_test',
        name: 'Leave Test League',
        ownerId: 'user_member_1',
        adminId: 'user_member_1',
        inviteCode: 'LVE001',
        createdAt: DateTime.now(),
      );

      final members = [
        PrivateLeagueMember(
          privateLeagueId: league.id,
          userId: 'user_member_1',
          username: 'DepartingPlayer',
          picoPoints: 20,
          joinedAt: DateTime.now(),
        ),
      ];
      repo.membersMap[league.id] = members;

      await tester.pumpWidget(
        _buildTestHarness(
          child: Scaffold(
            body: LeagueDetailsSheet(
              league: league,
              initialMembers: members,
            ),
          ),
          repo: repo,
          currentUserId: 'user_member_1',
        ),
      );
      await tester.pumpAndSettle();

      // Tap Leave League
      await tester.tap(find.text('Leave League'));
      await tester.pumpAndSettle();

      // Verify Dialog shown
      expect(find.text('Leave League?'), findsOneWidget);

      // Confirm Leave
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      // Verify repository leavePrivateLeague called
      expect(repo.leaveLeagueCalled, isTrue);
    });
  });
}
