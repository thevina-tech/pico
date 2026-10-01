import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/features/matches/domain/competition.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/private_league.dart';
import 'package:pico/features/tournaments/domain/private_league_member.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';
import 'package:pico/features/tournaments/domain/tournament_participant.dart';
import 'package:pico/features/tournaments/domain/private_league_exceptions.dart';
import 'package:pico/features/tournaments/presentation/create_private_league_screen.dart';
import 'package:pico/features/tournaments/presentation/join_private_league_screen.dart';
import 'package:pico/features/tournaments/presentation/public_tournament_screen.dart';
import 'package:pico/features/tournaments/presentation/private_tournament_screen.dart';
import 'package:pico/features/tournaments/domain/league_message.dart';
import 'package:pico/features/tournaments/presentation/tournaments_screen.dart';
import 'package:pico/shared/components/game_button.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _FakeTournamentRepository implements TournamentRepository {
  final List<Tournament> tournaments = [];
  final List<PrivateLeague> privateLeagues = [];
  final Map<String, List<PrivateLeagueMember>> leagueMembers = {};
  final Map<String, List<LeagueMessage>> leagueMessagesMap = {};
  final List<Competition> competitions = [
    const Competition(
      id: '1',
      name: 'Primera División (La Liga)',
      shortName: 'La Liga',
      flag: '🇪🇸',
    ),
    const Competition(
      id: '10',
      name: 'Premier League',
      shortName: 'Premier League',
      flag: '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
    ),
    const Competition(
      id: '7',
      name: 'Serie A',
      shortName: 'Serie A',
      flag: '🇮🇹',
    ),
    const Competition(
      id: '8',
      name: 'Bundesliga',
      shortName: 'Bundesliga',
      flag: '🇩🇪',
    ),
    const Competition(
      id: '16',
      name: 'Ligue 1',
      shortName: 'Ligue 1',
      flag: '🇫🇷',
    ),
    const Competition(
      id: '107',
      name: 'Champions League',
      shortName: 'UCL',
      flag: '⭐',
    ),
    const Competition(
      id: '117',
      name: 'Europa League',
      shortName: 'UEL',
      flag: '🟠',
    ),
    const Competition(
      id: '2492',
      name: 'Conference League',
      shortName: 'UECL',
      flag: '🟢',
    ),
  ];

  @override
  Future<List<Competition>> getCompetitions() async => competitions;

  @override
  Future<List<Tournament>> getPublicTournaments() async => tournaments;

  List<Tournament>? customEnrolledTournaments;
  final List<String> enrolledIds = [];

  @override
  Future<List<Tournament>> getEnrolledTournaments(String userId) async {
    if (customEnrolledTournaments != null) {
      final base = customEnrolledTournaments!;
      final newlyJoined = tournaments.where((t) => enrolledIds.contains(t.id));
      return {...base, ...newlyJoined}.toList();
    }
    return tournaments;
  }

  @override
  Future<void> enrollInDefaultTournaments({
    required String userId,
    required List<String> leagueIds,
  }) async {}

  @override
  Future<void> enrollInTournament({
    required String userId,
    required String tournamentId,
  }) async {
    if (!enrolledIds.contains(tournamentId)) {
      enrolledIds.add(tournamentId);
    }
  }

  @override
  Future<List<TournamentParticipant>> getParticipantsForUser(
    String userId,
  ) async => [];

  @override
  Future<List<PrivateLeague>> getUserPrivateLeagues(String userId) async =>
      privateLeagues;

  @override
  Future<PrivateLeague> createPrivateLeague({
    required String name,
    required String competitionId,
    required String userId,
    String description = '',
  }) async {
    final allowedIds = competitions.map((c) => c.id).toSet();
    if (!allowedIds.contains(competitionId)) {
      throw ArgumentError(
        'Competition $competitionId is not permitted for Sprint 4',
      );
    }
    final league = PrivateLeague(
      id: 'pl_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      ownerId: userId,
      competitionId: competitionId,
      inviteCode: 'PICO99',
      createdAt: DateTime.now(),
    );
    privateLeagues.add(league);
    leagueMembers[league.id] = [
      PrivateLeagueMember(
        privateLeagueId: league.id,
        userId: userId,
        picoPoints: 0,
        joinedAt: DateTime.now(),
      ),
    ];
    return league;
  }

  @override
  Future<PrivateLeague> joinPrivateLeagueByCode({
    required String inviteCode,
    required String userId,
  }) async {
    final cleanCode = inviteCode.trim().toUpperCase();
    if (cleanCode.length != 6) {
      throw ArgumentError('Invite code must be exactly 6 characters');
    }
    final league = privateLeagues.firstWhere(
      (l) => l.inviteCode.toUpperCase() == cleanCode,
      orElse: () => throw LeagueNotFoundException(cleanCode),
    );
    if (league.ownerId == userId) {
      throw LeagueCreatorCannotRejoinException(cleanCode);
    }
    final members = leagueMembers[league.id] ?? [];
    if (members.any((m) => m.userId == userId)) {
      throw LeagueAlreadyMemberException(cleanCode);
    }
    if (members.length >= league.maxCapacity) {
      throw const LeagueCapacityReachedException();
    }
    return league;
  }

  @override
  Future<List<PrivateLeagueMember>> getPrivateLeagueMembers(
    String leagueId,
  ) async {
    return leagueMembers[leagueId] ?? [];
  }

  @override
  Future<Tournament?> getTournamentById(String tournamentId) async {
    return tournaments.where((t) => t.id == tournamentId).firstOrNull;
  }

  @override
  Future<List<TournamentParticipant>> getTournamentLeaderboard(
    String tournamentId,
  ) async {
    return [
      TournamentParticipant(
        tournamentId: tournamentId,
        userId: 'test_owner_123',
        picoPoints: 45,
        username: 'PicoChamp',
        joinedAt: DateTime.now(),
      ),
      TournamentParticipant(
        tournamentId: tournamentId,
        userId: 'user_runner_up',
        picoPoints: 30,
        username: 'FootballFan99',
        joinedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<PrivateLeague?> getPrivateLeagueById(String leagueId) async {
    return privateLeagues.where((l) => l.id == leagueId).firstOrNull;
  }

  @override
  Future<void> deletePrivateLeague({
    required String leagueId,
    required String userId,
  }) async {
    final league = privateLeagues.firstWhere(
      (l) => l.id == leagueId,
      orElse: () => throw const LeagueNotFoundException(),
    );
    if (league.ownerId != userId) {
      throw const LeagueNotOwnerException();
    }
    privateLeagues.removeWhere((l) => l.id == leagueId);
    leagueMembers.remove(leagueId);
  }

  @override
  Future<void> removeMemberFromPrivateLeague({
    required String leagueId,
    required String targetUserId,
    required String adminUserId,
  }) async {
    final league = privateLeagues.firstWhere(
      (l) => l.id == leagueId,
      orElse: () => throw const LeagueNotFoundException(),
    );
    if (league.ownerId != adminUserId) {
      throw const LeagueNotOwnerException();
    }
    if (targetUserId == adminUserId) {
      throw const LeagueOwnerCannotBeRemovedException();
    }
    leagueMembers[leagueId]?.removeWhere((m) => m.userId == targetUserId);
  }

  @override
  Future<void> leavePrivateLeague({
    required String leagueId,
    required String userId,
  }) async {
    final league = privateLeagues.firstWhere(
      (l) => l.id == leagueId,
      orElse: () => throw const LeagueNotFoundException(),
    );
    if (league.ownerId == userId) {
      throw const LeagueOwnerCannotLeaveException();
    }
    leagueMembers[leagueId]?.removeWhere((m) => m.userId == userId);
  }

  @override
  Future<List<LeagueMessage>> getLeagueMessages(
    String leagueId, {
    int limit = 50,
  }) async {
    return List<LeagueMessage>.from(leagueMessagesMap[leagueId] ?? []);
  }

  @override
  Future<LeagueMessage> sendLeagueMessage({
    required String leagueId,
    required String userId,
    required String message,
    String? username,
    String? avatarUrl,
  }) async {
    final newMsg = LeagueMessage(
      id: 'mock_msg_${DateTime.now().millisecondsSinceEpoch}',
      leagueId: leagueId,
      userId: userId,
      message: message,
      createdAt: DateTime.now(),
      username: username ?? 'Player',
      avatarUrl: avatarUrl,
    );
    leagueMessagesMap.putIfAbsent(leagueId, () => []).insert(0, newMsg);
    return newMsg;
  }
}

class _FakeMemberAuthNotifier extends AuthNotifier {
  @override
  PicoAuthState build() {
    return const PicoAuthAuthenticated(
      user: supa.User(
        id: 'member_user_456',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      ),
      isPersonalized: true,
    );
  }
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  PicoAuthState build() {
    return const PicoAuthAuthenticated(
      user: supa.User(
        id: 'test_owner_123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      ),
      isPersonalized: true,
    );
  }
}

class _FakeProfileNotifier extends CurrentUserProfile {
  @override
  FutureOr<UserProfile> build() {
    return const UserProfile(
      id: 'test_owner_123',
      username: 'PicoChamp',
      level: 10,
      xp: 1200,
      streak: 5,
      coins: 200,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Sprint 4: Database-Backed Competitions (8 Top-Tier Limit)', () {
    test('TournamentRepository.getCompetitions returns the 8 supported competitions', () async {
      final repo = _FakeTournamentRepository();
      final comps = await repo.getCompetitions();
      expect(comps.length, equals(8));

      final names = comps.map((c) => c.name).toList();
      expect(names, contains('Primera División (La Liga)'));
      expect(names, contains('Premier League'));
      expect(names, contains('Serie A'));
      expect(names, contains('Bundesliga'));
      expect(names, contains('Ligue 1'));
      expect(names, contains('Champions League'));
      expect(names, contains('Europa League'));
      expect(names, contains('Conference League'));
    });

    test('Competition IDs match exact BeSoccer specifications', () async {
      final repo = _FakeTournamentRepository();
      final comps = await repo.getCompetitions();
      final map = {for (final c in comps) c.id: c};

      expect(map['1']?.name, equals('Primera División (La Liga)'));
      expect(map['10']?.name, equals('Premier League'));
      expect(map['7']?.name, equals('Serie A'));
      expect(map['8']?.name, equals('Bundesliga'));
      expect(map['16']?.name, equals('Ligue 1'));
      expect(map['107']?.name, equals('Champions League'));
      expect(map['117']?.name, equals('Europa League'));
      expect(map['2492']?.name, equals('Conference League'));
    });

    test('Competition provides shortName and flag from schema and defaults gracefully', () {
      final fromJson = Competition.fromJson({
        'id': '10',
        'name': 'Premier League',
        'short_name': 'Premier League',
        'flag': '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
      });
      expect(fromJson.flag, equals('🏴󠁧󠁢󠁥󠁮󠁧󠁿'));
      expect(fromJson.shortName, equals('Premier League'));

      const fallback = Competition(id: '99', name: 'Custom Cup');
      expect(fallback.flag, equals('🏆'));
      expect(fallback.displayName, equals('Custom Cup'));
    });
  });

  group('Sprint 4: Domain Models & Serialization', () {
    test('PrivateLeague serialization matches backend schema', () {
      final json = {
        'id': 'pl-uuid-1',
        'name': 'The Champions Club',
        'owner_id': 'user-uuid-123',
        'competition_id': '10',
        'invite_code': 'K9X2P1',
        'created_at': '2026-09-22T02:00:00.000Z',
      };

      final league = PrivateLeague.fromJson(json);
      expect(league.id, equals('pl-uuid-1'));
      expect(league.name, equals('The Champions Club'));
      expect(league.ownerId, equals('user-uuid-123'));
      expect(league.competitionId, equals('10'));
      expect(league.inviteCode, equals('K9X2P1'));

      final outJson = league.toJson();
      expect(outJson['invite_code'], equals('K9X2P1'));
      expect(outJson['competition_id'], equals('10'));
    });

    test('PrivateLeagueMember serialization handles points and joins', () {
      final json = {
        'private_league_id': 'pl-uuid-1',
        'user_id': 'user-uuid-123',
        'pico_points': 45,
        'joined_at': '2026-09-22T02:00:00.000Z',
      };

      final member = PrivateLeagueMember.fromJson(json);
      expect(member.privateLeagueId, equals('pl-uuid-1'));
      expect(member.userId, equals('user-uuid-123'));
      expect(member.picoPoints, equals(45));
    });

    test('Invite codes are exactly 6 uppercase alphanumeric characters', () {
      final codeRegex = RegExp(r'^[A-Z0-9]{6}$');
      expect(codeRegex.hasMatch('K9X2P1'), isTrue);
      expect(codeRegex.hasMatch('PICO99'), isTrue);
      expect(codeRegex.hasMatch('ABCDEF'), isTrue);

      expect(codeRegex.hasMatch('k9x2p1'), isFalse); // Lowercase
      expect(codeRegex.hasMatch('PICO-1'), isFalse); // Special character
      expect(codeRegex.hasMatch('TOOLONG123'), isFalse); // > 6 chars
      expect(codeRegex.hasMatch('SHORT'), isFalse); // < 6 chars
    });
  });

  group('Sprint 4: Tournament Repository & Business Logic', () {
    test('Create private league succeeds with allowed competition', () async {
      final repo = _FakeTournamentRepository();
      final league = await repo.createPrivateLeague(
        name: 'Friends League',
        competitionId: '1',
        userId: 'test_owner_123',
      );

      expect(league.name, equals('Friends League'));
      expect(league.competitionId, equals('1'));
      expect(league.inviteCode.length, equals(6));

      final members = await repo.getPrivateLeagueMembers(league.id);
      expect(members.length, equals(1));
      expect(members.first.userId, equals('test_owner_123'));
    });

    test('Create private league rejects non-curated competition', () async {
      final repo = _FakeTournamentRepository();
      expect(
        () => repo.createPrivateLeague(
          name: 'Invalid League',
          competitionId: '99',
          userId: 'test_owner_123',
        ),
        throwsArgumentError,
      );
    });

    test(
      'Join private league handles case-insensitive 6-character code',
      () async {
        final repo = _FakeTournamentRepository();
        await repo.createPrivateLeague(
          name: 'La Liga Fans',
          competitionId: '1',
          userId: 'test_owner_123',
        );

        // Join with lowercase version
        final joined = await repo.joinPrivateLeagueByCode(
          inviteCode: 'pico99',
          userId: 'joiner_456',
        );
        expect(joined.name, equals('La Liga Fans'));

        // Reject invalid lengths
        expect(
          () =>
              repo.joinPrivateLeagueByCode(inviteCode: '12345', userId: 'user'),
          throwsArgumentError,
        );
      },
    );

    test('Join private league throws LeagueNotFoundException for non-existent code', () async {
      final repo = _FakeTournamentRepository();
      expect(
        () => repo.joinPrivateLeagueByCode(
          inviteCode: 'ZZZZZZ',
          userId: 'user_456',
        ),
        throwsA(isA<LeagueNotFoundException>()),
      );
    });

    test('Join private league throws LeagueCreatorCannotRejoinException for creator', () async {
      final repo = _FakeTournamentRepository();
      await repo.createPrivateLeague(
        name: 'Creator League',
        competitionId: '1',
        userId: 'test_owner_123',
      );

      expect(
        () => repo.joinPrivateLeagueByCode(
          inviteCode: 'PICO99',
          userId: 'test_owner_123',
        ),
        throwsA(isA<LeagueCreatorCannotRejoinException>()),
      );
    });

    test('Join private league throws LeagueAlreadyMemberException for existing member', () async {
      final repo = _FakeTournamentRepository();
      final league = await repo.createPrivateLeague(
        name: 'Member League',
        competitionId: '1',
        userId: 'test_owner_123',
      );
      // Simulate member already in league
      repo.leagueMembers[league.id]!.add(
        PrivateLeagueMember(
          privateLeagueId: league.id,
          userId: 'already_member_456',
          picoPoints: 10,
          joinedAt: DateTime.now(),
        ),
      );

      expect(
        () => repo.joinPrivateLeagueByCode(
          inviteCode: 'PICO99',
          userId: 'already_member_456',
        ),
        throwsA(isA<LeagueAlreadyMemberException>()),
      );
    });

    test('Join private league throws LeagueCapacityReachedException when at max capacity (25 members)', () async {
      final repo = _FakeTournamentRepository();
      final league = await repo.createPrivateLeague(
        name: 'Full League',
        competitionId: '1',
        userId: 'owner_user_id',
      );
      // Populate 25 members
      repo.leagueMembers[league.id] = List.generate(
        25,
        (i) => PrivateLeagueMember(
          privateLeagueId: league.id,
          userId: 'user_$i',
          picoPoints: i,
          joinedAt: DateTime.now(),
        ),
      );

      expect(
        () => repo.joinPrivateLeagueByCode(
          inviteCode: league.inviteCode,
          userId: 'user_26_attempt',
        ),
        throwsA(isA<LeagueCapacityReachedException>()),
      );
    });
  });

  group('Sprint 4: UI & Widget Integration Tests', () {
    Widget buildHarness({
      required Widget child,
      TournamentRepository? repo,
      AuthNotifier Function()? authOverride,
      Locale? locale,
    }) {
      final fakeRepo = repo ?? _FakeTournamentRepository();
      return ProviderScope(
        overrides: [
          tournamentRepositoryProvider.overrideWithValue(fakeRepo),
          authProvider.overrideWith(authOverride ?? () => _FakeAuthNotifier()),
          currentUserProfileProvider.overrideWith(() => _FakeProfileNotifier()),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      );
    }

    testWidgets('TournamentsScreen renders tabs and switches between them', (
      tester,
    ) async {
      final repo = _FakeTournamentRepository();
      repo.tournaments.add(
        const Tournament(
          id: 't-1',
          name: 'La Liga 2025/26',
          competitionId: '1',
        ),
      );

      await tester.pumpWidget(
        buildHarness(child: const TournamentsScreen(), repo: repo),
      );
      await tester.pumpAndSettle();

      // Check header and tabs
      expect(find.text('Tournaments'), findsOneWidget);
      expect(find.text('My Leagues'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);

      // Tap on Discover tab
      await tester.tap(find.text('Discover'));
      await tester.pumpAndSettle();

      // Shows public tournaments section in Discover
      expect(find.text('TOP-TIER PUBLIC TOURNAMENTS'), findsOneWidget);
    });

    testWidgets(
      'TournamentsScreen renders Clash-inspired 3D mobile-game Create/Join button with tactile physics',
      (tester) async {
        final repo = _FakeTournamentRepository();
        await tester.pumpWidget(
          buildHarness(child: const TournamentsScreen(), repo: repo),
        );
        await tester.pumpAndSettle();

        final buttonFinder = find.text('+ Create / Join');
        expect(buttonFinder, findsOneWidget);

        // Verify the button text is styled with clean bold white typography with subtle shadow
        final textWidget = tester.widget<Text>(buttonFinder);
        expect(textWidget.style?.color, Colors.white);
        expect(textWidget.style?.fontWeight, FontWeight.w700);
        expect(textWidget.style?.shadows, isNotNull);
        expect(textWidget.style!.shadows!.isNotEmpty, isTrue);

        // Verify outer 3D extruded layer container has dark brown outline and amber base
        final animatedContainer = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: buttonFinder,
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        final decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFFB86000));
        expect(decoration.borderRadius, BorderRadius.circular(22.0));
        expect(decoration.border, isNotNull);
        expect(
          (decoration.border! as Border).top.color,
          const Color(0xFFB86600),
        );

        // Verify inner container has solid yellow/orange background and clean surface
        final innerContainer = tester
            .widgetList<Container>(
              find.descendant(
                of: find
                    .ancestor(
                      of: buttonFinder,
                      matching: find.byType(AnimatedContainer),
                    )
                    .first,
                matching: find.byType(Container),
              ),
            )
            .firstWhere(
              (c) =>
                  c.decoration is BoxDecoration &&
                  (c.decoration as BoxDecoration).color ==
                      const Color(0xFFFCCB2B),
            );
        final innerDecoration = innerContainer.decoration as BoxDecoration;
        expect(innerDecoration.color, const Color(0xFFFCCB2B));
        expect(innerDecoration.gradient, isNull);
        expect(innerDecoration.border, isNull);

        // Verify glossy specular highlight is rendered
        expect(
          find.descendant(
            of: find
                .ancestor(
                  of: buttonFinder,
                  matching: find.byType(AnimatedContainer),
                )
                .first,
            matching: find.byType(Transform),
          ),
          findsWidgets,
        );

        // Tap button and verify modal opens with options
        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();

        expect(find.text('Create Private League'), findsWidgets);
        expect(find.text('Join Private League'), findsOneWidget);
      },
    );

    testWidgets(
      'TournamentsScreen renders public tournaments BEFORE private leagues',
      (tester) async {
        final repo = _FakeTournamentRepository();
        repo.tournaments.add(
          const Tournament(
            id: 't-1',
            name: 'La Liga 2025/26',
            competitionId: '1',
          ),
        );
        repo.privateLeagues.add(
          PrivateLeague(
            id: 'pl-1',
            name: 'Friends Private League',
            ownerId: 'test_owner_123',
            competitionId: '10',
            inviteCode: 'CODE12',
            createdAt: DateTime.now(),
          ),
        );

        await tester.pumpWidget(
          buildHarness(child: const TournamentsScreen(), repo: repo),
        );
        await tester.pumpAndSettle();

        // Check both are rendered in My Leagues
        expect(find.text('PUBLIC TOURNAMENTS'), findsOneWidget);
        expect(find.text('PRIVATE LEAGUES'), findsOneWidget);

        // Verify vertical position: public tournaments appear before private leagues
        final publicPos = tester.getTopLeft(find.text('PUBLIC TOURNAMENTS')).dy;
        final privatePos = tester.getTopLeft(find.text('PRIVATE LEAGUES')).dy;
        expect(publicPos, lessThan(privatePos));
      },
    );

    testWidgets(
      'CreatePrivateLeagueScreen strictly displays the 8 curated competitions',
      (tester) async {
        final repo = _FakeTournamentRepository();
        await tester.pumpWidget(
          buildHarness(child: const CreatePrivateLeagueScreen(), repo: repo),
        );
        await tester.pumpAndSettle();

        expect(find.text('Create Private League'), findsWidgets);
        expect(find.text('BASE TOURNAMENT / COMPETITION'), findsOneWidget);
        expect(find.text('8 available'), findsOneWidget);

        // Initially prompts user to select a base competition
        expect(find.text('Select Base Competition'), findsOneWidget);

        // Scroll until the competition picker is visible
        await tester.scrollUntilVisible(
          find.text('Select Base Competition'),
          50.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        // Open the competition picker modal
        await tester.tap(find.text('Select Base Competition'));
        await tester.pumpAndSettle();

        // Verify the modal title
        expect(
          find.text('Select Base Tournament (8 Available)'),
          findsOneWidget,
        );

        // Verify visible competitions in modal
        expect(find.text('Premier League'), findsOneWidget);
        expect(find.text('Serie A'), findsOneWidget);

        // Scroll to verify the later items
        await tester.scrollUntilVisible(
          find.text('Ligue 1'),
          50.0,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text('Ligue 1'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text('Conference League'),
          50.0,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.text('Conference League'), findsOneWidget);
      },
    );

    testWidgets(
      'CreatePrivateLeagueScreen creates league and displays centered notification dialog modal (not bottom sheet)',
      (tester) async {
        final repo = _FakeTournamentRepository();
        await tester.pumpWidget(
          buildHarness(child: const CreatePrivateLeagueScreen(), repo: repo),
        );
        await tester.pumpAndSettle();

        // Enter league name
        await tester.enterText(
          find.byKey(const Key('league_name_field')),
          'Champions League of Friends',
        );
        await tester.pumpAndSettle();

        // Select competition from dropdown
        await tester.scrollUntilVisible(
          find.text('Select Base Competition'),
          50.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Select Base Competition'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Primera División (La Liga)').first);
        await tester.pumpAndSettle();

        // Drag ListView down to reveal the submit button
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();

        // Tap Create League button
        await tester.tap(find.byType(GameButton));
        await tester.pumpAndSettle();

        // Crucially verify it is a centered Dialog container and NOT a BottomSheet
        expect(find.byType(Dialog), findsOneWidget);
        expect(find.byType(BottomSheet), findsNothing);

        // Verify the dialog contents
        expect(
          find.descendant(
            of: find.byType(Dialog),
            matching: find.text('League Created! 🎉'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(Dialog),
            matching: find.text('Champions League of Friends'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(Dialog),
            matching: find.text('INVITE CODE'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: find.byType(Dialog), matching: find.text('P')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: find.byType(Dialog), matching: find.text('I')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: find.byType(Dialog), matching: find.text('C')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: find.byType(Dialog), matching: find.text('O')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: find.byType(Dialog), matching: find.text('9')),
          findsNWidgets(2),
        ); // PICO99
        expect(
          find.descendant(
            of: find.byType(Dialog),
            matching: find.text('Copy Code'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: find.byType(Dialog), matching: find.text('Done')),
          findsOneWidget,
        );

        // Tap Done dismisses the modal dialog
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
      },
    );

    testWidgets(
      'CreatePrivateLeagueScreen displays success SnackBar before ad transition and dialog modal',
      (tester) async {
        final repo = _FakeTournamentRepository();
        await tester.pumpWidget(
          buildHarness(child: const CreatePrivateLeagueScreen(), repo: repo),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('league_name_field')),
          'Test SnackBar League',
        );
        await tester.pumpAndSettle();

        // Select competition from dropdown
        await tester.scrollUntilVisible(
          find.text('Select Base Competition'),
          50.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Select Base Competition'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Primera División (La Liga)').first);
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(GameButton));
        // Pump initial frame so backend execution completes and SnackBar is posted
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Visibly verify the success SnackBar is rendered
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('League created successfully!'), findsOneWidget);

        await tester.pumpAndSettle();

        // Verify the dialog modal is displayed upon ad transition
        expect(find.byType(Dialog), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(Dialog),
            matching: find.text('Test SnackBar League'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'CreatePrivateLeagueScreen security note does not overflow on narrow screen with Spanish locale',
      (tester) async {
        tester.view.physicalSize = const Size(360 * 3, 700 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final repo = _FakeTournamentRepository();
        await tester.pumpWidget(
          buildHarness(
            child: const CreatePrivateLeagueScreen(),
            repo: repo,
            locale: const Locale('es'),
          ),
        );
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(0, -400));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Solo los jugadores con tu código de invitación podrán unirse',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('JoinPrivateLeagueScreen accepts 6-character code input', (
      tester,
    ) async {
      final repo = _FakeTournamentRepository();
      await tester.pumpWidget(
        buildHarness(child: const JoinPrivateLeagueScreen(), repo: repo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Join Private League'), findsWidgets);
      expect(find.text('ENTER 6-CHARACTER CODE'), findsOneWidget);

      // Enter a 6-character code
      await tester.enterText(find.byType(TextField), 'PICO99');
      await tester.pumpAndSettle();

      expect(find.text('P'), findsWidgets);
      expect(find.text('I'), findsWidgets);
      expect(find.text('C'), findsWidgets);
      expect(find.text('O'), findsWidgets);
      expect(find.text('9'), findsWidgets);
    });

    testWidgets(
      'JoinPrivateLeagueScreen shows SnackBar when league has reached capacity',
      (tester) async {
        final repo = _FakeTournamentRepository();
        final fullLeague = await repo.createPrivateLeague(
          name: 'Full Clan',
          competitionId: '1',
          userId: 'owner_user_id',
        );
        repo.leagueMembers[fullLeague.id] = List.generate(
          25,
          (i) => PrivateLeagueMember(
            privateLeagueId: fullLeague.id,
            userId: 'user_$i',
            picoPoints: 0,
            joinedAt: DateTime.now(),
          ),
        );

        await tester.pumpWidget(
          buildHarness(child: const JoinPrivateLeagueScreen(), repo: repo),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), fullLeague.inviteCode);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(GameButton));
        await tester.pumpAndSettle();

        expect(
          find.text('This league is full (Max 25 members).'),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'PublicTournamentScreen renders tournament header and switches tabs',
      (tester) async {
        final repo = _FakeTournamentRepository();
        const tournament = Tournament(
          id: 'tourn_la_liga',
          name: 'La Liga Tournament',
          competitionId: '1',
        );
        repo.tournaments.add(tournament);

        await tester.pumpWidget(
          buildHarness(
            child: const PublicTournamentScreen(
              tournamentId: 'tourn_la_liga',
              initialTournament: tournament,
            ),
            repo: repo,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Tournament Details'), findsOneWidget);
        expect(find.text('La Liga Tournament'), findsOneWidget);
        expect(find.text('Standings'), findsOneWidget);
        expect(find.text('Matches'), findsOneWidget);

        // Verify Leaderboard content
        expect(find.text('PicoChamp'), findsOneWidget);
        expect(find.text('FootballFan99'), findsOneWidget);

        // Switch to Matches tab
        await tester.tap(find.text('Matches'));
        await tester.pumpAndSettle();

        expect(find.text('Matches'), findsWidgets);
      },
    );

    testWidgets(
      'PrivateTournamentScreen renders Admin Controls when isOwner is true',
      (tester) async {
        final repo = _FakeTournamentRepository();
        final league = PrivateLeague(
          id: 'pl_123',
          name: 'Champs League',
          ownerId: 'test_owner_123', // Matches _FakeAuthNotifier
          competitionId: '107',
          inviteCode: 'K9X2P1',
          createdAt: DateTime.now(),
          memberCount: 2,
        );
        repo.privateLeagues.add(league);
        repo.leagueMembers[league.id] = [
          PrivateLeagueMember(
            privateLeagueId: league.id,
            userId: 'test_owner_123',
            username: 'PicoChamp (Creator)',
            picoPoints: 50,
            joinedAt: DateTime.now(),
          ),
          PrivateLeagueMember(
            privateLeagueId: league.id,
            userId: 'member_999',
            username: 'RivalPlayer',
            picoPoints: 30,
            joinedAt: DateTime.now(),
          ),
        ];

        await tester.pumpWidget(
          buildHarness(
            child: PrivateTournamentScreen(
              leagueId: league.id,
              initialLeague: league,
            ),
            repo: repo,
          ),
        );
        await tester.pumpAndSettle();

        // Verify Standings tab strictly displays standings
        expect(find.text('STANDINGS'), findsOneWidget);
        expect(find.text('Delete League'), findsNothing);

        // Verify Remove Member button is available for other members
        expect(
          find.byIcon(Icons.remove_circle_outline_rounded),
          findsOneWidget,
        );

        // Verify Leave League is NOT shown in app bar
        expect(find.byIcon(Icons.logout_rounded), findsNothing);

        // Tap settings button to open LeagueDetailsSheet
        await tester.tap(find.byKey(const Key('league_settings_button')));
        await tester.pumpAndSettle();

        // Inside LeagueDetailsSheet:
        expect(find.text('INVITE CODE'), findsOneWidget);
        expect(find.text('K9X2P1'), findsOneWidget);
        expect(find.text('ADMIN CONTROLS'), findsOneWidget);
        expect(find.text('Delete League'), findsOneWidget);
      },
    );

    testWidgets(
      'PrivateTournamentScreen hides Admin Controls when isOwner is false',
      (tester) async {
        final repo = _FakeTournamentRepository();
        final league = PrivateLeague(
          id: 'pl_456',
          name: 'Friends League',
          ownerId: 'test_owner_123', // Does NOT match member_user_456
          competitionId: '1',
          inviteCode: 'ABCDEF',
          createdAt: DateTime.now(),
          memberCount: 2,
        );
        repo.privateLeagues.add(league);
        repo.leagueMembers[league.id] = [
          PrivateLeagueMember(
            privateLeagueId: league.id,
            userId: 'test_owner_123',
            username: 'OwnerUser',
            picoPoints: 40,
            joinedAt: DateTime.now(),
          ),
          PrivateLeagueMember(
            privateLeagueId: league.id,
            userId: 'member_user_456',
            username: 'MemberUser',
            picoPoints: 20,
            joinedAt: DateTime.now(),
          ),
        ];

        await tester.pumpWidget(
          buildHarness(
            child: PrivateTournamentScreen(
              leagueId: league.id,
              initialLeague: league,
            ),
            repo: repo,
            authOverride: () => _FakeMemberAuthNotifier(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Admin Controls are NOT rendered on standings
        expect(find.text('ADMIN CONTROLS'), findsNothing);
        expect(find.text('Delete League'), findsNothing);

        // Verify Remove Member button is NOT rendered
        expect(find.byIcon(Icons.remove_circle_outline_rounded), findsNothing);

        // Verify logout icon is NOT in app bar
        expect(find.byIcon(Icons.logout_rounded), findsNothing);

        // Tap settings button to open LeagueDetailsSheet
        await tester.tap(find.byKey(const Key('league_settings_button')));
        await tester.pumpAndSettle();

        // Verify Leave League button IS rendered in sheet for members
        expect(find.text('Leave League'), findsOneWidget);
        expect(find.text('ADMIN CONTROLS'), findsNothing);
      },
    );

    testWidgets(
      'PublicTournamentScreen renders accented Primera División, standings, and Join CTA when not joined',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(800, 1400);
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final repo = _FakeTournamentRepository();
        const tournament = Tournament(
          id: '10000000-0000-0000-0000-000000000001',
          name: 'Primera División',
          competitionId: '1',
        );
        repo.tournaments.add(tournament);
        repo.customEnrolledTournaments = []; // Not joined

        await tester.pumpWidget(
          buildHarness(
            child: const PublicTournamentScreen(
              tournamentId: '10000000-0000-0000-0000-000000000001',
              initialTournament: tournament,
            ),
            repo: repo,
            authOverride: () => _FakeAuthNotifier(),
          ),
        );
        await tester.pumpAndSettle();

        // Accented tournament name is properly rendered
        expect(find.text('Primera División'), findsOneWidget);

        // Standings/leaderboard are viewable even without being enrolled
        expect(find.text('PicoChamp'), findsOneWidget);
        expect(find.text('FootballFan99'), findsOneWidget);

        // Attractive Join CTA banner is rendered
        expect(find.text('JOIN THE COMPETITION'), findsOneWidget);
        expect(find.text('Predict & Compete'), findsOneWidget);
        expect(find.text('Join Tournament'), findsOneWidget);

        // Tap Join Tournament CTA
        await tester.tap(find.text('Join Tournament'));
        await tester.pumpAndSettle();

        // Confirm Join in Pico Confirmation Modal
        if (find.text('Join ${tournament.name}?').evaluate().isNotEmpty) {
          await tester.tap(find.text('Join Tournament').last);
          await tester.pumpAndSettle();
        }

        // Verify user enrolled
        expect(repo.enrolledIds.contains(tournament.id), isTrue);
      },
    );

    testWidgets(
      'TournamentsScreen cards are clickable and Discover tab shows Join CTA for unjoined tournaments',
      (tester) async {
        final repo = _FakeTournamentRepository();
        const tournament = Tournament(
          id: '10000000-0000-0000-0000-000000000001',
          name: 'Primera División',
          competitionId: '1',
        );
        repo.tournaments.add(tournament);
        repo.customEnrolledTournaments = []; // User has not joined yet

        await tester.pumpWidget(
          buildHarness(
            child: const TournamentsScreen(),
            repo: repo,
            authOverride: () => _FakeAuthNotifier(),
          ),
        );
        await tester.pumpAndSettle();

        // Switch to Discover tab
        await tester.tap(find.text('Discover'));
        await tester.pumpAndSettle();

        // Accented tournament name is rendered
        expect(find.text('Primera División'), findsOneWidget);

        // Unjoined tournament displays a Join button
        expect(find.text('Join'), findsOneWidget);

        // Card is wrapped in an InkWell (clickable card container)
        expect(find.byType(InkWell), findsWidgets);

        // Tap Join button
        await tester.tap(find.text('Join'));
        await tester.pumpAndSettle();

        // Confirm Join in Pico Confirmation Modal
        if (find.text('Join ${tournament.name}?').evaluate().isNotEmpty) {
          await tester.tap(find.text('Join Tournament'));
          await tester.pumpAndSettle();
        }

        // Verify user enrolled in repository
        expect(repo.enrolledIds.contains(tournament.id), isTrue);
      },
    );
  });
}
