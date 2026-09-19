import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_controller.dart';
import 'package:pico/shared/components/match_card.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';
import 'package:pico/shared/components/pico_companion.dart';
import 'package:pico/shared/components/pico_header.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';

/// The official Pico Home screen based on Stitch "Direction D: Friendly Premium Football World".
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    this.heroMatch,
    this.showBottomNavBar = true,
    this.currentNavIndex = 0,
    this.onNavTap,
    this.onNavigateMatches,
    this.onNavigateTournaments,
    this.onNavigateProfile,
    this.onMakePrediction,
    this.onViewLeaderboard,
  });

  final PicoMatch? heroMatch;
  final bool showBottomNavBar;
  final int currentNavIndex;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onNavigateMatches;
  final VoidCallback? onNavigateTournaments;
  final VoidCallback? onNavigateProfile;
  final VoidCallback? onMakePrediction;
  final VoidCallback? onViewLeaderboard;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _currentNavIndex;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.currentNavIndex;
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentNavIndex != widget.currentNavIndex) {
      _currentNavIndex = widget.currentNavIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    PicoMatch? effectiveHero = widget.heroMatch;
    if (effectiveHero == null) {
      try {
        effectiveHero = ref.watch(matchesControllerProvider).value?.heroMatch;
      } catch (_) {
        // Fallback for tests when matchesControllerProvider is not present in scope
      }
    }

    return Scaffold(
      backgroundColor: PicoColors.pitchBackground,
      bottomNavigationBar: widget.showBottomNavBar
          ? Center(
              heightFactor: 1.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
          child: PicoBottomNavBar(
            currentIndex: _currentNavIndex,
            onTap: (idx) {
              setState(() => _currentNavIndex = idx);
              widget.onNavTap?.call(idx);
              switch (idx) {
                case 0:
                  break;
                case 1:
                  widget.onNavigateMatches?.call();
                  break;
                case 2:
                  widget.onNavigateTournaments?.call();
                  break;
                case 3:
                  widget.onNavigateProfile?.call();
                  break;
              }
            },
          ),
        ),
      )
    : null,
      body: PicoPitchBackground(
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440.0),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top App Bar (Alex, Lvl 7, 720/1k XP, 4 Streak)
                    PicoTopAppBar(
                      playerName: 'Alex',
                      level: 7,
                      xpProgress: 0.72,
                      streakCount: 4,
                      onProfileTap: widget.onNavigateProfile,
                    ),
                    const SizedBox(height: 16.0),

                    // 2. Mascot Greeting Row
                    _buildMascotGreetingRow(),
                    const SizedBox(height: 18.0),

                    // 3. Featured Hero Match Card (Dynamic from MockMatchRepository)
                    if (effectiveHero != null)
                      MatchCard.fromMatch(
                        match: effectiveHero,
                        onPredictPressed: () => widget.onMakePrediction?.call(),
                      )
                    else
                      MatchCard.unpredicted(
                        competition: 'MATCH OF THE DAY',
                        kickoffTime: '20:45',
                        homeTeamName: 'Man. City',
                        homeTeamCode: 'MAC',
                        awayTeamName: 'RB Leipzig',
                        awayTeamCode: 'RBL',
                        closesAtTime: '20:35',
                        onPredictPressed: () => widget.onMakePrediction?.call(),
                      ),
                    const SizedBox(height: 18.0),

                    // 4. Active Tournament Hub Card (La Liga Season Hub)
                    _buildActiveTournamentCard(),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Mascot Daily Greeting ("Big match tonight, Alex! ⚽")
  Widget _buildMascotGreetingRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Mascot badge avatar with active indicator
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: PicoColors.primary,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: PicoColors.primaryFixed, width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF134E2D),
                    offset: Offset(0, 2.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Center(child: PicoCompanion.avatar(size: 28.0)),
            ),
            Positioned(
              top: -2.0,
              right: -2.0,
              child: Container(
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(
                  color: PicoColors.electricMint,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PicoColors.pitchBackground,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8.0),

        // Speech Bubble (Content-hugging rounded bubble with tactile bevel)
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.5,
            ),
            decoration: const BoxDecoration(
              color: PicoColors.cardFace,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(18.0),
                bottomLeft: Radius.circular(18.0),
                bottomRight: Radius.circular(18.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: PicoColors.cardBevelDark,
                  offset: Offset(0, 3.0),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: Color(0x22000000),
                  offset: Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              'Big match tonight, Alex! ⚽',
              style: PicoTypography.bodyMdBold.copyWith(
                color: PicoColors.textPitchInk,
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Active Tournament Hub Card (La Liga Season Hub)
  Widget _buildActiveTournamentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: PicoColors.pitchSurfaceElevated,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: PicoColors.cardBorder.withValues(alpha: 0.15),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Emblem Icon
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: PicoColors.pitchBackground,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: PicoColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: PicoColors.gold,
                  size: 26.0,
                ),
              ),
              const SizedBox(width: 12.0),

              // Title & Rank
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE TOURNAMENT',
                      style: PicoTypography.labelPillSm.copyWith(
                        color: PicoColors.electricMint,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'La Liga Season Hub',
                      style: PicoTypography.headlineMd.copyWith(
                        color: PicoColors.textWhite,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Rank #12',
                            style: PicoTypography.labelPillSm.copyWith(
                              color: PicoColors.primaryFixed,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' · 42 Pico Points',
                            style: PicoTypography.bodySm.copyWith(
                              color: PicoColors.textWhiteMuted,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Leaderboard Action Pill
              GestureDetector(
                onTap: () {
                  widget.onViewLeaderboard?.call();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: PicoColors.cardFace,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Leaderboard',
                        style: PicoTypography.labelPillSm.copyWith(
                          color: PicoColors.textPitchInk,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2.0),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: PicoColors.textPitchInk,
                        size: 14.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Divider(color: PicoColors.cardBorder.withValues(alpha: 0.1)),
          const SizedBox(height: 6.0),

          // Ticker Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: const BoxDecoration(
                        color: PicoColors.electricMint,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        'Round 28 of 38 active',
                        style: PicoTypography.labelPillSm.copyWith(
                          color: PicoColors.textWhiteMuted,
                          fontSize: 10.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                '3 FIXTURES TODAY',
                style: PicoTypography.labelPillSm.copyWith(
                  color: PicoColors.textWhiteMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
