import 'package:flutter/material.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/pico_app_bar.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
import 'package:pico/shared/components/tournament_card.dart';

/// The official Tournaments screen displaying public and private tournaments.
class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({
    super.key,
    this.onViewLeaderboard,
  });

  final ValueChanged<String>? onViewLeaderboard;

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PicoGameExitScope(
      child: Scaffold(
        backgroundColor: PicoColors.pitchBackground,
        appBar: const PicoAppBar(),
      body: PicoPitchBackground(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440.0),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 24.0),
                children: [
                  // Page Header
                  _buildHeader(),
                  const SizedBox(height: 16.0),

                  // Segmented Tabs (General / Private)
                  TournamentTabs(
                    selectedIndex: _selectedTabIndex,
                    onChanged: (idx) => setState(() => _selectedTabIndex = idx),
                    privateCount: 2,
                  ),
                  const SizedBox(height: 18.0),

                  // Featured Hero Tournament
                  TournamentCard(
                    title: 'Champions League Masters',
                    category: 'OFFICIAL TOURNAMENT',
                    subtitle: 'Weekly Sprint · 6 matches remaining',
                    currentRank: 42,
                    standingNote: 'Only 3 pts behind #1',
                    pointsLabel: '720 Pts',
                    onViewStandings: () =>
                        widget.onViewLeaderboard?.call('Champions League Masters'),
                  ),
                  const SizedBox(height: 16.0),

                  // Secondary Tournament Directory
                  TournamentDirectoryCard(
                    title: 'Active Public Leagues',
                    items: [
                      TournamentDirectoryItem(
                        title: 'Premier League Matchday 28',
                        subtitle: '8,190 players · Rank #128',
                        icon: Icons.sports_soccer_rounded,
                        onTap: () =>
                            widget.onViewLeaderboard?.call('Premier League Matchday 28'),
                      ),
                      TournamentDirectoryItem(
                        title: 'La Liga Weekend Clash',
                        subtitle: '5,420 players · Rank #54',
                        icon: Icons.emoji_events_rounded,
                        onTap: () =>
                            widget.onViewLeaderboard?.call('La Liga Weekend Clash'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tournaments',
                style: PicoTypography.headlineLgMobile.copyWith(
                  color: PicoColors.textWhite,
                  fontWeight: FontWeight.w800,
                  fontSize: 26.0,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                'Compete with friends · No real money',
                style: PicoTypography.bodySm.copyWith(
                  color: PicoColors.textWhiteMuted,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: const Color(0xFF152B21),
            borderRadius: BorderRadius.circular(999.0),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 14.0,
                color: PicoColors.gold,
              ),
              const SizedBox(width: 6.0),
              Text(
                'Active Hub',
                style: PicoTypography.labelPillSm.copyWith(
                  color: PicoColors.textWhite,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
