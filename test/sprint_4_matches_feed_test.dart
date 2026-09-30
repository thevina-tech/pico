import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_controller.dart';
import 'package:pico/features/matches/presentation/matches_screen.dart';
import 'package:pico/features/matches/presentation/matches_view_model.dart';
import 'package:pico/features/predictions/domain/prediction.dart';
import 'package:pico/features/predictions/presentation/prediction_controller.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _FakeAuthNotifier extends AuthNotifier {
  @override
  PicoAuthState build() {
    return const PicoAuthAuthenticated(
      user: supa.User(
        id: 'test_user_feed',
        appMetadata: {},
        userMetadata: {'full_name': 'Striker'},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      ),
      isPersonalized: true,
    );
  }
}

class _FakeProfileNotifier extends CurrentUserProfile {
  @override
  FutureOr<UserProfile> build() => const UserProfile(
        id: 'test_user_feed',
        username: 'Striker',
        level: 4,
        xp: 350,
        coins: 500,
        streak: 2,
      );
}

class _FakePredictionController extends PredictionController {
  _FakePredictionController(this._predictions);
  final Map<String, Prediction> _predictions;

  @override
  FutureOr<Map<String, Prediction>> build() => _predictions;
}

class _TestMatchesController extends MatchesController {
  _TestMatchesController(this._matches, {this.initialTab = MatchTab.upcoming});
  final List<PicoMatch> _matches;
  final MatchTab initialTab;

