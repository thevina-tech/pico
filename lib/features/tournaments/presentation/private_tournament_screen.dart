import 'package:flutter/material.dart';
import 'package:pico/features/tournaments/domain/private_league.dart';
import 'private_league_dashboard_screen.dart';

export 'private_league_dashboard_screen.dart';

/// Deprecated: Use [PrivateLeagueDashboardScreen] instead.
/// This forwarding screen preserves backward compatibility while unifying the UI into the clan dashboard.
@Deprecated('Use PrivateLeagueDashboardScreen instead')
class PrivateTournamentScreen extends StatelessWidget {
  const PrivateTournamentScreen({
    super.key,
    required this.leagueId,
    this.initialLeague,
  });

  final String leagueId;
  final PrivateLeague? initialLeague;

  @override
  Widget build(BuildContext context) {
    return PrivateLeagueDashboardScreen(
      leagueId: leagueId,
      initialLeague: initialLeague,
      initialTabIndex: 2, // Opens Standings tab where Admin Controls and leaderboard live
    );
  }
}
