import 'package:flutter/material.dart';
import 'package:pico/features/tournaments/domain/private_league.dart';

import 'private_league_dashboard_screen.dart';

export 'private_league_dashboard_screen.dart';

/// Deprecated: Use [PrivateLeagueDashboardScreen] instead.
/// Legacy alias for [PrivateLeagueDashboardScreen] preserving backward compatibility.
@Deprecated('Use PrivateLeagueDashboardScreen instead')
class LeagueChatScreen extends StatelessWidget {
  const LeagueChatScreen({
    super.key,
    required this.leagueId,
    this.initialLeague,
    this.initialTabIndex = 0,
  });

  final String leagueId;
  final PrivateLeague? initialLeague;
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return PrivateLeagueDashboardScreen(
      leagueId: leagueId,
      initialLeague: initialLeague,
      initialTabIndex: initialTabIndex,
    );
  }
}
