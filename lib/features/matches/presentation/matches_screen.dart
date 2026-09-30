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
import 'package:pico/widgets/ads/native_ad_card_widget.dart';

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
      child: PicoPitchBackground(
        imageAsset: 'assets/images/main_background.png',
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PicoAppBar(
            title: l10n?.navMatches ?? 'Matches',
            isTransparent: true,
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
                        switch (idx) {
                          case 0:
                            context.go('/shop');
                            break;
                          case 1:
                            // Already in Matches
                            break;
                          case 2:
                            context.go('/home');
                            break;
                          case 3:
                            context.go('/tournaments');
                            break;
                          case 4:
                            context.go('/profile');
                            break;
                        }
                      },
                    ),
                  ),
                )
              : null,
          body: SafeArea(
            top: false,
            bottom: false,
            child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8.0),
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

                        // Dynamically calculate total items injecting NativeAdCardWidget every 6th item
                        final adCount = matches.length ~/ 5;
                        final totalCount = matches.length + adCount;

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            0,
                            16.0,
                            24.0,
                          ),
                          itemCount: totalCount,
                          itemBuilder: (context, index) {
                            // Inject Native Ad Card at every 6th index (index 5, 11, 17, ...)
                            if ((index + 1) % 6 == 0) {
                              return const NativeAdCardWidget(
                                placement: 'match_feed',
                              );
                            }

                            final matchIndex = index - ((index + 1) ~/ 6);
                            final match = matches[matchIndex];
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
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A24),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildClashTabButton(
            title: l10n?.feedTabLive ?? 'Live',
            count: state.liveCount,
            icon: Icons.sensors_rounded,
            isSelected: activeTab == MatchTab.live,
            isLive: true,
            onTap: () => ref
                .read(matchesControllerProvider.notifier)
                .selectTab(MatchTab.live),
          ),
          const SizedBox(width: 8.0),
          _buildClashTabButton(
            title: l10n?.feedTabUpcoming ?? 'Upcoming',
            count: state.upcomingCount,
            icon: Icons.schedule_rounded,
            isSelected: activeTab == MatchTab.upcoming,
            onTap: () => ref
                .read(matchesControllerProvider.notifier)
                .selectTab(MatchTab.upcoming),
          ),
          const SizedBox(width: 8.0),
          _buildClashTabButton(
            title: l10n?.feedTabFinished ?? 'Finished',
            count: state.finishedCount,
            icon: Icons.task_alt_rounded,
            isSelected: activeTab == MatchTab.finished,
            onTap: () => ref
                .read(matchesControllerProvider.notifier)
                .selectTab(MatchTab.finished),
          ),
        ],
      ),
    );
  }

  Widget _buildClashTabButton({
    required String title,
    required int count,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool isLive = false,
  }) {
    const activeColor = Color(0xFFF7F4EC);
    const activeBorderBottom = Color(0xFFD8D1C3);
    const activeBorder = Color(0xFFECE7DC);
    const activeIconColor = Color(0xFF006A3A);
    const activeTextColor = Color(0xFF13211B);

    const inactiveColor = Color(0xFF162534);
    const inactiveBorderBottom = Color(0xFF090F16);
    const inactiveIconColor = Color(0xD9FAF9F4);
    const inactiveTextColor = Color(0xD9FAF9F4);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(top: isSelected ? 2.0 : 0.0),
          decoration: BoxDecoration(
            color: isSelected ? activeBorderBottom : inactiveBorderBottom,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 6.0,
                      offset: Offset(0, 2),
                    ),
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 1.0,
                      offset: Offset(0, 1),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          padding: EdgeInsets.only(bottom: isSelected ? 2.0 : 4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
            decoration: BoxDecoration(
              color: isSelected ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isSelected ? activeBorder : Colors.white.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 24.0,
                      color: isLive && count > 0
                          ? const Color(0xFFEF4444)
                          : (isSelected ? activeIconColor : inactiveIconColor),
                    ),
                    if (isLive && count > 0)
                      Positioned(
                        top: -2.0,
                        right: -4.0,
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? activeColor : inactiveColor,
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x99EF4444),
                                blurRadius: 4.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: PicoTypography.labelPillSm.copyWith(
                          color: isSelected ? activeTextColor : inactiveTextColor,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          fontSize: 12.0,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 3.0),
                      Text(
                        '($count)',
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF006A3A)
                              : const Color(0xFF6B8074),
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
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
