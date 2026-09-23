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
import 'package:pico/shared/components/prediction_bottom_sheet.dart';
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

  void _showPredictionModal(BuildContext context, PicoMatch match) {
    showPicoPredictionBottomSheet(
      context: context,
      ref: ref,
      match: match,
      onPredictionSaved: () => widget.onPredictMatch?.call(match.id),
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
                                    'Prediction window opens 3 days before kickoff',
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
                                 onViewPredictionPressed: () {
                                   if (widget.onViewLockedMatch != null) {
                                     widget.onViewLockedMatch!(match.id);
                                   } else {
                                     context.push(
                                       '/prediction/${match.id}',
                                       extra: match,
                                     );
                                   }
                                 },
                                 onTapResult: () {
                                   if (widget.onViewResult != null) {
                                     widget.onViewResult!(match.id);
                                   } else {
                                     context.push(
                                       '/prediction/${match.id}',
                                       extra: match,
                                     );
                                   }
                                 },
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

  /// Header with page title
  Widget _buildHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Matches',
        style: PicoTypography.headlineLgMobile.copyWith(
          color: PicoColors.textWhite,
          fontWeight: FontWeight.w800,
          fontSize: 26.0,
          letterSpacing: -0.5,
        ),
      ),
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
