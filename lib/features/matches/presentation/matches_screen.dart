import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_controller.dart';
import 'package:pico/features/matches/presentation/matches_view_model.dart';
import 'package:pico/shared/components/match_card.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';
import 'package:pico/shared/components/pico_button.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
import 'package:pico/shared/components/prediction_controls.dart';

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
    final matchesState = ref.read(matchesControllerProvider).value;
    final currentPrediction = matchesState?.getPrediction(match.id);
    int homeScore = currentPrediction?.homeScore ?? 0;
    int awayScore = currentPrediction?.awayScore ?? 0;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20.0,
                16.0,
                20.0,
                MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
              decoration: const BoxDecoration(
                color: PicoColors.pitchSurfaceElevated,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
                border: Border(
                  top: BorderSide(color: Color(0x33FFFFFF), width: 1.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pull pill
                  Container(
                    width: 36.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  Text(
                    'Exact Score Prediction',
                    style: PicoTypography.headlineMd.copyWith(
                      color: PicoColors.textWhite,
                      fontWeight: FontWeight.w800,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Predict both scores to win up to 5 Pico Points',
                    style: PicoTypography.bodySm.copyWith(
                      color: PicoColors.textWhiteMuted,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Score Steppers Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Home Team Stepper
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              match.homeTeamName,
                              style: PicoTypography.titleCard.copyWith(
                                color: PicoColors.textWhite,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.0,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12.0),
                            ScoreStepper(
                              score: homeScore,
                              onChanged: (val) {
                                setModalState(() => homeScore = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          ':',
                          style: PicoTypography.headlineLgMobile.copyWith(
                            color: PicoColors.textWhiteMuted,
                            fontWeight: FontWeight.w800,
                            fontSize: 24.0,
                          ),
                        ),
                      ),
                      // Away Team Stepper
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              match.awayTeamName,
                              style: PicoTypography.titleCard.copyWith(
                                color: PicoColors.textWhite,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.0,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12.0),
                            ScoreStepper(
                              score: awayScore,
                              onChanged: (val) {
                                setModalState(() => awayScore = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28.0),

                  // Confirm CTA
                  PicoButton.primary(
                    text: 'Save Prediction (+10 XP)',
                    onPressed: () {
                      ref
                          .read(matchesControllerProvider.notifier)
                          .savePrediction(match.id, homeScore, awayScore);
                      Navigator.of(bottomSheetContext).pop();
                      widget.onPredictMatch?.call(match.id);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(matchesControllerProvider);

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Page Header (Always visible)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                    child: _buildHeader(),
                  ),
                  const SizedBox(height: 14.0),

                  // 2. Horizontal Filter Bar (Always visible)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildFilterBar(
                      context,
                      matchesAsync.value?.filters ?? const [],
                      matchesAsync.value?.selectedFilterIndex ?? 0,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // 3. Matches Feed (Scrollable, 60fps ListView.builder)
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
                          return Center(
                            child: Text(
                              'No matches found',
                              style: PicoTypography.bodyMd.copyWith(
                                color: PicoColors.textWhiteMuted,
                              ),
                            ),
                          );
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
                            final prediction =
                                state.getPrediction(match.id);

                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 16.0),
                              child: MatchCard.fromMatch(
                                match: match,
                                predictedHomeScore:
                                    prediction?.homeScore,
                                predictedAwayScore:
                                    prediction?.awayScore,
                                onPredictPressed: () =>
                                    _showPredictionModal(context, match),
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
      height: 38.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
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
}
