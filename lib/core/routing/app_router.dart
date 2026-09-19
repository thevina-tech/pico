import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/features/home/presentation/home_screen.dart';
import 'package:pico/features/matches/presentation/matches_screen.dart';
import 'package:pico/features/profile/presentation/profile_screen.dart';
import 'package:pico/features/tournaments/presentation/tournaments_screen.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';

/// Application router using [GoRouter] with [StatefulShellRoute]
/// to preserve scroll and state across the 4 core tabs: Home, Matches, Tournaments, Profile.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
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