  @override
  FutureOr<MatchesState> build() {
    return MatchesState(
      allMatches: _matches,
      filters: const [
        MatchFilterChipData(
          label: 'All',
          competitionName: 'All',
          count: 0,
        ),
      ],
      selectedTab: initialTab,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.now();

  // 1. Live match
  final liveMatch = PicoMatch(
    id: 'match_live_1',
    competitionId: 'premier_league',
    competitionName: 'Premier League',
    homeTeamName: 'Arsenal',
    homeTeamCode: 'ARS',
    awayTeamName: 'Chelsea',
    awayTeamCode: 'CHE',
    kickoffAt: now.subtract(const Duration(minutes: 45)),
    status: MatchStatus.live,
    homeScore: 1,
    awayScore: 0,
  );

  // 2. Upcoming match within 3 days (prediction window open)
  final openUpcomingMatch = PicoMatch(
    id: 'match_upcoming_open',
    competitionId: 'premier_league',
    competitionName: 'Premier League',
    homeTeamName: 'Liverpool',
    homeTeamCode: 'LIV',
    awayTeamName: 'Manchester United',
    awayTeamCode: 'MUN',
    kickoffAt: now.add(const Duration(days: 2)),
    status: MatchStatus.upcoming,
  );

  // 3. Upcoming match in teaser window (5 days away -> opens in 2 days with 3-day window)
  final teaserMatch = PicoMatch(
    id: 'match_upcoming_teaser',
    competitionId: 'la_liga',
    competitionName: 'La Liga',
    homeTeamName: 'Real Madrid',
    homeTeamCode: 'RMA',
    awayTeamName: 'Barcelona',
    awayTeamCode: 'BAR',
    kickoffAt: now.add(const Duration(days: 5, hours: 2)),
    status: MatchStatus.upcoming,
  );

  // 4. Upcoming match beyond 14 days (17 days away)
  final distantMatch = PicoMatch(
    id: 'match_distant',
    competitionId: 'la_liga',
    competitionName: 'La Liga',
    homeTeamName: 'Atletico Madrid',
    homeTeamCode: 'ATM',
    awayTeamName: 'Sevilla',
    awayTeamCode: 'SEV',
    kickoffAt: now.add(const Duration(days: 17)),
    status: MatchStatus.upcoming,
  );

  // 5. Finished matches (within 7 days) with different settlement outcomes
  final finishedMatchExact = PicoMatch(
    id: 'match_fin_exact',
    competitionId: 'premier_league',
    competitionName: 'Premier League',
    homeTeamName: 'Manchester City',
    homeTeamCode: 'MCI',
    awayTeamName: 'Tottenham',
    awayTeamCode: 'TOT',
    kickoffAt: now.subtract(const Duration(days: 2)),
    status: MatchStatus.finished,
    homeScore: 2,
    awayScore: 1,
    settled: true,
  );

  final finishedMatchWinner = PicoMatch(
    id: 'match_fin_winner',
    competitionId: 'la_liga',
    competitionName: 'La Liga',
    homeTeamName: 'Real Betis',
    homeTeamCode: 'BET',
    awayTeamName: 'Villarreal',
    awayTeamCode: 'VIL',
    kickoffAt: now.subtract(const Duration(days: 3)),
    status: MatchStatus.finished,
    homeScore: 3,
    awayScore: 1,
    settled: true,
  );

  final finishedMatchWrong = PicoMatch(
    id: 'match_fin_wrong',
    competitionId: 'la_liga',
    competitionName: 'La Liga',
    homeTeamName: 'Valencia',
    homeTeamCode: 'VAL',
    awayTeamName: 'Getafe',
    awayTeamCode: 'GET',
    kickoffAt: now.subtract(const Duration(days: 4)),
    status: MatchStatus.finished,
    homeScore: 0,
    awayScore: 2,
    settled: true,
  );

  final finishedMatchUnpredicted = PicoMatch(
    id: 'match_fin_unpred',
    competitionId: 'serie_a',
    competitionName: 'Serie A',
    homeTeamName: 'Juventus',
    homeTeamCode: 'JUV',
    awayTeamName: 'Inter',
    awayTeamCode: 'INT',
    kickoffAt: now.subtract(const Duration(days: 5)),
    status: MatchStatus.finished,
    homeScore: 1,
    awayScore: 1,
    settled: true,
  );

  final allTestMatches = [
    liveMatch,
    openUpcomingMatch,
    teaserMatch,
    distantMatch,
    finishedMatchExact,
    finishedMatchWinner,
    finishedMatchWrong,
    finishedMatchUnpredicted,
  ];

  final mockUserPredictions = <String, Prediction>{
    'match_fin_exact': Prediction(
      id: 'pred_1',
      userId: 'test_user_feed',
      matchId: 'match_fin_exact',
      homeScore: 2,
      awayScore: 1,
      predictedWinner: 'home',
    ),
    'match_fin_winner': Prediction(
      id: 'pred_2',
      userId: 'test_user_feed',
      matchId: 'match_fin_winner',
      homeScore: 2,
      awayScore: 0,
      predictedWinner: 'home',
    ),
    'match_fin_wrong': Prediction(
      id: 'pred_3',
      userId: 'test_user_feed',
      matchId: 'match_fin_wrong',
      homeScore: 1,
      awayScore: 0,
      predictedWinner: 'home',
    ),
  };

  group('Sprint 4: Categorized Match Feed & Rolling Prediction Windows', () {
    testWidgets('Renders categorized top tabs and switches smoothly between Live, Upcoming, and Finished',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _FakeAuthNotifier()),
            currentUserProfileProvider.overrideWith(() => _FakeProfileNotifier()),
            predictionControllerProvider.overrideWith(() => _FakePredictionController(mockUserPredictions)),
            matchesControllerProvider.overrideWith(
              () => _TestMatchesController(allTestMatches, initialTab: MatchTab.upcoming),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MatchesScreen(showBottomNavBar: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top tab bar should be visible with Live, Upcoming, and Finished
      expect(find.text('Live'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Finished'), findsOneWidget);

      // In Upcoming view: open match (Liverpool) and teaser match (Real Madrid) are present
      expect(find.text('Liverpool'), findsOneWidget);
      expect(find.text('Real Madrid'), findsOneWidget);
      // Distant match (> 14 days) should NOT be in the upcoming feed
      expect(find.text('Atletico Madrid'), findsNothing);
      // Live and Finished matches should NOT be in Upcoming tab
      expect(find.text('Arsenal'), findsNothing);
      expect(find.text('Manchester City'), findsNothing);

      // Switch to Live Tab
      await tester.tap(find.text('Live'));
      await tester.pumpAndSettle();

      // Now Live match (Arsenal vs Chelsea) is visible
      expect(find.text('Arsenal'), findsOneWidget);
      expect(find.text('Liverpool'), findsNothing);
      expect(find.text('Manchester City'), findsNothing);

      // Switch to Finished Tab
      await tester.tap(find.text('Finished'));
      await tester.pumpAndSettle();

      // Finished matches are visible
      expect(find.text('Manchester City'), findsOneWidget);
      expect(find.text('Real Betis'), findsOneWidget);
      expect(find.text('Valencia'), findsOneWidget);
      expect(find.text('Juventus'), findsOneWidget);
      expect(find.text('Arsenal'), findsNothing);
      expect(find.text('Liverpool'), findsNothing);
    });

    testWidgets('Teaser Mechanic: Match <= 3 days has enabled Predict button; match > 3 days has disabled countdown',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _FakeAuthNotifier()),
            currentUserProfileProvider.overrideWith(() => _FakeProfileNotifier()),
            predictionControllerProvider.overrideWith(() => _FakePredictionController({})),
            matchesControllerProvider.overrideWith(
              () => _TestMatchesController(allTestMatches, initialTab: MatchTab.upcoming),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MatchesScreen(showBottomNavBar: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Match <= 3 days (Liverpool vs MUN): Enabled Predict button
      expect(find.text('Make Prediction →'), findsOneWidget);

      // Match > 3 days (Real Madrid vs Barcelona): Disabled countdown button (Opens in 2d)
      expect(find.text('Opens in 2d'), findsOneWidget);
      expect(find.text('OPENS SOON'), findsOneWidget);

      // Tapping the teaser button does NOT open the prediction bottom sheet
      await tester.tap(find.text('Opens in 2d'));
      await tester.pumpAndSettle();

      // Bottom sheet header must NOT appear
      expect(find.text('Pick the Winner'), findsNothing);

      // Tapping the active match's "Make Prediction →" opens the modal
      await tester.tap(find.text('Make Prediction →'));
      await tester.pumpAndSettle();

      expect(find.text('Pick the Winner'), findsOneWidget);
      expect(find.text('LIV'), findsWidgets);
    });

    testWidgets('Personal Settlement History: Displays exact points outcome (+5, +3, 0, No Prediction)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _FakeAuthNotifier()),
            currentUserProfileProvider.overrideWith(() => _FakeProfileNotifier()),
            predictionControllerProvider.overrideWith(() => _FakePredictionController(mockUserPredictions)),
            matchesControllerProvider.overrideWith(
              () => _TestMatchesController(allTestMatches, initialTab: MatchTab.finished),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MatchesScreen(showBottomNavBar: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Exact score (City 2-1 Spurs, predicted 2-1) -> +5 Points
      expect(find.text('+5 Points'), findsOneWidget);

      // 2. Correct winner (Betis 3-1 Villarreal, predicted 2-0) -> +3 Points
      expect(find.text('+3 Points'), findsOneWidget);

      // 3. Incorrect (Valencia 0-2 Getafe, predicted 1-0) -> 0 Points
      expect(find.text('0 Points'), findsOneWidget);

      // 4. Unpredicted (Juventus 1-1 Inter, no prediction submitted) -> No Prediction
      expect(find.text('No Prediction'), findsOneWidget);
    });

    testWidgets('Spanish Localization: Categorized tabs, teaser countdown, and settlement strings in Spanish',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _FakeAuthNotifier()),
            currentUserProfileProvider.overrideWith(() => _FakeProfileNotifier()),
            predictionControllerProvider.overrideWith(() => _FakePredictionController(mockUserPredictions)),
            matchesControllerProvider.overrideWith(
              () => _TestMatchesController(allTestMatches, initialTab: MatchTab.upcoming),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MatchesScreen(showBottomNavBar: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Spanish tab labels
      expect(find.text('En Vivo'), findsOneWidget);
      expect(find.text('Próximos'), findsOneWidget);
      expect(find.text('Finalizados'), findsOneWidget);

      // Spanish teaser button
      expect(find.text('Abre en 2d'), findsOneWidget);

      // Switch to finished tab and verify Spanish points
      await tester.tap(find.text('Finalizados'));
      await tester.pumpAndSettle();

      expect(find.text('+5 Puntos'), findsOneWidget);
      expect(find.text('+3 Puntos'), findsOneWidget);
      expect(find.text('0 Puntos'), findsOneWidget);
      expect(find.text('Sin Predicción'), findsOneWidget);
    });

    testWidgets('MatchesScreen renders 3D tactile tab buttons with vertical icon/text and bright active background',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _FakeAuthNotifier()),
            currentUserProfileProvider.overrideWith(() => _FakeProfileNotifier()),
            predictionControllerProvider.overrideWith(() => _FakePredictionController(mockUserPredictions)),
            matchesControllerProvider.overrideWith(
              () => _TestMatchesController(allTestMatches, initialTab: MatchTab.live),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MatchesScreen(showBottomNavBar: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final liveText = find.text('Live');
      final upcomingText = find.text('Upcoming');
      final finishedText = find.text('Finished');

      expect(liveText, findsOneWidget);
      expect(upcomingText, findsOneWidget);
      expect(finishedText, findsOneWidget);

      // Verify Column layout: Icon is above text
      final liveIcon = find.descendant(
        of: find.ancestor(of: liveText, matching: find.byType(Column)),
        matching: find.byIcon(Icons.sensors_rounded),
      );
      final upcomingIcon = find.descendant(
        of: find.ancestor(of: upcomingText, matching: find.byType(Column)),
        matching: find.byIcon(Icons.schedule_rounded),
      );
      final finishedIcon = find.descendant(
        of: find.ancestor(of: finishedText, matching: find.byType(Column)),
        matching: find.byIcon(Icons.task_alt_rounded),
      );

      expect(liveIcon, findsOneWidget);
      expect(upcomingIcon, findsOneWidget);
      expect(finishedIcon, findsOneWidget);
      expect(tester.getTopLeft(liveIcon).dy < tester.getTopLeft(liveText).dy, isTrue);
      expect(tester.getTopLeft(upcomingIcon).dy < tester.getTopLeft(upcomingText).dy, isTrue);
      expect(tester.getTopLeft(finishedIcon).dy < tester.getTopLeft(finishedText).dy, isTrue);

      // Verify Live tab is initially active with bright background Color(0xFFF7F4EC)
      final liveSurface = tester.widgetList<Container>(
        find.descendant(
          of: find.ancestor(of: liveText, matching: find.byType(AnimatedContainer)),
          matching: find.byType(Container),
        ),
      ).elementAt(1);
      expect((liveSurface.decoration as BoxDecoration).color, const Color(0xFFF7F4EC));

      // Tapping Upcoming switches active tab and sets its background to bright Color(0xFFF7F4EC)
      await tester.tap(upcomingText);
      await tester.pumpAndSettle();

      final upcomingSurface = tester.widgetList<Container>(
        find.descendant(
          of: find.ancestor(of: upcomingText, matching: find.byType(AnimatedContainer)),
          matching: find.byType(Container),
        ),
      ).elementAt(1);
      expect((upcomingSurface.decoration as BoxDecoration).color, const Color(0xFFF7F4EC));

      // Live should now be inactive with dark background Color(0xFF162534)
      final inactiveLiveSurface = tester.widgetList<Container>(
        find.descendant(
          of: find.ancestor(of: liveText, matching: find.byType(AnimatedContainer)),
          matching: find.byType(Container),
        ),
      );
      expect(
        inactiveLiveSurface.any((c) => (c.decoration as BoxDecoration?)?.color == const Color(0xFF162534)),
        isTrue,
      );
    });
  });
}
