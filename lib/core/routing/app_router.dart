import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/auth/presentation/onboarding_screen.dart';
import 'package:pico/features/home/presentation/home_screen.dart';
import 'package:pico/features/matches/presentation/matches_screen.dart';
import 'package:pico/features/profile/presentation/personalization_screen.dart';
import 'package:pico/features/profile/presentation/profile_screen.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';
import 'package:pico/features/tournaments/domain/private_league.dart';
import 'package:pico/features/tournaments/presentation/create_private_league_screen.dart';
import 'package:pico/features/tournaments/presentation/join_private_league_screen.dart';
import 'package:pico/features/tournaments/presentation/public_tournament_screen.dart';
import 'package:pico/features/tournaments/presentation/private_tournament_screen.dart';
import 'package:pico/features/tournaments/presentation/tournaments_screen.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/predictions/presentation/prediction_screen.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';

part 'app_router.g.dart';

/// Riverpod provider for application routing with auth state guards.
@riverpod
GoRouter goRouter(Ref ref) {
  final authState = ref.watch(authProvider);
  return AppRouter.createRouter(authState);
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
    final isGoingToOnboarding = matchedLocation.startsWith('/onboarding');
    final isGoingToPersonalization = matchedLocation == '/personalization';

    // 1. Unauthenticated or error -> redirect to /onboarding
    if (authState is PicoAuthUnauthenticated || authState is PicoAuthError) {
      return isGoingToOnboarding ? null : '/onboarding';
    }

    // 2. Authenticating -> allow current transition
    if (authState is PicoAuthAuthenticating) {
      return null;
    }

    // 3. Authenticated
    if (authState is PicoAuthAuthenticated) {
      if (!authState.isPersonalized) {
        return isGoingToPersonalization ? null : '/personalization';
      }

      // If personalized, do not linger in onboarding or personalization
      if (isGoingToOnboarding || isGoingToPersonalization) {
        return '/home';
      }
    }

    return null;
  }

  /// Factory creating a configured [GoRouter] with auth guard redirects.
  static GoRouter createRouter(PicoAuthState authState) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/home',
      redirect: (context, state) =>
          resolveRedirect(authState, state.matchedLocation),
      routes: [
        GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: OnboardingScreen(),
          ),
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
              child: PrivateTournamentScreen(
                leagueId: id,
                initialLeague: league,
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
            // Branch 0: Home
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

            // Branch 1: Matches
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
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
