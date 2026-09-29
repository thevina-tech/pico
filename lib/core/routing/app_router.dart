import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_gate.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/auth/presentation/onboarding_screen.dart';
import 'package:pico/features/home/presentation/home_screen.dart';
import 'package:pico/features/matches/presentation/matches_screen.dart';
import 'package:pico/features/profile/presentation/help_support_screen.dart';
import 'package:pico/features/profile/presentation/personalization_screen.dart';
import 'package:pico/features/profile/presentation/profile_screen.dart';
import 'package:pico/shared/components/in_app_web_browser_screen.dart';
import 'package:pico/features/shop/presentation/shop_screen.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';
import 'package:pico/features/tournaments/domain/private_league.dart';
import 'package:pico/features/tournaments/presentation/create_private_league_screen.dart';
import 'package:pico/features/tournaments/presentation/join_private_league_screen.dart';
import 'package:pico/features/tournaments/presentation/public_tournament_screen.dart';
import 'package:pico/features/tournaments/presentation/private_tournament_screen.dart';
import 'package:pico/features/tournaments/presentation/league_chat_screen.dart';
import 'package:pico/features/tournaments/presentation/private_league_dashboard_screen.dart';
import 'package:pico/features/tournaments/presentation/tournaments_screen.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/predictions/presentation/prediction_screen.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';

part 'app_router.g.dart';

/// Riverpod provider for application routing with auth state guards.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final authNotifier = ValueNotifier<PicoAuthState>(ref.read(authProvider));

  ref.listen<PicoAuthState>(authProvider, (_, next) {
    authNotifier.value = next;
  });

  ref.onDispose(() {
    authNotifier.dispose();
  });

  return AppRouter.createRouter(
    ref.read(authProvider),
    refreshListenable: authNotifier,
    currentAuthState: () => authNotifier.value,
  );
}

/// Application router using [GoRouter] with [StatefulShellRoute]
/// to preserve scroll and state across the 4 core tabs: Home, Matches, Tournaments, Profile.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Fallback static router instance for testing without Riverpod scope.
  static final GoRouter router = createRouter(const PicoAuthAuthenticated(
    isPersonalized: true,
  ));

  /// Evaluates routing redirects based on [PicoAuthState] and current location.
  static String? resolveRedirect(
    PicoAuthState authState,
    String matchedLocation,
  ) {
    // 0. AuthGate at root is the primary decision-maker on app startup.
    if (matchedLocation == '/') {
      return null;
    }

    final isGoingToOnboarding = matchedLocation.startsWith('/onboarding');
    final isGoingToPersonalization = matchedLocation == '/personalization';

    // 1. Unauthenticated or error -> redirect to /onboarding
    if (authState is PicoAuthUnauthenticated || authState is PicoAuthError) {
      return isGoingToOnboarding ? null : '/onboarding';
    }

    // 2. Initializing or Authenticating -> allow current transition
    if (authState is PicoAuthInitial || authState is PicoAuthAuthenticating) {
      return null;
    }

    // 3. Authenticated
    if (authState is PicoAuthAuthenticated) {
      if (!authState.isPersonalized) {
        if (isGoingToOnboarding || isGoingToPersonalization) {
          return null;
        }
        return '/onboarding';
      }

      // If personalized, do not linger in onboarding or personalization
      if (isGoingToOnboarding || isGoingToPersonalization) {
        return '/home';
      }
    }

    return null;
  }

  /// Factory creating a configured [GoRouter] with auth guard redirects.
  static GoRouter createRouter(
    PicoAuthState authState, {
    String initialLocation = '/',
    Listenable? refreshListenable,
    PicoAuthState Function()? currentAuthState,
  }) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialLocation,
      refreshListenable: refreshListenable,
      redirect: (context, state) {
        final current = currentAuthState != null ? currentAuthState() : authState;
        return resolveRedirect(current, state.matchedLocation);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AuthGate(),
          ),
        ),
        GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) {
            final stepStr = state.uri.queryParameters['step'];
            final initialPage = int.tryParse(stepStr ?? '') ?? 1;
            return NoTransitionPage(
              child: OnboardingScreen(initialPage: initialPage),
            );
          },
          routes: [
            GoRoute(
              path: 'how-it-works',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: OnboardingScreen(initialPage: 1),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/personalization',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PersonalizationScreen(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '/prediction/:matchId',
          pageBuilder: (context, state) {
            final match = state.extra as PicoMatch?;
            if (match == null) {
              return MaterialPage(
                child: Scaffold(
                  appBar: AppBar(title: const Text('Match Prediction')),
                  body: const Center(child: Text('Match information unavailable')),
                ),
              );
            }
            return MaterialPage(
              child: PredictionScreen(
                match: match,
                onBack: () => context.pop(),
              ),
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '/tournaments/create',
          pageBuilder: (context, state) => const MaterialPage(
            child: CreatePrivateLeagueScreen(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '/tournaments/join',
          pageBuilder: (context, state) => const MaterialPage(
            child: JoinPrivateLeagueScreen(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '/tournaments/public/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            final tournament = state.extra as Tournament?;
            return MaterialPage(
              child: PublicTournamentScreen(
                tournamentId: id,
                initialTournament: tournament,
              ),
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '/tournaments/private/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            final league = state.extra as PrivateLeague?;
            return MaterialPage(
              child: PrivateLeagueDashboardScreen(
                leagueId: id,
                initialLeague: league,
                initialTabIndex: 0,
              ),
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '/tournaments/private/:id/standings',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            final league = state.extra as PrivateLeague?;
            return MaterialPage(
              child: PrivateLeagueDashboardScreen(
                leagueId: id,
                initialLeague: league,
                initialTabIndex: 2,
              ),
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '/shop',
          pageBuilder: (context, state) => const MaterialPage(
            child: ShopScreen(
              showBottomNavBar: false,
            ),
          ),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '/help-support',
          pageBuilder: (context, state) => const MaterialPage(
            child: HelpSupportScreen(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: '/in-app-browser',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, String>?;
            final title = extra?['title'] ??
                state.uri.queryParameters['title'] ??
                'Browser';
            final url = extra?['url'] ??
                state.uri.queryParameters['url'] ??
                '';
            return MaterialPage(
              child: InAppWebBrowserScreen(
                title: title,
                url: url,
              ),
            );
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return PicoGameExitScope(
              child: Scaffold(
                backgroundColor: PicoColors.pitchBackground,
                body: navigationShell,
                bottomNavigationBar: Center(
                  heightFactor: 1.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440.0),
                    child: PicoBottomNavBar(
                      currentIndex: navigationShell.currentIndex,
                      onTap: (index) {
                        navigationShell.goBranch(
                          index,
                          initialLocation: index == navigationShell.currentIndex,
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
          branches: [
            // Branch 0: Matches
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/matches',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: MatchesScreen(
                      showBottomNavBar: false,
                    ),
                  ),
                ),
              ],
            ),

            // Branch 1: Home
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: HomeScreen(
                      showBottomNavBar: false,
                    ),
                  ),
                ),
              ],
            ),

            // Branch 2: Tournaments
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/tournaments',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: TournamentsScreen(),
                  ),
                ),
              ],
            ),

            // Branch 3: Profile
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: ProfileScreen(),
                  ),
                  routes: [
                    GoRoute(
                      parentNavigatorKey: rootNavigatorKey,
                      path: 'help-support',
                      pageBuilder: (context, state) => const MaterialPage(
                        child: HelpSupportScreen(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
