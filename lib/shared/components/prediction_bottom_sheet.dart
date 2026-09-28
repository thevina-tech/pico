import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_controller.dart';
import 'package:pico/features/predictions/presentation/prediction_controller.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/pico_button.dart';
import 'package:pico/shared/components/prediction_controls.dart';

/// Shows the standardized tactile prediction bottom sheet for [match].
///
/// Shared across MatchesScreen, PublicTournamentScreen, and PrivateTournamentScreen
/// to ensure a cohesive, unified 60fps prediction experience with zero code duplication.
Future<void> showPicoPredictionBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PicoMatch match,
  VoidCallback? onPredictionSaved,
}) {
  final l10n = AppLocalizations.of(context);
  final matchesState = ref.read(matchesControllerProvider).value;
  final currentPrediction = matchesState?.getPrediction(match.id);
  final existingPredictions = ref.read(predictionControllerProvider).value;
  final existing = existingPredictions?[match.id];

  int homeScore = currentPrediction?.homeScore ?? existing?.homeScore ?? 2;
  int awayScore = currentPrediction?.awayScore ?? existing?.awayScore ?? 1;

  MatchOutcome calculateWinner(int home, int away) {
    if (home > away) return MatchOutcome.home;
    if (away > home) return MatchOutcome.away;
    return MatchOutcome.draw;
  }

  MatchOutcome selectedWinner = calculateWinner(homeScore, awayScore);
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

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (bottomSheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final locksText = l10n?.matchLocksAt(match.closesAtTimeFormatted) ??
              'LOCKS ${match.closesAtTimeFormatted.toUpperCase()}';

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
              border: Border.fromBorderSide(
                BorderSide(color: Color(0xFFECE7DC), width: 1.5),
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
                      '${match.competitionName.toUpperCase()} · $locksText',
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
                            l10n?.pickTheWinner ?? 'Pick the Winner',
                            style: PicoTypography.titleCard.copyWith(
                              color: PicoColors.textPitchInk,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        (l10n?.whoWins ?? 'WHO WINS?').toUpperCase(),
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
                        l10n?.exactScoreTitle ?? 'Exact Score Prediction',
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
                            l10n?.scoringRuleBanner ??
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
                    text: l10n?.savePredictionCta ?? 'Save Prediction (+10 XP)',
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
                            SnackBar(
                              content: Text(
                                l10n?.predictionLockedSuccessToast ??
                                    'Prediction locked in! (+10 XP) ⚽',
                              ),
                              backgroundColor: PicoColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          onPredictionSaved?.call();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                match.isLocked
                                    ? (l10n?.predictionWindowClosed ??
                                        'Predictions are closed for this match')
                                    : (l10n?.predictionSaveFailed ??
                                        'Failed to save prediction. Please try again.'),
                              ),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 10.0),

                  // Secondary CTA: Detailed Prediction Screen
                  PicoButton.secondary(
                    text: l10n?.viewFullPredictionPage ?? 'View Full Prediction Page →',
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
