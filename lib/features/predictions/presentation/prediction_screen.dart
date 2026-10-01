import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/predictions/presentation/prediction_controller.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/game_button.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
import 'package:pico/shared/components/pico_snackbar.dart';
import 'package:pico/shared/components/prediction_controls.dart';

/// Screen: Tactile Match Prediction Board
///
/// Features:
/// 1. Dynamic [PicoMatch] binding with live kickoff and closing times.
/// 2. Pick the Winner selector and vertical Exact Score steppers.
/// 3. Zero-client trust enforcement (locks 10 minutes before kickoff).
/// 4. Direct Riverpod integration saving prediction + awarding +10 XP ledger.
class PredictionScreen extends ConsumerStatefulWidget {
  const PredictionScreen({
    super.key,
    required this.match,
    this.initialHomeScore,
    this.initialAwayScore,
    this.onBack,
    this.onPredictionLocked,
  });

  final PicoMatch match;
  final int? initialHomeScore;
  final int? initialAwayScore;
  final VoidCallback? onBack;
  final void Function(int homeScore, int awayScore, MatchOutcome winner)?
      onPredictionLocked;

  @override
  ConsumerState<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends ConsumerState<PredictionScreen> {
  late int _homeScore;
  late int _awayScore;
  late MatchOutcome _selectedWinner;
  bool _isLocked = false;
  bool _isSubmitting = false;
  bool _hasUserModified = false;

  @override
  void initState() {
    super.initState();
    final bool isFinished = widget.match.status == MatchStatus.finished;
    final bool isLive = widget.match.status == MatchStatus.live;
    final bool isTeaser = widget.match.isTeaser;
    _isLocked = widget.match.isLocked || isFinished || isLive || isTeaser;

    final predictions = ref.read(predictionControllerProvider);
    final existing = predictions.value?[widget.match.id];

    if (isFinished) {
      _homeScore = widget.match.homeScore ?? 0;
      _awayScore = widget.match.awayScore ?? 0;
      _selectedWinner = _parseWinner(widget.match.actualWinner ?? 'draw');
    } else if (isLive) {
      if (existing != null) {
        _homeScore = existing.homeScore;
        _awayScore = existing.awayScore;
        _selectedWinner = _parseWinner(existing.predictedWinner);
      } else {
        _homeScore = widget.match.homeScore ?? 0;
        _awayScore = widget.match.awayScore ?? 0;
        _selectedWinner = _parseWinner(widget.match.actualWinner ?? 'draw');
      }
    } else if (existing != null) {
      _homeScore = existing.homeScore;
      _awayScore = existing.awayScore;
      _selectedWinner = _parseWinner(existing.predictedWinner);
    } else {
      _homeScore = widget.initialHomeScore ?? 2;
      _awayScore = widget.initialAwayScore ?? 1;
      _autoSyncWinnerFromScore();
    }
  }

  MatchOutcome _parseWinner(String winner) {
    switch (winner.toLowerCase()) {
      case 'home':
        return MatchOutcome.home;
      case 'away':
        return MatchOutcome.away;
      case 'draw':
      default:
        return MatchOutcome.draw;
    }
  }

  void _updateHomeScore(int newScore) {
    if (_isLocked || newScore < 0) return;
    setState(() {
      _hasUserModified = true;
      _homeScore = newScore;
      _autoSyncWinnerFromScore();
    });
  }

  void _updateAwayScore(int newScore) {
    if (_isLocked || newScore < 0) return;
    setState(() {
      _hasUserModified = true;
      _awayScore = newScore;
      _autoSyncWinnerFromScore();
    });
  }

  void _selectWinner(MatchOutcome outcome) {
    if (_isLocked) return;
    setState(() {
      _hasUserModified = true;
      _selectedWinner = outcome;
      if (outcome == MatchOutcome.home && _homeScore <= _awayScore) {
        _homeScore = _awayScore + 1;
      } else if (outcome == MatchOutcome.away && _awayScore <= _homeScore) {
        _awayScore = _homeScore + 1;
      } else if (outcome == MatchOutcome.draw && _homeScore != _awayScore) {
        _awayScore = _homeScore;
      }
    });
  }

  void _autoSyncWinnerFromScore() {
    if (_homeScore > _awayScore) {
      _selectedWinner = MatchOutcome.home;
    } else if (_awayScore > _homeScore) {
      _selectedWinner = MatchOutcome.away;
    } else {
      _selectedWinner = MatchOutcome.draw;
    }
  }

  String _cleanImageUrl(String url) {
    if (url.contains('?')) {
      return url.split('?').first;
    }
    return url;
  }

  Future<void> _submitPrediction() async {
    if (_isLocked || _isSubmitting) return;

    if (widget.match.isLocked) {
      setState(() => _isLocked = true);
      final l10n = AppLocalizations.of(context);
      PicoSnackBar.showError(
        context,
        l10n?.predictionWindowClosed ??
            'Predictions lock exactly 10 minutes before kickoff.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final winnerString = _selectedWinner == MatchOutcome.home
          ? 'home'
          : _selectedWinner == MatchOutcome.away
              ? 'away'
              : 'draw';

      final success = await ref
          .read(predictionControllerProvider.notifier)
          .submitPrediction(
            match: widget.match,
            homeScore: _homeScore,
            awayScore: _awayScore,
            predictedWinner: winnerString,
          );

      if (!mounted) return;

      if (success) {
        widget.onPredictionLocked?.call(_homeScore, _awayScore, _selectedWinner);
        final l10n = AppLocalizations.of(context);
        PicoSnackBar.showSuccess(
          context,
          l10n?.predictionLockedTitle ?? 'Prediction Locked! ⚽',
          subtitle:
              '${widget.match.homeTeamName} $_homeScore - $_awayScore ${widget.match.awayTeamName}',
        );
      } else {
        if (widget.match.isLocked) {
          setState(() => _isLocked = true);
        }
        final l10n = AppLocalizations.of(context);
        PicoSnackBar.showError(
          context,
          widget.match.isLocked
              ? (l10n?.predictionWindowClosed ??
                  'Predictions are closed for this match')
              : (l10n?.predictionSaveFailed ??
                  'Failed to save prediction. Please try again.'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(predictionControllerProvider, (prev, next) {
      final existing = next.value?[widget.match.id];
      if (existing != null && !_hasUserModified && mounted && widget.match.status != MatchStatus.finished) {
        setState(() {
          _homeScore = existing.homeScore;
          _awayScore = existing.awayScore;
          _selectedWinner = _parseWinner(existing.predictedWinner);
        });
      }
    });

    return PicoPitchBackground(
      showContours: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header Bar: Back Button, Match Info, Streak
                    _buildHeaderBar(),
                    const SizedBox(height: 14.0),

                    // 2. Teams Faceoff Presentation
                    _buildTeamsFaceoff(),
                    const SizedBox(height: 16.0),

                    // 3. Main Interactive Tactile Prediction Board
                    _buildPredictionBoard(),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Top navigation & match status header
  Widget _buildHeaderBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back Button
        GestureDetector(
          onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: const Color(0xFF122B1F),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0x9923533C), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF0A1811),
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFFF2F1EC),
              size: 20.0,
            ),
          ),
        ),

        const SizedBox(width: 8.0),

        // Centered Match Context Info
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.match.competitionName.toUpperCase(),
                textAlign: TextAlign.center,
                style: PicoTypography.labelPillSm.copyWith(
                  color: PicoColors.primaryFixedDim,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6.0,
                    height: 6.0,
                    decoration: BoxDecoration(
                      color: widget.match.status == MatchStatus.finished
                          ? const Color(0xFFE6C687)
                          : widget.match.status == MatchStatus.live
                              ? const Color(0xFFFF4B4B)
                              : widget.match.isTeaser
                                  ? const Color(0xFFF59E0B)
                                  : (_isLocked ? PicoColors.textTactileMuted : const Color(0xFF00E297)),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Flexible(
                    child: Text(
                      widget.match.status == MatchStatus.finished
                          ? 'FINAL · ${widget.match.homeTeamName} ${widget.match.homeScore ?? 0} - ${widget.match.awayScore ?? 0} ${widget.match.awayTeamName}'
                          : widget.match.status == MatchStatus.live
                              ? 'LIVE · ${widget.match.homeScore ?? 0} - ${widget.match.awayScore ?? 0}'
                              : widget.match.isTeaser
                                  ? 'TEASER · Opens in ${widget.match.teaserCountdownShort}'
                                  : (_isLocked
                                      ? 'LOCKED · Kickoff in 10 mins'
                                      : 'Kickoff ${widget.match.kickoffTimeFormatted} · Locks ${widget.match.closesAtTimeFormatted}'),
                      textAlign: TextAlign.center,
                      style: PicoTypography.bodySm.copyWith(
                        color: const Color(0xFFF5F4EF),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 8.0),

        // Symmetrical spacer to center the league info against the 40px back button
        const SizedBox(width: 40.0),
      ],
    );
  }

  /// Visual presentation of the two clubs facing off
  Widget _buildTeamsFaceoff() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Home Team Column
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTeamBadge(
                  widget.match.homeTeamName,
                  widget.match.homeTeamBadgeUrl,
                  widget.match.homeTeamCode,
                ),
                const SizedBox(height: 6.0),
                SizedBox(
                  height: 38.0,
                  child: Center(
                    child: Text(
                      widget.match.homeTeamName,
                      textAlign: TextAlign.center,
                      style: PicoTypography.titleCard.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF102A1E),
                    borderRadius: BorderRadius.circular(999.0),
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.homeOutcome ?? 'Home',
                    style: PicoTypography.labelPillSm.copyWith(
                      color: PicoColors.primaryFixedDim,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // VS Circular Center Pill (aligned vertically with the 56px badges)
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 6.0, right: 6.0),
            child: Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: const Color(0xFF1B432F),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2F7552), width: 1.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'VS',
                  style: PicoTypography.labelPillSm.copyWith(
                    color: const Color(0xFFF5F4EF),
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          ),

          // Away Team Column
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTeamBadge(
                  widget.match.awayTeamName,
                  widget.match.awayTeamBadgeUrl,
                  widget.match.awayTeamCode,
                ),
                const SizedBox(height: 6.0),
                SizedBox(
                  height: 38.0,
                  child: Center(
                    child: Text(
                      widget.match.awayTeamName,
                      textAlign: TextAlign.center,
                      style: PicoTypography.titleCard.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF261A00),
                    borderRadius: BorderRadius.circular(999.0),
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.awayOutcome ?? 'Away',
                    style: PicoTypography.labelPillSm.copyWith(
                      color: PicoColors.gold,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamBadge(String name, String? badgeUrl, String code) {
    final cleanUrl = badgeUrl != null && badgeUrl.isNotEmpty ? _cleanImageUrl(badgeUrl) : null;
    return Container(
      width: 56.0,
      height: 56.0,
      decoration: BoxDecoration(
        color: const Color(0xFF193D2B),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF337754), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: cleanUrl != null
          ? CachedNetworkImage(
              imageUrl: cleanUrl,
              fit: BoxFit.cover,
              width: 56.0,
              height: 56.0,
              placeholder: (context, url) => Center(
                child: Text(
                  code,
                  style: PicoTypography.headlineMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.0,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Center(
                child: Text(
                  code,
                  style: PicoTypography.headlineMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.0,
                  ),
                ),
              ),
            )
          : Center(
              child: code.isNotEmpty
                  ? Text(
                      code,
                      style: PicoTypography.headlineMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16.0,
                      ),
                    )
                  : const Icon(
                      Icons.shield_rounded,
                      color: Colors.white70,
                      size: 28.0,
                    ),
            ),
    );
  }

  /// The tactile physical prediction card containing Step 1, Step 2, and Lock CTA
  Widget _buildPredictionBoard() {
    final bool isFinished = widget.match.status == MatchStatus.finished;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: PicoColors.cardFace,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: const Color(0xFFECE7DC), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFEDE8DD),
            offset: Offset(0, 8),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Color(0x3D0A1811),
            offset: Offset(0, 16),
            blurRadius: 32,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isFinished) _buildMatchResultBanner(),

          // STEP 1: Pick the Winner
          _buildStep1Winner(),
          const SizedBox(height: 18.0),

          // Divider
          const Divider(color: Color(0xFFE7E2D6), height: 1.0, thickness: 1.0),
          const SizedBox(height: 18.0),

          // STEP 2: Predict Exact Score (Vertical Stepper Arena)
          _buildStep2ScoreStepper(),
          const SizedBox(height: 18.0),

          // Scoring Potential Banner
          _buildScoringPotentialBanner(),
          const SizedBox(height: 18.0),

          // Primary CTA: Lock Prediction Button
          _buildLockPredictionButton(),
        ],
      ),
    );
  }

  /// Result banner displayed when viewing a finished match
  Widget _buildMatchResultBanner() {
    final predictions = ref.watch(predictionControllerProvider);
    final existing = predictions.value?[widget.match.id];
    final bool hasPrediction = existing != null;
    final int? points = hasPrediction
        ? widget.match.calculateSettlementPoints(existing.homeScore, existing.awayScore)
        : null;

    final l10n = AppLocalizations.of(context);
    final String outcomeTitle;
    final String pointsBadge;
    final Color badgeBg;
    final Color badgeTextColor;

    if (hasPrediction) {
      if (points == 5) {
        outcomeTitle = '${l10n?.scoringRuleExactTitle ?? 'Exact Score'}! 🎯';
        pointsBadge = l10n?.pointsOutcomeExact ?? '+5 PTS';
        badgeBg = PicoColors.primary;
        badgeTextColor = Colors.white;
      } else if (points == 3) {
        outcomeTitle = '${l10n?.scoringRuleGoalDiffTitle ?? 'Winner + Diff'}! ⚽';
        pointsBadge = l10n?.pointsOutcomeGoalDiff ?? '+3 PTS';
        badgeBg = const Color(0xFFE6C687);
        badgeTextColor = const Color(0xFF2C1C02);
      } else if (points == 1) {
        outcomeTitle = '${l10n?.scoringRuleWinnerOnlyTitle ?? 'Correct Winner'}! ⚽';
        pointsBadge = l10n?.pointsOutcomeOne ?? '+1 PT';
        badgeBg = const Color(0xFFBAE6FD);
        badgeTextColor = const Color(0xFF0369A1);
      } else {
        outcomeTitle = 'Prediction Settled';
        pointsBadge = l10n?.pointsOutcomeIncorrect ?? '0 PTS';
        badgeBg = const Color(0xFFEDE8DD);
        badgeTextColor = PicoColors.textTactileMuted;
      }
    } else {
      outcomeTitle = l10n?.matchFinishedLabel ?? 'Match Finished';
      pointsBadge = l10n?.pointsOutcomeNone ?? 'Not Predicted';
      badgeBg = const Color(0xFFEDE8DD);
      badgeTextColor = PicoColors.textTactileMuted;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0C2417),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: PicoColors.primary.withValues(alpha: 0.3), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            decoration: BoxDecoration(
              color: hasPrediction && (points ?? 0) > 0
                  ? const Color(0xFF194D31)
                  : const Color(0xFF142C20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasPrediction && (points ?? 0) > 0
                  ? Icons.emoji_events_rounded
                  : Icons.sports_soccer_rounded,
              color: hasPrediction && (points ?? 0) > 0
                  ? const Color(0xFFE6C687)
                  : const Color(0xFF98E3B6),
              size: 20.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  outcomeTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  hasPrediction
                      ? 'Your prediction: ${widget.match.homeTeamCode} ${existing.homeScore} - ${existing.awayScore} ${widget.match.awayTeamCode}'
                      : 'You did not predict this match · 0 Points awarded',
                  style: const TextStyle(
                    color: Color(0xFF98E3B6),
                    fontWeight: FontWeight.w500,
                    fontSize: 11.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              pointsBadge,
              style: TextStyle(
                color: badgeTextColor,
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 1: Winner Picker with 3 tactile tiles
  Widget _buildStep1Winner() {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
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
                  Flexible(
                    child: Text(
                      widget.match.status == MatchStatus.finished
                          ? 'Winning Team'
                          : (l10n?.pickWinner ?? 'Pick the Winner'),
                      style: PicoTypography.titleCard.copyWith(
                        color: PicoColors.textPitchInk,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              widget.match.status == MatchStatus.finished
                  ? 'FINAL RESULT'
                  : (l10n?.whoWins.toUpperCase() ?? 'WHO WINS?'),
              style: PicoTypography.labelPillSm.copyWith(
                color: PicoColors.textTactileMuted,
                fontSize: 10.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // 3 Tactile Choice Tiles
        Row(
          children: [
            Expanded(
              child: _buildChoiceTile(
                title: widget.match.homeTeamCode,
                sublabel: l10n?.homeOutcome ?? 'Home',
                isSelected: _selectedWinner == MatchOutcome.home,
                enabled: !_isLocked,
                onTap: () => _selectWinner(MatchOutcome.home),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: _buildChoiceTile(
                title: l10n?.drawOutcome ?? 'Draw',
                sublabel: 'TIE',
                isSelected: _selectedWinner == MatchOutcome.draw,
                enabled: !_isLocked,
                onTap: () => _selectWinner(MatchOutcome.draw),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: _buildChoiceTile(
                title: widget.match.awayTeamCode,
                sublabel: l10n?.awayOutcome ?? 'Away',
                isSelected: _selectedWinner == MatchOutcome.away,
                enabled: !_isLocked,
                onTap: () => _selectWinner(MatchOutcome.away),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceTile({
    required String title,
    required String sublabel,
    required bool isSelected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.6,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFF5F4EF),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: isSelected ? PicoColors.primary : const Color(0xFFD9D4C7),
                  width: isSelected ? 2.0 : 1.0,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0xFF1B5E3A),
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                        BoxShadow(
                          color: Color(0x26006A3A),
                          offset: Offset(0, 6),
                          blurRadius: 12,
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Color(0xFFEDE8DD),
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: PicoTypography.titleCard.copyWith(
                        color: isSelected ? PicoColors.primary : PicoColors.textPitchInk,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      sublabel,
                      style: PicoTypography.labelPillSm.copyWith(
                        color: isSelected ? PicoColors.primary : PicoColors.textTactileMuted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: -4.0,
                right: 6.0,
                child: Container(
                  width: 16.0,
                  height: 16.0,
                  decoration: const BoxDecoration(
                    color: PicoColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 11.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Step 2: Predict Exact Score (Vertical Stepper Arena)
  Widget _buildStep2ScoreStepper() {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
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
                  Flexible(
                    child: Text(
                      widget.match.status == MatchStatus.finished
                          ? 'Final Match Score'
                          : (l10n?.exactScoreTitle ?? 'Exact Score Prediction'),
                      style: PicoTypography.titleCard.copyWith(
                        color: PicoColors.textPitchInk,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.match.status == MatchStatus.finished) ...[
              const SizedBox(width: 8.0),
              Text(
                'FULL TIME',
                style: PicoTypography.labelPillSm.copyWith(
                  color: PicoColors.textTactileMuted,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12.0),

        // Stepper Arena
        ScoreStepperArena(
          homeScore: _homeScore,
          awayScore: _awayScore,
          homeTeamCode: widget.match.homeTeamCode,
          awayTeamCode: widget.match.awayTeamCode,
          onHomeScoreChanged: _updateHomeScore,
          onAwayScoreChanged: _updateAwayScore,
          enabled: !_isLocked,
        ),
      ],
    );
  }

  /// Scoring Potential calculation rules banner
  Widget _buildScoringPotentialBanner() {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F2),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE5DFD0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.match.status == MatchStatus.finished
                      ? (l10n?.picoScoringRules ?? 'PICO SCORING RULES')
                      : (l10n?.potentialPointsHeader.toUpperCase() ?? 'POTENTIAL PICO POINTS'),
                  style: PicoTypography.labelPillSm.copyWith(
                    color: const Color(0xFF5C6B64),
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: PicoColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  '+5 Pts Max',
                  style: PicoTypography.labelPillSm.copyWith(
                    color: PicoColors.primaryDark,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Row 1: Exact Score
          _buildScoringRow(
            icon: Icons.stars_rounded,
            iconColor: const Color(0xFFD97706),
            label: l10n?.scoringRuleExactTitle ?? 'Exact Score',
            subtitle: l10n?.scoringRuleExactDesc ?? 'Predict the exact final scoreline',
            pointsBadge: l10n?.pointsOutcomeExact ?? '+5 Points',
            badgeBg: PicoColors.primary.withValues(alpha: 0.12),
            badgeColor: PicoColors.primaryDark,
          ),
          const SizedBox(height: 6.0),

          // Row 2: Winner + Goal Diff
          _buildScoringRow(
            icon: Icons.sports_soccer_rounded,
            iconColor: PicoColors.primary,
            label: l10n?.scoringRuleGoalDiffTitle ?? 'Winner + Goal Diff',
            subtitle: l10n?.scoringRuleGoalDiffDesc ?? 'Correct winner and goal margin',
            pointsBadge: l10n?.pointsOutcomeGoalDiff ?? '+3 Points',
            badgeBg: const Color(0xFFFEF3C7),
            badgeColor: const Color(0xFF92400E),
          ),
          const SizedBox(height: 6.0),

          // Row 3: Correct Winner
          _buildScoringRow(
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF0284C7),
            label: l10n?.scoringRuleWinnerOnlyTitle ?? 'Correct Winner',
            subtitle: l10n?.scoringRuleWinnerOnlyDesc ?? 'Correct winner, other scoreline',
            pointsBadge: l10n?.pointsOutcomeOne ?? '+1 Point',
            badgeBg: const Color(0xFFE0F2FE),
            badgeColor: const Color(0xFF0369A1),
          ),
        ],
      ),
    );
  }

  Widget _buildScoringRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required String pointsBadge,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFECE7DC), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 28.0,
            height: 28.0,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, size: 16.0, color: iconColor),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: PicoColors.textPitchInk,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6F7A70),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              pointsBadge,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Primary 3D tactile gold call-to-action button
  Widget _buildLockPredictionButton() {
    final l10n = AppLocalizations.of(context);
    final predictions = ref.watch(predictionControllerProvider);
    final bool hasExistingPrediction = predictions.value?.containsKey(widget.match.id) ?? false;
    final bool isFinished = widget.match.status == MatchStatus.finished;
    final bool isLive = widget.match.status == MatchStatus.live;
    final bool isTeaser = widget.match.isTeaser;

    final String ctaText;
    final IconData ctaIcon;
    final String ctaNote;

    if (isFinished) {
      ctaText = 'Match Finished';
      ctaIcon = Icons.lock_rounded;
      ctaNote = 'Match completed · Controls are locked.';
    } else if (isLive) {
      ctaText = 'Match In Progress';
      ctaIcon = Icons.play_circle_outline_rounded;
      ctaNote = 'Live match in progress · Predictions closed.';
    } else if (isTeaser) {
      ctaText = 'Opens in ${widget.match.teaserCountdownShort}';
      ctaIcon = Icons.timer_outlined;
      ctaNote = l10n?.teaserCountdownSubtext ?? 'Prediction window opens 3 days before kickoff.';
    } else if (_isLocked) {
      ctaText = l10n?.predictionLockedTitle.replaceAll('! ⚽', '') ?? 'Prediction Locked';
      ctaIcon = Icons.lock_rounded;
      ctaNote = l10n?.predictionLockNote ?? 'Predictions lock exactly 10 minutes before kickoff.';
    } else {
      ctaText = hasExistingPrediction
          ? (l10n?.modifyPrediction != null
              ? '${l10n!.modifyPrediction} (+5 Points)'
              : 'Update Prediction (+5 Points)')
          : (l10n?.savePredictionCta ?? 'Save Prediction (+5 Points)');
      ctaIcon = Icons.arrow_forward_rounded;
      ctaNote = l10n?.predictionLockNote ?? 'Predictions lock exactly 10 minutes before kickoff.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GameButton.green(
          text: _isSubmitting ? '...' : ctaText,
          icon: Icon(
            ctaIcon,
            color: Colors.white,
            size: 18.0,
          ),
          width: double.infinity,
          extrusionHeight: 4.5,
          borderRadius: 16.0,
          fontSize: 15.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
          enabled: !_isLocked && !_isSubmitting,
          onPressed: _isLocked || _isSubmitting ? null : _submitPrediction,
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isTeaser ? Icons.timer_outlined : Icons.lock_clock_outlined,
              size: 13.0,
              color: const Color(0xFF6F7A70),
            ),
            const SizedBox(width: 4.0),
            Flexible(
              child: Text(
                ctaNote,
                style: PicoTypography.bodySm.copyWith(
                  color: const Color(0xFF6F7A70),
                  fontSize: 11.0,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
