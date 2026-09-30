import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/core/routing/app_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_gate.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/auth/presentation/onboarding_screen.dart';
import 'package:pico/features/home/presentation/home_screen.dart';
import 'package:pico/main.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _TestAuthenticatedNotifier extends AuthNotifier {
  _TestAuthenticatedNotifier({required this.isPersonalized});
  final bool isPersonalized;

  @override
  PicoAuthState build() {
    return PicoAuthAuthenticated(
      user: const supa.User(
        id: 'test_user_gate',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      ),
      isPersonalized: isPersonalized,
    );
  }
}

class _TestUnauthenticatedNotifier extends AuthNotifier {
  @override
  PicoAuthState build() {
    return const PicoAuthUnauthenticated();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthGate - Startup Decision Maker & Anti-Flicker', () {
    test('resolveRedirect returns null for root path to allow AuthGate execution', () {
      const unauth = PicoAuthUnauthenticated();
      expect(AppRouter.resolveRedirect(unauth, '/'), isNull);

      const authPersonalized = PicoAuthAuthenticated(
        user: supa.User(
          id: 'u1',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        ),
        isPersonalized: true,
      );
      expect(AppRouter.resolveRedirect(authPersonalized, '/'), isNull);

      const authUnpersonalized = PicoAuthAuthenticated(
        user: supa.User(
          id: 'u2',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        ),
        isPersonalized: false,
      );
      expect(AppRouter.resolveRedirect(authUnpersonalized, '/'), isNull);
    });

    testWidgets('AuthGate initially renders blank pitch Scaffold with CircularProgressIndicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthGate(),
          ),
        ),
      );

      // Verify that while loading, a centered CircularProgressIndicator is rendered
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progressIndicator.color, PicoColors.primary);

      // Verify no interactive onboarding screens or home screens are displayed yet
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);

      // Complete async microtasks and post-frame callback
      await tester.pumpAndSettle();

      // Outside GoRouter, unauthenticated state falls back to OnboardingScreen
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('AuthGate standalone routes to HomeScreen when authenticated and personalized',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthenticatedNotifier(isPersonalized: true),
            ),
          ],
          child: const MaterialApp(
            home: AuthGate(),
          ),
        ),
      );

      // Verify first frame is loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      await tester.pumpAndSettle();

      // Resolved to HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('AuthGate standalone routes to OnboardingScreen when authenticated but not personalized',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthenticatedNotifier(isPersonalized: false),
            ),
          ],
          child: const MaterialApp(
            home: AuthGate(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Not personalized -> routes to OnboardingScreen
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('PicoApp with GoRouter: boots into AuthGate first before navigating to HomeScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _TestAuthenticatedNotifier(isPersonalized: true),
            ),
          ],
          child: const PicoApp(),
        ),
      );

      // Frame 1: AuthGate is mounted at '/'
      expect(find.byType(AuthGate), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Crucial anti-flicker test: OnboardingScreen MUST NOT be rendered
      expect(find.byType(OnboardingScreen), findsNothing);

      // Settle routing transitions
      await tester.pumpAndSettle();

      // Navigated to /home shell
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(PicoBottomNavBar), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('PicoApp with GoRouter: boots into AuthGate first before navigating to OnboardingScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(() => _TestUnauthenticatedNotifier()),
          ],
          child: const PicoApp(),
        ),
      );

      // Frame 1: AuthGate is mounted at '/' with loader
      expect(find.byType(AuthGate), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);

      // Settle routing transitions
      await tester.pumpAndSettle();

      // Navigated to /onboarding
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });
  });
}
