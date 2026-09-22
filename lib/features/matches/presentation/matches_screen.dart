import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_controller.dart';
import 'package:pico/features/matches/presentation/matches_view_model.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/match_card.dart';
import 'package:pico/shared/components/pico_app_bar.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';
import 'package:pico/shared/components/pico_button.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
import 'package:pico/shared/components/prediction_controls.dart';
import 'package:pico/features/predictions/presentation/prediction_controller.dart';
import 'package:pico/l10n/app_localizations.dart';

/// The official "Pico — Matches" screen.
///
/// Strictly adheres to Pico guidelines:
/// - Pure dumb display layer: zero UI business logic in screen.
/// - Connects to [MatchesViewModel] using granular `ref.watch(matchesViewModelProvider.select(...))`.
/// - Uses [ListView.builder] for smooth 60fps scrolling feed.
/// - Reuses [MatchCard.fromMatch] for dynamic binding from [MockMatchRepository].
/// - Reuses [ScoreStepper] and [PicoButton] for the prediction bottom sheet.
class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({
    super.key,
    this.showBottomNavBar = true,
    this.currentNavIndex = 1,
    this.onNavTap,
    this.onPredictMatch,
    this.onModifyMatch,
    this.onViewLockedMatch,
    this.onViewResult,
  });

  final bool showBottomNavBar;
  final int currentNavIndex;
  final ValueChanged<int>? onNavTap;
  final ValueChanged<String>? onPredictMatch;
  final ValueChanged<String>? onModifyMatch;
  final ValueChanged<String>? onViewLockedMatch;
  final ValueChanged<String>? onViewResult;

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  late int _currentNavIndex;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.currentNavIndex;
  }

  @override
  void didUpdateWidget(covariant MatchesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentNavIndex != widget.currentNavIndex) {
      _currentNavIndex = widget.currentNavIndex;
    }
  }

  MatchOutcome _calculateWinner(int home, int away) {
    if (home > away) return MatchOutcome.home;
    if (away > home) return MatchOutcome.away;
    return MatchOutcome.draw;
  }

  void _showPredictionModal(BuildContext context, PicoMatch match) {
    final matchesState = ref.read(matchesControllerProvider).value;
    final currentPrediction = matchesState?.getPrediction(match.id);
    final existingPredictions = ref.read(predictionControllerProvider).value;
    final existing = existingPredictions?[match.id];

    int homeScore = currentPrediction?.homeScore ?? existing?.homeScore ?? 2;
    int awayScore = currentPrediction?.awayScore ?? existing?.awayScore ?? 1;
    MatchOutcome selectedWinner = _calculateWinner(homeScore, awayScore);
    if (existing != null) {
      final w = existing.predictedWinner.toLowerCase();
      if (w == 'home') {
        selectedWinner = MatchOutcome.home;
      } else if (w == 'away') {
        selectedWinner = MatchOutcome.away;
      } else if (w == 'draw') {
        selectedWinner = MatchOutcome.draw;
      }
    }

    void onSelectWinner(MatchOutcome outcome, void Function(void Function()) setModalState) {
      setModalState(() {
        selectedWinner = outcome;
        if (outcome == MatchOutcome.home && homeScore <= awayScore) {
          homeScore = awayScore + 1;
        } else if (outcome == MatchOutcome.away && awayScore <= homeScore) {
          awayScore = homeScore + 1;
        } else if (outcome == MatchOutcome.draw && homeScore != awayScore) {
          awayScore = homeScore;
        }
      });
    }

    void onUpdateHomeScore(int newScore, void Function(void Function()) setModalState) {
      if (newScore < 0) return;
      setModalState(() {
        homeScore = newScore;
        if (homeScore > awayScore) {
          selectedWinner = MatchOutcome.home;
        } else if (awayScore > homeScore) {
          selectedWinner = MatchOutcome.away;
        } else {
          selectedWinner = MatchOutcome.draw;
        }
      });
    }

    void onUpdateAwayScore(int newScore, void Function(void Function()) setModalState) {
      if (newScore < 0) return;
      setModalState(() {
        awayScore = newScore;
        if (homeScore > awayScore) {
          selectedWinner = MatchOutcome.home;
        } else if (awayScore > homeScore) {
          selectedWinner = MatchOutcome.away;
        } else {
          selectedWinner = MatchOutcome.draw;
        }
      });
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.90,
              ),
              padding: EdgeInsets.fromLTRB(
                20.0,
                16.0,
                20.0,
                MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
              decoration: const BoxDecoration(
                color: PicoColors.cardFace,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
                border: Border(
                  top: BorderSide(color: Color(0xFFECE7DC), width: 2.0),
                  left: BorderSide(color: Color(0xFFECE7DC), width: 1.0),
                  right: BorderSide(color: Color(0xFFECE7DC), width: 1.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFEDE8DD),
                    offset: Offset(0, -6),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0x3D0A1811),
                    offset: Offset(0, -12),
                    blurRadius: 32,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pull pill
                    Center(
                      child: Container(
                        width: 38.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD2CCC0),
                          borderRadius: BorderRadius.circular(999.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),

                    // Header: Competition & Closes At
                    Center(
                      child: Text(
                        '${match.competitionName.toUpperCase()} · LOCKS ${match.closesAtTimeFormatted.toUpperCase()}',
                        style: PicoTypography.labelPillSm.copyWith(
                          color: PicoColors.textTactileMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4.0),

                    // Match Title
                    Center(
                      child: Text(
                        '${match.homeTeamName} vs ${match.awayTeamName}',
                        style: PicoTypography.headlineMd.copyWith(
                          color: PicoColors.textPitchInk,
                          fontWeight: FontWeight.w800,
                          fontSize: 18.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 14.0),

                    const Divider(color: Color(0xFFE7E2D6), height: 1.0, thickness: 1.0),
                    const SizedBox(height: 14.0),

                    // STEP 1: Pick the Winner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20.0,
                              height: 20.0,
                              decoration: const BoxDecoration(
                                color: PicoColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Pick the Winner',
                              style: PicoTypography.titleCard.copyWith(
                                color: PicoColors.textPitchInk,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'WHO WINS?',
                          style: PicoTypography.labelPillSm.copyWith(
                            color: PicoColors.textTactileMuted,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    WinnerSelector(
                      selectedOutcome: selectedWinner,
                      homeCode: match.homeTeamCode,
                      drawCode: 'X',
                      awayCode: match.awayTeamCode,
                      isDark: false,
                      onSelected: (outcome) => onSelectWinner(outcome, setModalState),
                    ),
                    const SizedBox(height: 16.0),

                    const Divider(color: Color(0xFFE7E2D6), height: 1.0, thickness: 1.0),
                    const SizedBox(height: 14.0),

                    // STEP 2: Exact Score Prediction
                    Row(
                      children: [
                        Container(
                          width: 20.0,
                          height: 20.0,
                          decoration: const BoxDecoration(
                            color: PicoColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Exact Score Prediction',
                          style: PicoTypography.titleCard.copyWith(
                            color: PicoColors.textPitchInk,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    ScoreStepperArena(
                      homeScore: homeScore,
                      awayScore: awayScore,
                      homeTeamCode: match.homeTeamCode,
                      awayTeamCode: match.awayTeamCode,
                      onHomeScoreChanged: (val) => onUpdateHomeScore(val, setModalState),
                      onAwayScoreChanged: (val) => onUpdateAwayScore(val, setModalState),
                      isDark: false,
                    ),
                    const SizedBox(height: 16.0),

                    // Scoring Potential Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF7EE),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: PicoColors.primary, size: 18.0),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'Exact score = +5 Pico Points · Correct winner = +3 Pico Points',
                              style: PicoTypography.bodySm.copyWith(
                                color: const Color(0xFF1B5E3A),
                                fontWeight: FontWeight.w700,
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18.0),

                    // Primary CTA: Save Prediction (+10 XP)
                    PicoButton.primary(
                      text: 'Save Prediction (+10 XP)',
                      onPressed: () async {
                        final winnerString = selectedWinner == MatchOutcome.home
                            ? 'home'
                            : selectedWinner == MatchOutcome.away
                                ? 'away'
                                : 'draw';

                        Navigator.of(bottomSheetContext).pop();

                        final success = await ref
                            .read(predictionControllerProvider.notifier)
                            .submitPrediction(
                              match: match,
                              homeScore: homeScore,
                              awayScore: awayScore,
                              predictedWinner: winnerString,
                            );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Prediction locked in! (+10 XP) ⚽'),
                                backgroundColor: PicoColors.primary,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(match.isLocked
                                    ? 'Predictions are closed for this match'
                                    : 'Failed to save prediction. Please try again.'),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }

                        widget.onPredictMatch?.call(match.id);
                      },
                    ),
                    const SizedBox(height: 10.0),

                    // Secondary CTA: Detailed Prediction Screen
                    PicoButton.secondary(
                      text: 'View Full Prediction Page →',
                      onPressed: () {
                        Navigator.of(bottomSheetContext).pop();
                        context.push('/prediction/${match.id}', extra: match);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final matchesAsync = ref.watch(matchesControllerProvider);
    final predictionsAsync = ref.watch(predictionControllerProvider);

    return PicoGameExitScope(
      child: Scaffold(
        backgroundColor: PicoColors.pitchBackground,
        appBar: PicoAppBar(
          onProfileTap: () => context.go('/profile'),
        ),
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
                  },
                ),
              ),
            )
          : null,
      body: PicoPitchBackground(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Page Header (Always visible)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0),
                    child: _buildHeader(),
                  ),
                  const SizedBox(height: 12.0),

                  // 2. Categorized Tabs Bar ("Live", "Upcoming", "Finished")
                  if (matchesAsync.value != null)
                    _buildTabBar(context, matchesAsync.value!),
                  const SizedBox(height: 12.0),

                  // 3. Horizontal Filter Bar (Always visible)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildFilterBar(
                      context,
                      matchesAsync.value?.filters ?? const [],
                      matchesAsync.value?.selectedFilterIndex ?? 0,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // 4. Matches Feed (Scrollable, 60fps ListView.builder)
                  Expanded(
                    child: matchesAsync.when(
                      loading: () => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Loading matches...',
                            style: PicoTypography.bodyMd.copyWith(
                              color: PicoColors.textWhiteMuted,
                            ),
                          ),
                        ),
                      ),
                      error: (err, stack) => Center(
                        child: Text(
                          'Failed to load matches: $err',
                          style: PicoTypography.bodyMd.copyWith(
                            color: PicoColors.textWhiteMuted,
                          ),
                        ),
                      ),
                      data: (state) {
                        final matches = state.visibleMatches;
                        if (matches.isEmpty) {
                          return _buildEmptyState(context, state.selectedTab);
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            0,
                            16.0,
                            24.0,
                          ),
                          itemCount: matches.length,
                          itemBuilder: (context, index) {
                            final match = matches[index];
                            final userPred = predictionsAsync.value?[match.id];
                            final localPred = state.getPrediction(match.id);
                            final predictedHomeScore = userPred?.homeScore ?? localPred?.homeScore;
                            final predictedAwayScore = userPred?.awayScore ?? localPred?.awayScore;

                            // Personal settlement outcome calculation
                            final points = state.settlementPoints[match.id] ??
                                match.calculateSettlementPoints(predictedHomeScore, predictedAwayScore);

                            String? outcomeLabel;
                            if (match.status == MatchStatus.finished) {
                              if (userPred != null || localPred != null) {
                                if (points != null && points == 5) {
                                  outcomeLabel = l10n?.pointsOutcomeExact ?? '+5 Points';
                                } else if (points != null && points == 3) {
                                  outcomeLabel = l10n?.pointsOutcomeWinner ?? '+3 Points';
                                } else {
                                  outcomeLabel = l10n?.pointsOutcomeIncorrect ?? '0 Points';
                                }
                              } else {
                                outcomeLabel = l10n?.pointsOutcomeNone ?? 'No Prediction';
                              }
                            }

                            // Rolling teaser countdown formatting
                            String? teaserLabel;
                            if (match.isTeaser) {
                              final countdown = match.teaserCountdown;
                              if (countdown.inDays >= 1) {
                                teaserLabel = l10n?.teaserOpensInDays(countdown.inDays) ??
                                    'Opens in ${countdown.inDays}d';
                              } else if (countdown.inHours >= 1) {
                                teaserLabel = l10n?.teaserOpensInHours(countdown.inHours) ??
                                    'Opens in ${countdown.inHours}h';
                              } else {
                                teaserLabel = l10n?.teaserOpensInMinutes(countdown.inMinutes.clamp(1, 60)) ??
                                    'Opens in ${countdown.inMinutes}m';
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: MatchCard.fromMatch(
                                match: match,
                                predictedHomeScore: predictedHomeScore,
                                predictedAwayScore: predictedAwayScore,
                                awardedPoints: points,
                                settlementOutcomeLabel: outcomeLabel,
                                teaserCountdownLabel: teaserLabel,
                                teaserSubtext: l10n?.teaserCountdownSubtext ??
                                    'Prediction window opens 7 days before kickoff',
                                onCardTap: match.isTeaser
                                    ? null
                                    : () => context.push(
                                          '/prediction/${match.id}',
                                          extra: match,
                                        ),
                                onPredictPressed: match.isTeaser
                                    ? null
                                    : () => _showPredictionModal(context, match),
                                onModifyPressed: () =>
                                    _showPredictionModal(context, match),
                                onViewPredictionPressed: () => widget
                                    .onViewLockedMatch
                                    ?.call(match.id),
                                onTapResult: () =>
                                    widget.onViewResult?.call(match.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
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

  /// Header with title, round subtitle, and calendar date capsule
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Matches',
                style: PicoTypography.headlineLgMobile.copyWith(
                  color: PicoColors.textWhite,
                  fontWeight: FontWeight.w800,
                  fontSize: 26.0,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                'Round 32 Predictions · Sunday',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PicoTypography.bodySm.copyWith(
                  color: PicoColors.textWhiteMuted,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8.0),

        // Date / Calendar Pill
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
                Icons.calendar_today_rounded,
                size: 14.0,
                color: PicoColors.primaryFixed,
              ),
              const SizedBox(width: 6.0),
              Text(
                'Today, 18 May',
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

  /// Horizontal scrolling filter chips bar populated dynamically from [MatchesViewModel]
  Widget _buildFilterBar(
    BuildContext context,
    List<MatchFilterChipData> filters,
    int selectedIndex,
  ) {
    if (filters.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: 38.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final bool isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              ref
                  .read(matchesControllerProvider.notifier)
                  .selectFilter(index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? PicoColors.primary
                    : const Color(0xFF142B20),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.1),
                  width: 1.0,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0xFF004424),
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Color(0xFF0A1811),
                          offset: Offset(0, 2),
                          blurRadius: 0,
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filter.isStar) ...[
                    const Icon(
                      Icons.star_rounded,
                      size: 14.0,
                      color: PicoColors.gold,
                    ),
                    const SizedBox(width: 6.0),
                  ] else if (filter.dotColor != null) ...[
                    Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: filter.dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                  ],
                  Text(
                    filter.label,
                    style: PicoTypography.labelPillSm.copyWith(
                      color: isSelected
                          ? PicoColors.textWhite
                          : const Color(0xFFE3E3DE),
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Top categorized tab bar with "Live", "Upcoming", and "Finished" views
  Widget _buildTabBar(BuildContext context, MatchesState state) {
    final l10n = AppLocalizations.of(context);
    final activeTab = state.selectedTab;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2117),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: l10n?.feedTabLive ?? 'Live',
              count: state.liveCount,
              isSelected: activeTab == MatchTab.live,
              isLive: true,
              onTap: () => ref
                  .read(matchesControllerProvider.notifier)
                  .selectTab(MatchTab.live),
            ),
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: _buildTabButton(
              title: l10n?.feedTabUpcoming ?? 'Upcoming',
              count: state.upcomingCount,
              isSelected: activeTab == MatchTab.upcoming,
              onTap: () => ref
                  .read(matchesControllerProvider.notifier)
                  .selectTab(MatchTab.upcoming),
            ),
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: _buildTabButton(
              title: l10n?.feedTabFinished ?? 'Finished',
              count: state.finishedCount,
              isSelected: activeTab == MatchTab.finished,
              onTap: () => ref
                  .read(matchesControllerProvider.notifier)
                  .selectTab(MatchTab.finished),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    bool isLive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: isSelected ? PicoColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0xFF004424),
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLive) ...[
                Container(
                  width: 7.0,
                  height: 7.0,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5.0),
              ],
              Text(
                title,
                style: PicoTypography.labelPillSm.copyWith(
                  color: isSelected ? Colors.white : const Color(0xFFA1B3A8),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4.0),
                Text(
                  '($count)',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.85)
                        : const Color(0xFF6B8074),
                    fontWeight: FontWeight.w700,
                    fontSize: 11.0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Tailored empty states for each categorized tab view
  Widget _buildEmptyState(BuildContext context, MatchTab tab) {
    final l10n = AppLocalizations.of(context);
    final IconData icon;
    final String title;
    final String subtitle;

    switch (tab) {
      case MatchTab.live:
        icon = Icons.sensors_off_rounded;
        title = l10n?.noLiveMatches ?? 'No live matches right now';
        subtitle = l10n?.noLiveMatchesSub ?? 'Check back during matchdays for real-time fixtures.';
        break;
      case MatchTab.upcoming:
        icon = Icons.event_available_outlined;
        title = l10n?.feedNoUpcomingMatches ?? 'No upcoming matches in the next 14 days';
        subtitle = l10n?.noUpcomingMatchesSub ?? 'Upcoming fixtures will appear here once scheduled.';
        break;
      case MatchTab.finished:
        icon = Icons.history_rounded;
        title = l10n?.noFinishedMatches ?? 'No finished matches in the last 7 days';
        subtitle = l10n?.noFinishedMatchesSub ?? 'Recently concluded matches and points will be shown here.';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(
                color: const Color(0xFF142B20),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Icon(icon, color: PicoColors.primaryFixed, size: 28.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: PicoTypography.headlineMd.copyWith(
                color: PicoColors.textWhite,
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: PicoTypography.bodySm.copyWith(
                color: PicoColors.textWhiteMuted,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
