import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/matches/data/match_repository.dart';
import 'package:pico/features/matches/presentation/matches_controller.dart';
import 'package:pico/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Sprint 0 - Environment (.env)', () {
    test('dotenv loads .env successfully from assets bundle', () async {
      await dotenv.load(fileName: ".env");
      expect(dotenv.env['SUPABASE_URL'], isNotEmpty);
      expect(dotenv.env['SUPABASE_ANON_KEY'], isNotEmpty);
      expect(dotenv.env['BESOCCER_API_KEY'], isNotEmpty);
    });
  });

  group('Sprint 0 - Localization', () {
    test('AppLocalizations supports en and es locales', () {
      expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('es')));
    });

    testWidgets('AppLocalizations resolves English and Spanish strings',
        (WidgetTester tester) async {
      late AppLocalizations enLoc;
      late AppLocalizations esLoc;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              enLoc = AppLocalizations.of(context)!;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(enLoc.appTitle, 'Pico');
      expect(enLoc.predictButton, 'Predict');
      expect(enLoc.navHome, 'Home');
      expect(enLoc.navMatches, 'Matches');
      expect(enLoc.predictBy('19:50'), 'Predict by 19:50');

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Builder(
            builder: (context) {
              esLoc = AppLocalizations.of(context)!;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(esLoc.appTitle, 'Pico');
      expect(esLoc.predictButton, 'Predecir');
      expect(esLoc.navHome, 'Inicio');
      expect(esLoc.navMatches, 'Partidos');
      expect(esLoc.predictBy('19:50'), 'Predecir antes de 19:50');
    });
  });

  group('Sprint 0 - Riverpod MatchesController', () {
    test('matchesControllerProvider loads matches and updates predictions',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Verify repository provider
      final repo = container.read(matchRepositoryProvider);
      expect(repo, isA<MatchRepository>());

      // Wait for controller to finish build
      final state = await container.read(matchesControllerProvider.future);
      expect(state.allMatches, isNotEmpty);
      expect(state.filters, isNotEmpty);
      expect(state.filters.first.competitionName, 'All');

      // Test selecting filter
      final notifier = container.read(matchesControllerProvider.notifier);
      if (state.filters.length > 1) {
        notifier.selectFilter(1);
        final filteredState = container.read(matchesControllerProvider).value!;
        expect(filteredState.selectedFilterIndex, 1);
        expect(
          filteredState.visibleMatches.every(
            (m) => m.competitionName == state.filters[1].competitionName,
          ),
          isTrue,
        );
      }

      // Test saving prediction
      final firstMatchId = state.allMatches.first.id;
      notifier.savePrediction(firstMatchId, 2, 1);
      final updatedState = container.read(matchesControllerProvider).value!;
      final pred = updatedState.getPrediction(firstMatchId);
      expect(pred, isNotNull);
      expect(pred!.homeScore, 2);
      expect(pred.awayScore, 1);
    });
  });
}
