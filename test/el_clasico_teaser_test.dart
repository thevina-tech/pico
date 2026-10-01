import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/home/presentation/home_screen.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/game_button.dart';

class _FakeProfileNotifier extends CurrentUserProfile {
  @override
  UserProfile build() {
    return const UserProfile(
      id: 'user_1',
      username: 'FootballFan',
      level: 5,
      xp: 200,
      streak: 3,
      coins: 500,
      totalPoints: 50,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildHomeScreen({Locale locale = const Locale('en')}) {
    return ProviderScope(
      overrides: [
        currentUserProfileProvider.overrideWith(() => _FakeProfileNotifier()),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(showBottomNavBar: false),
      ),
    );
  }

  group('Home Screen - El Clásico Static Teaser Card', () {
    testWidgets(
        'renders elclasico.png background, centered header, solid circle team icons, and disabled button',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildHomeScreen());
      await tester.pumpAndSettle();

      // 1. Verify Top Half background asset uses elclasico.png with BoxFit.cover
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsWidgets);
      final elClasicoImage = tester.widgetList<Image>(imageFinder).firstWhere(
            (img) =>
                img.image is AssetImage &&
                (img.image as AssetImage).assetName ==
                    'assets/images/elclasico.png',
          );
      expect(elClasicoImage.fit, BoxFit.cover);

      // 2. Verify NO "Premier League" or league badge
      expect(find.text('Premier League'), findsNothing);
      expect(find.text('PREMIER LEAGUE'), findsNothing);
      expect(find.text('LALIGA'), findsNothing);

      // 3. Verify centered "El Clásico" and match date
      expect(find.text('El Clásico'), findsOneWidget);
      expect(find.text('📅 Sat, 26 Oct • 21:00'), findsOneWidget);

      // 4. Verify hardcoded team names: Barcelona (Home) & Real Madrid (Away)
      expect(find.text('Barcelona'), findsOneWidget);
      expect(find.text('Real Madrid'), findsOneWidget);
      expect(find.text('VS'), findsOneWidget);

      // 5. Verify team logos are solid colored circular containers (no image widgets for logos)
      final containers = tester.widgetList<Container>(find.byType(Container));

      // Barcelona solid blue circle (#004D98)
      final barcelonaCircle = containers.any((c) {
        final deco = c.decoration;
        if (deco is BoxDecoration) {
          return deco.shape == BoxShape.circle &&
              deco.color == const Color(0xFF004D98);
        }
        return false;
      });
      expect(barcelonaCircle, isTrue);

      // Real Madrid solid white circle (Colors.white)
      final realMadridCircle = containers.any((c) {
        final deco = c.decoration;
        if (deco is BoxDecoration) {
          return deco.shape == BoxShape.circle && deco.color == Colors.white;
        }
        return false;
      });
      expect(realMadridCircle, isTrue);

      // 6. Verify Action button: disabled with localized "Coming Soon!" text
      final actionButtonFinder =
          find.byKey(const Key('special_event_action_button'));
      expect(actionButtonFinder, findsOneWidget);

      final gameButton = tester.widget<GameButton>(actionButtonFinder);
      expect(gameButton.text, 'Coming Soon!');
      expect(gameButton.onPressed, isNull);
    });

    testWidgets('renders Spanish localized "¡Próximamente!" on action button',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildHomeScreen(locale: const Locale('es')));
      await tester.pumpAndSettle();

      final actionButtonFinder =
          find.byKey(const Key('special_event_action_button'));
      expect(actionButtonFinder, findsOneWidget);

      final gameButton = tester.widget<GameButton>(actionButtonFinder);
      expect(gameButton.text, '¡Próximamente!');
      expect(gameButton.onPressed, isNull);
    });
  });
}
