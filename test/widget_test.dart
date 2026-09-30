import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/auth/presentation/onboarding_screen.dart';
import 'package:pico/features/home/presentation/home_screen.dart';
import 'package:pico/features/matches/presentation/matches_screen.dart';
import 'package:pico/features/profile/presentation/profile_screen.dart';
import 'package:pico/features/shop/presentation/shop_screen.dart';
import 'package:pico/features/tournaments/presentation/tournaments_screen.dart';
import 'package:pico/main.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _FakeAuthenticatedNotifier extends AuthNotifier {
  @override
  PicoAuthState build() {
    return const PicoAuthAuthenticated(
      user: supa.User(
        id: 'test_user_id',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      ),
      isPersonalized: true,
    );
  }
}

void main() {
  testWidgets('PicoApp unauthenticated - boots to Welcome Step and navigates to How Pico Works',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PicoApp()));
    await tester.pumpAndSettle();

    // Verify OnboardingScreen is rendered at Step 1 (Welcome Step)
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Predict Football.\nCompete with Friends.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Tap "Get Started" to advance to Step 2 (How Pico Works)
    await tester.ensureVisible(find.text('Get Started'));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('How Pico Works'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('PicoApp authenticated - boots and displays bottom nav shell',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _FakeAuthenticatedNotifier()),
        ],
        child: const PicoApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify bottom nav bar is present with its 5 tabs
    final navBar = find.byType(PicoBottomNavBar);
    expect(navBar, findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Shop')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Matches')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Home')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Tournaments')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Profile')), findsOneWidget);
  });

  testWidgets('PicoApp anti-flicker: does not render OnboardingScreen before HomeScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _FakeAuthenticatedNotifier()),
        ],
        child: const PicoApp(),
      ),
    );

    // Initial frame renders AuthGate with loader and does NOT render OnboardingScreen
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);

    await tester.pumpAndSettle();

    // Succeeded directly to home shell without ever showing OnboardingScreen
    expect(find.byType(PicoBottomNavBar), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('PicoApp tab navigation - switches branches via bottom nav bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _FakeAuthenticatedNotifier()),
        ],
        child: const PicoApp(),
      ),
    );
    await tester.pumpAndSettle();

    final navBar = find.byType(PicoBottomNavBar);

    // Tap Shop tab (far left)
    await tester.tap(find.descendant(of: navBar, matching: find.text('Shop')));
    await tester.pumpAndSettle();
    expect(find.byType(ShopScreen), findsOneWidget);

    // Tap Matches tab
    await tester.tap(find.descendant(of: navBar, matching: find.text('Matches')));
    await tester.pumpAndSettle();
    expect(find.byType(MatchesScreen), findsOneWidget);

    // Tap Tournaments tab
    await tester.tap(find.descendant(of: navBar, matching: find.text('Tournaments')));
    await tester.pumpAndSettle();
    expect(find.byType(TournamentsScreen), findsOneWidget);

    // Tap Profile tab
    await tester.tap(find.descendant(of: navBar, matching: find.text('Profile')));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    // Tap Home tab back
    await tester.tap(find.descendant(of: navBar, matching: find.text('Home')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
