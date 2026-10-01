import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'game_button.dart';
import 'prediction_controls.dart';

/// The 4 distinct lifecycle states of a match card in Pico.
enum MatchCardState {
  unpredicted,
  predicted,
  locked,
  finished,
}

/// The core fixture match card in Pico's "Friendly Football World" design system,
/// precisely matching the canonical designs in `assets/Screens/Matches.jpeg`.
///
/// Features a tactile cream card face (`#F7F4EC`) with 3D bottom bevel (`#EDE8DD`),
/// team squircle crests, state-specific center indicator, and responsive 3D action CTA.
class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.competition,
    this.kickoffTime,
    this.lockStatusLabel,
    required this.homeTeamName,
    required this.homeTeamCode,
    required this.awayTeamName,
    required this.awayTeamCode,
    this.homeTeamCrest,
    this.awayTeamCrest,
    this.homeTeamBadgeUrl,
    this.awayTeamBadgeUrl,
    this.state = MatchCardState.unpredicted,
    this.predictedHomeScore,
    this.predictedAwayScore,
    this.finalHomeScore,
    this.finalAwayScore,
    this.closesAtTime,
    this.editableUntilTime,
    this.statusSubtext,
    this.scoreBadgeLabel,
    this.isExactScore = false,
    this.awardedPoints,
    this.isTeaser = false,
    this.teaserLabel,
    this.teaserSubtext,
    this.settlementOutcomeLabel,
    this.showInlinePrediction = false,
    this.inlineHomeScore,
    this.inlineAwayScore,
    this.onInlineHomeScoreChanged,
    this.onInlineAwayScoreChanged,
    this.onQuickPredict,
    this.onCardTap,
    this.onPredictPressed,
    this.onModifyPressed,
    this.onViewPredictionPressed,
    this.onTapResult,
  });

  /// Factory constructor that binds directly to a [PicoMatch] domain entity from MockMatchRepository.
  factory MatchCard.fromMatch({
    Key? key,
    required PicoMatch match,
    int? predictedHomeScore,
    int? predictedAwayScore,
    int? awardedPoints,
    String? settlementOutcomeLabel,
    String? teaserCountdownLabel,
    String? teaserSubtext,
    bool showInlinePrediction = false,
    int? inlineHomeScore,
    int? inlineAwayScore,
    ValueChanged<int>? onInlineHomeScoreChanged,
    ValueChanged<int>? onInlineAwayScoreChanged,
    VoidCallback? onQuickPredict,
    VoidCallback? onCardTap,
    VoidCallback? onPredictPressed,
    VoidCallback? onModifyPressed,
    VoidCallback? onViewPredictionPressed,
    VoidCallback? onTapResult,
  }) {
    final bool hasPrediction = predictedHomeScore != null && predictedAwayScore != null;

    if (match.status == MatchStatus.finished) {
      final int? points = awardedPoints ??
          match.calculateSettlementPoints(predictedHomeScore, predictedAwayScore);
      final String outcome;
      if (settlementOutcomeLabel != null) {
        outcome = settlementOutcomeLabel;
      } else if (hasPrediction && points != null) {
        outcome = points > 0 ? '+$points Points' : '0 Points';
      } else {
        outcome = 'No Prediction';
      }

      return MatchCard.finished(
        key: key,
        competition: match.competitionName.toUpperCase(),
        homeTeamName: match.homeTeamName,
        homeTeamCode: match.homeTeamCode,
        homeTeamBadgeUrl: match.homeTeamBadgeUrl,
        awayTeamName: match.awayTeamName,
        awayTeamCode: match.awayTeamCode,
        awayTeamBadgeUrl: match.awayTeamBadgeUrl,
        finalHomeScore: match.homeScore ?? 0,
        finalAwayScore: match.awayScore ?? 0,
        scoreBadgeLabel: 'FINAL',
        statusSubtext: hasPrediction
            ? 'Your prediction: $predictedHomeScore - $predictedAwayScore'
            : 'Full time · Points awarded',
        awardedPoints: points ?? 0,
        settlementOutcomeLabel: outcome,
        onCardTap: onCardTap,
        onTapResult: onTapResult,
      );
    }

    if (match.isLocked || match.status == MatchStatus.live) {
      return MatchCard.locked(
        key: key,
        competition: match.competitionName.toUpperCase(),
        lockStatusLabel: match.status == MatchStatus.live ? 'LIVE' : 'LOCKED',
        homeTeamName: match.homeTeamName,
        homeTeamCode: match.homeTeamCode,
        homeTeamBadgeUrl: match.homeTeamBadgeUrl,
        awayTeamName: match.awayTeamName,
        awayTeamCode: match.awayTeamCode,
        awayTeamBadgeUrl: match.awayTeamBadgeUrl,
        lockedHomeScore: predictedHomeScore ?? 0,
        lockedAwayScore: predictedAwayScore ?? 0,
        statusSubtext: match.status == MatchStatus.live
            ? 'Match in progress'
            : 'Prediction locked · Kickoff at ${match.kickoffTimeFormatted}',
        onCardTap: onCardTap,
        onViewPredictionPressed: onViewPredictionPressed,
      );
    }

    if (hasPrediction) {
      return MatchCard.predicted(
        key: key,
        competition: match.competitionName.toUpperCase(),
        kickoffTime: match.kickoffTimeFormatted,
        homeTeamName: match.homeTeamName,
        homeTeamCode: match.homeTeamCode,
        homeTeamBadgeUrl: match.homeTeamBadgeUrl,
        awayTeamName: match.awayTeamName,
        awayTeamCode: match.awayTeamCode,
        awayTeamBadgeUrl: match.awayTeamBadgeUrl,
        predictedHomeScore: predictedHomeScore,
        predictedAwayScore: predictedAwayScore,
        showInlinePrediction: showInlinePrediction,
        inlineHomeScore: inlineHomeScore,
        inlineAwayScore: inlineAwayScore,
        onInlineHomeScoreChanged: onInlineHomeScoreChanged,
        onInlineAwayScoreChanged: onInlineAwayScoreChanged,
        onQuickPredict: onQuickPredict,
        onCardTap: onCardTap,
        editableUntilTime: match.closesAtTimeFormatted,
        onModifyPressed: onModifyPressed,
      );
    }

    // Teaser window: 7 to 14 days out
    if (match.isTeaser) {
      final String countdownText = teaserCountdownLabel ??
          'Opens in ${match.teaserCountdownShort}';
      return MatchCard.unpredicted(
        key: key,
        competition: match.competitionName.toUpperCase(),
        kickoffTime: match.kickoffTimeFormatted,
        homeTeamName: match.homeTeamName,
        homeTeamCode: match.homeTeamCode,
        homeTeamBadgeUrl: match.homeTeamBadgeUrl,
        awayTeamName: match.awayTeamName,
        awayTeamCode: match.awayTeamCode,
        awayTeamBadgeUrl: match.awayTeamBadgeUrl,
        closesAtTime: match.closesAtTimeFormatted,
        isTeaser: true,
        teaserLabel: countdownText,
        teaserSubtext: teaserSubtext,
        onCardTap: onCardTap,
        onPredictPressed: null, // Disabled in teaser window
      );
    }

    return MatchCard.unpredicted(
      key: key,
      competition: match.competitionName.toUpperCase(),
      kickoffTime: match.kickoffTimeFormatted,
      homeTeamName: match.homeTeamName,
      homeTeamCode: match.homeTeamCode,
      homeTeamBadgeUrl: match.homeTeamBadgeUrl,
      awayTeamName: match.awayTeamName,
      awayTeamCode: match.awayTeamCode,
      awayTeamBadgeUrl: match.awayTeamBadgeUrl,
      closesAtTime: match.closesAtTimeFormatted,
      showInlinePrediction: showInlinePrediction,
      inlineHomeScore: inlineHomeScore,
      inlineAwayScore: inlineAwayScore,
      onInlineHomeScoreChanged: onInlineHomeScoreChanged,
      onInlineAwayScoreChanged: onInlineAwayScoreChanged,
      onQuickPredict: onQuickPredict,
      onCardTap: onCardTap,
      onPredictPressed: onPredictPressed,
    );
  }

  /// Factory constructor for an unpredicted match (Card 1 in Matches.jpeg).
  factory MatchCard.unpredicted({
    Key? key,
    required String competition,
    required String kickoffTime,
    required String homeTeamName,
    required String homeTeamCode,
    required String awayTeamName,
    required String awayTeamCode,
    Widget? homeTeamCrest,
    Widget? awayTeamCrest,
    String? homeTeamBadgeUrl,
    String? awayTeamBadgeUrl,
    String? closesAtTime,
    bool isTeaser = false,
    String? teaserLabel,
    String? teaserSubtext,
    bool showInlinePrediction = false,
    int? inlineHomeScore,
    int? inlineAwayScore,
    ValueChanged<int>? onInlineHomeScoreChanged,
    ValueChanged<int>? onInlineAwayScoreChanged,
    VoidCallback? onQuickPredict,
    VoidCallback? onCardTap,
    VoidCallback? onPredictPressed,
  }) {
    return MatchCard(
      key: key,
      competition: competition,
      kickoffTime: kickoffTime,
      homeTeamName: homeTeamName,
      homeTeamCode: homeTeamCode,
      awayTeamName: awayTeamName,
      awayTeamCode: awayTeamCode,
      homeTeamCrest: homeTeamCrest,
      awayTeamCrest: awayTeamCrest,
      homeTeamBadgeUrl: homeTeamBadgeUrl,
      awayTeamBadgeUrl: awayTeamBadgeUrl,
      state: MatchCardState.unpredicted,
      closesAtTime: closesAtTime,
      isTeaser: isTeaser,
      teaserLabel: teaserLabel,
      teaserSubtext: teaserSubtext,
      showInlinePrediction: showInlinePrediction,
      inlineHomeScore: inlineHomeScore,
      inlineAwayScore: inlineAwayScore,
      onInlineHomeScoreChanged: onInlineHomeScoreChanged,
      onInlineAwayScoreChanged: onInlineAwayScoreChanged,
      onQuickPredict: onQuickPredict,
      onCardTap: onCardTap,
      onPredictPressed: onPredictPressed,
    );
  }

  /// Factory constructor for a predicted, editable match (Card 2 in Matches.jpeg).
  factory MatchCard.predicted({
    Key? key,
    required String competition,
    required String kickoffTime,
    required String homeTeamName,
    required String homeTeamCode,
    required String awayTeamName,
    required String awayTeamCode,
    Widget? homeTeamCrest,
    Widget? awayTeamCrest,
    String? homeTeamBadgeUrl,
    String? awayTeamBadgeUrl,
    required int predictedHomeScore,
    required int predictedAwayScore,
    String? editableUntilTime,
    bool showInlinePrediction = false,
    int? inlineHomeScore,
    int? inlineAwayScore,
    ValueChanged<int>? onInlineHomeScoreChanged,
    ValueChanged<int>? onInlineAwayScoreChanged,
    VoidCallback? onQuickPredict,
    VoidCallback? onCardTap,
    VoidCallback? onModifyPressed,
  }) {
    return MatchCard(
      key: key,
      competition: competition,
      kickoffTime: kickoffTime,
      homeTeamName: homeTeamName,
      homeTeamCode: homeTeamCode,
      awayTeamName: awayTeamName,
      awayTeamCode: awayTeamCode,
      homeTeamCrest: homeTeamCrest,
      awayTeamCrest: awayTeamCrest,
      homeTeamBadgeUrl: homeTeamBadgeUrl,
      awayTeamBadgeUrl: awayTeamBadgeUrl,
      state: MatchCardState.predicted,
      predictedHomeScore: predictedHomeScore,
      predictedAwayScore: predictedAwayScore,
      editableUntilTime: editableUntilTime,
      showInlinePrediction: showInlinePrediction,
      inlineHomeScore: inlineHomeScore,
      inlineAwayScore: inlineAwayScore,
      onInlineHomeScoreChanged: onInlineHomeScoreChanged,
      onInlineAwayScoreChanged: onInlineAwayScoreChanged,
      onQuickPredict: onQuickPredict,
      onCardTap: onCardTap,
      onModifyPressed: onModifyPressed,
    );
  }

  /// Factory constructor for a locked match fixture (Card 3 in Matches.jpeg).
  factory MatchCard.locked({
    Key? key,
    required String competition,
    String lockStatusLabel = 'LOCKED',
    required String homeTeamName,
    required String homeTeamCode,
    required String awayTeamName,
    required String awayTeamCode,
    Widget? homeTeamCrest,
    Widget? awayTeamCrest,
    String? homeTeamBadgeUrl,
    String? awayTeamBadgeUrl,
    required int lockedHomeScore,
    required int lockedAwayScore,
    String? statusSubtext = 'Prediction locked · Kickoff in 10 mins',
    VoidCallback? onCardTap,
    VoidCallback? onViewPredictionPressed,
  }) {
    return MatchCard(
      key: key,
      competition: competition,
      lockStatusLabel: lockStatusLabel,
      homeTeamName: homeTeamName,
      homeTeamCode: homeTeamCode,
      awayTeamName: awayTeamName,
      awayTeamCode: awayTeamCode,
      homeTeamCrest: homeTeamCrest,
      awayTeamCrest: awayTeamCrest,
      homeTeamBadgeUrl: homeTeamBadgeUrl,
      awayTeamBadgeUrl: awayTeamBadgeUrl,
      state: MatchCardState.locked,
      predictedHomeScore: lockedHomeScore,
      predictedAwayScore: lockedAwayScore,
      statusSubtext: statusSubtext,
      onCardTap: onCardTap,
      onViewPredictionPressed: onViewPredictionPressed,
    );
  }

  /// Factory constructor for a completed fixture with final score and points (Card 4 in Matches.jpeg).
  factory MatchCard.finished({
    Key? key,
    required String competition,
    required String homeTeamName,
    required String homeTeamCode,
    required String awayTeamName,
    required String awayTeamCode,
    Widget? homeTeamCrest,
    Widget? awayTeamCrest,
    String? homeTeamBadgeUrl,
    String? awayTeamBadgeUrl,
    required int finalHomeScore,
    required int finalAwayScore,
    String scoreBadgeLabel = 'EXACT SCORE',
    bool isExactScore = true,
    int awardedPoints = 3,
    String? settlementOutcomeLabel,
    String? statusSubtext = 'Full time · Points awarded to leaderboard',
    VoidCallback? onCardTap,
    VoidCallback? onTapResult,
  }) {
    return MatchCard(
      key: key,
      competition: competition,
      homeTeamName: homeTeamName,
      homeTeamCode: homeTeamCode,
      awayTeamName: awayTeamName,
      awayTeamCode: awayTeamCode,
      homeTeamCrest: homeTeamCrest,
      awayTeamCrest: awayTeamCrest,
      homeTeamBadgeUrl: homeTeamBadgeUrl,
      awayTeamBadgeUrl: awayTeamBadgeUrl,
      state: MatchCardState.finished,
      finalHomeScore: finalHomeScore,
      finalAwayScore: finalAwayScore,
      scoreBadgeLabel: scoreBadgeLabel,
      isExactScore: isExactScore,
      awardedPoints: awardedPoints,
      settlementOutcomeLabel: settlementOutcomeLabel,
      statusSubtext: statusSubtext,
      onCardTap: onCardTap,
      onTapResult: onTapResult,
    );
  }

  /// Alias for upcoming fixtures (for backward compatibility).
  factory MatchCard.upcoming({
    Key? key,
    required String competition,
    required String time,
    required String homeTeamName,
    required String homeTeamCode,
    required String awayTeamName,
    required String awayTeamCode,
    Widget? homeTeamCrest,
    Widget? awayTeamCrest,
    String? homeTeamBadgeUrl,
    String? awayTeamBadgeUrl,
    String? closesAtTime,
    VoidCallback? onPredictPressed,
  }) {
    return MatchCard.unpredicted(
      key: key,
      competition: competition,
      kickoffTime: time,
      homeTeamName: homeTeamName,
      homeTeamCode: homeTeamCode,
      awayTeamName: awayTeamName,
      awayTeamCode: awayTeamCode,
      homeTeamCrest: homeTeamCrest,
      awayTeamCrest: awayTeamCrest,
      homeTeamBadgeUrl: homeTeamBadgeUrl,
      awayTeamBadgeUrl: awayTeamBadgeUrl,
      closesAtTime: closesAtTime,
      onPredictPressed: onPredictPressed,
    );
  }

  final String competition;
  final String? kickoffTime;
  final String? lockStatusLabel;
  final String homeTeamName;
  final String homeTeamCode;
  final String awayTeamName;
  final String awayTeamCode;
  final Widget? homeTeamCrest;
  final Widget? awayTeamCrest;
  final String? homeTeamBadgeUrl;
  final String? awayTeamBadgeUrl;
  final MatchCardState state;
  final int? predictedHomeScore;
  final int? predictedAwayScore;
  final int? finalHomeScore;
  final int? finalAwayScore;
  final String? closesAtTime;
  final String? editableUntilTime;
  final String? statusSubtext;
  final String? scoreBadgeLabel;
  final bool isExactScore;
  final int? awardedPoints;
  final bool isTeaser;
  final String? teaserLabel;
  final String? teaserSubtext;
  final String? settlementOutcomeLabel;
  final bool showInlinePrediction;
  final int? inlineHomeScore;
  final int? inlineAwayScore;
  final ValueChanged<int>? onInlineHomeScoreChanged;
  final ValueChanged<int>? onInlineAwayScoreChanged;
  final VoidCallback? onQuickPredict;
  final VoidCallback? onCardTap;
  final VoidCallback? onPredictPressed;
  final VoidCallback? onModifyPressed;
  final VoidCallback? onViewPredictionPressed;
  final VoidCallback? onTapResult;

  @override
  Widget build(BuildContext context) {
    const double bevelHeight = 4.0;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 3D Bottom Shelf Bevel
          Positioned(
            top: bevelHeight,
            left: 0,
            right: 0,
            bottom: -bevelHeight,
            child: Container(
              decoration: BoxDecoration(
                color: PicoColors.cardBevel,
                borderRadius: BorderRadius.circular(22.0),
              ),
            ),
          ),

          // Main Card Face
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCardTap,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: PicoColors.cardFace,
                borderRadius: BorderRadius.circular(22.0),
                border: Border.all(color: PicoColors.cardBorder, width: 1.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20.0),
                  _buildTeamsRow(),
                  const SizedBox(height: 22.0),
                  _buildActionArea(),
                  const SizedBox(height: 8.0),
                  _buildSubtext(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Competition dot indicator and kickoff / status pill
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Green dot + Competition text
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7.0,
                height: 7.0,
                decoration: const BoxDecoration(
                  color: PicoColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6.0),
              Flexible(
                child: Text(
                  competition.toUpperCase(),
                  style: PicoTypography.labelPillSm.copyWith(
                    color: PicoColors.textTactileMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8.0),

        // Right: Status / Time Pill
        _buildHeaderStatusPill(),
      ],
    );
  }

  Widget _buildHeaderStatusPill() {
    if (state == MatchCardState.finished) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: const Color(0xFF151917),
          borderRadius: BorderRadius.circular(999.0),
        ),
        child: const Text(
          'FT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 10.5,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    if (state == MatchCardState.locked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.5),
        decoration: BoxDecoration(
          color: PicoColors.cardTray,
          borderRadius: BorderRadius.circular(999.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 12.0, color: PicoColors.textTactileMuted),
            const SizedBox(width: 4.0),
            Text(
              lockStatusLabel ?? 'Locks Soon',
              style: PicoTypography.labelPillSm.copyWith(
                color: PicoColors.textTactileMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Default: Kickoff Time
    final String timeText = kickoffTime != null ? 'Kickoff $kickoffTime' : 'Upcoming';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.5),
      decoration: BoxDecoration(
        color: PicoColors.cardTray,
        borderRadius: BorderRadius.circular(999.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_rounded, size: 12.0, color: PicoColors.textTactileMuted),
          const SizedBox(width: 4.0),
          Text(
            timeText,
            style: PicoTypography.labelPillSm.copyWith(
              color: PicoColors.textTactileMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Team row featuring home team, state-specific center indicator, and away team
  Widget _buildTeamsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Home Team
        Expanded(
          child: _TeamBlock(
            name: homeTeamName,
            code: homeTeamCode,
            crest: homeTeamCrest,
            badgeUrl: homeTeamBadgeUrl,
            isHome: true,
          ),
        ),

        // Center Indicator (VS, Score, or Locked) aligned with crest center
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: _buildCenterIndicator(),
        ),

        // Away Team
        Expanded(
          child: _TeamBlock(
            name: awayTeamName,
            code: awayTeamCode,
            crest: awayTeamCrest,
            badgeUrl: awayTeamBadgeUrl,
            isHome: false,
          ),
        ),
      ],
    );
  }

  /// State-specific center indicator
  Widget _buildCenterIndicator() {
    switch (state) {
      case MatchCardState.unpredicted:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38.0,
              height: 38.0,
              decoration: const BoxDecoration(
                color: PicoColors.cardTray,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'VS',
                  style: PicoTypography.labelPillSm.copyWith(
                    color: PicoColors.textTactileMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
              decoration: BoxDecoration(
                color: isTeaser
                    ? PicoColors.primaryTintContainer
                    : PicoColors.cardTray,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                isTeaser ? 'OPENS SOON' : 'NOT PREDICTED',
                style: PicoTypography.labelPillSm.copyWith(
                  color: isTeaser
                      ? PicoColors.primaryBevel
                      : PicoColors.textTactileMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 9.0,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        );

      case MatchCardState.predicted:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Solid Green Score Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1B7543),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Text(
                '$predictedHomeScore - $predictedAwayScore',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18.0,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            // Mint chip with checkmark
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(color: const Color(0xFF86EFAC), width: 1.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 11.0, color: Color(0xFF15803D)),
                  const SizedBox(width: 4.0),
                  Text(
                    'PREDICTED $predictedHomeScore-$predictedAwayScore',
                    style: const TextStyle(
                      color: Color(0xFF15803D),
                      fontWeight: FontWeight.w800,
                      fontSize: 9.0,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case MatchCardState.locked:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Charcoal Locked Score Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2621),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Text(
                '$predictedHomeScore - $predictedAwayScore',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18.0,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            // Grey capsule with lock icon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
              decoration: BoxDecoration(
                color: PicoColors.cardTray,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded, size: 10.0, color: PicoColors.textTactileMuted),
                  const SizedBox(width: 4.0),
                  Text(
                    'LOCKED $predictedHomeScore-$predictedAwayScore',
                    style: PicoTypography.labelPillSm.copyWith(
                      color: PicoColors.textTactileMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 9.0,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case MatchCardState.finished:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Light Score Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: PicoColors.cardTray,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: PicoColors.cardBorder, width: 1.0),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$finalHomeScore',
                      style: const TextStyle(
                        color: Color(0xFF15803D),
                        fontWeight: FontWeight.w800,
                        fontSize: 18.0,
                      ),
                    ),
                    const TextSpan(
                      text: ' - ',
                      style: TextStyle(
                        color: PicoColors.textPitchInk,
                        fontWeight: FontWeight.w800,
                        fontSize: 18.0,
                      ),
                    ),
                    TextSpan(
                      text: '$finalAwayScore',
                      style: const TextStyle(
                        color: PicoColors.textPitchInk,
                        fontWeight: FontWeight.w800,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            // Gold Exact Score Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8C8),
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(color: const Color(0xFFFCD34D), width: 1.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 10.0)),
                  const SizedBox(width: 4.0),
                  Text(
                    scoreBadgeLabel ?? 'EXACT SCORE',
                    style: const TextStyle(
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w800,
                      fontSize: 9.0,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  /// Action Area matching each state
  Widget _buildActionArea() {
    if (showInlinePrediction &&
        state != MatchCardState.finished &&
        state != MatchCardState.locked) {
      final homeScore = inlineHomeScore ?? predictedHomeScore ?? 0;
      final awayScore = inlineAwayScore ?? predictedAwayScore ?? 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: PicoColors.cardTray,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: PicoColors.cardBorder, width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Home Stepper
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      homeTeamCode.toUpperCase(),
                      style: PicoTypography.labelPillSm.copyWith(
                        color: PicoColors.textTactileMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.0,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    ScoreStepper(
                      score: homeScore,
                      onChanged: onInlineHomeScoreChanged ?? (_) {},
                      size: 32.0,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text(
                    ':',
                    style: PicoTypography.headlineMd.copyWith(
                      color: PicoColors.textTactileMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 22.0,
                    ),
                  ),
                ),
                // Away Stepper
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      awayTeamCode.toUpperCase(),
                      style: PicoTypography.labelPillSm.copyWith(
                        color: PicoColors.textTactileMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.0,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    ScoreStepper(
                      score: awayScore,
                      onChanged: onInlineAwayScoreChanged ?? (_) {},
                      size: 32.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          GameButton.green(
            text: state == MatchCardState.predicted
                ? 'Update Prediction ($homeScore - $awayScore)'
                : 'Quick Predict ($homeScore - $awayScore)',
            width: double.infinity,
            extrusionHeight: 4.5,
            borderRadius: 16.0,
            fontSize: 14.5,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            onPressed: onQuickPredict ?? onPredictPressed,
          ),
        ],
      );
    }

    switch (state) {
      case MatchCardState.unpredicted:
        if (isTeaser) {
          return GameButton.green(
            text: teaserLabel ?? 'Opens in 2d',
            icon: const Icon(
              Icons.schedule_rounded,
              size: 16.0,
              color: Color(0xCCFFFFFF),
            ),
            width: double.infinity,
            extrusionHeight: 4.0,
            borderRadius: 16.0,
            fontSize: 14.5,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            enabled: false,
            onPressed: null,
          );
        }
        return GameButton.green(
          text: 'Make Prediction →',
          width: double.infinity,
          extrusionHeight: 4.5,
          borderRadius: 16.0,
          fontSize: 14.5,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          onPressed: onPredictPressed,
        );

      case MatchCardState.predicted:
        return GameButton.cream(
          text: 'Modify Prediction ($predictedHomeScore-$predictedAwayScore)',
          icon: const Icon(Icons.edit_outlined, size: 18.0, color: Color(0xFF1B7543)),
          width: double.infinity,
          extrusionHeight: 4.5,
          borderRadius: 16.0,
          fontSize: 14.5,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          onPressed: onModifyPressed,
        );

      case MatchCardState.locked:
        return GameButton.green(
          text: 'View Prediction',
          icon: const Icon(Icons.lock_rounded, size: 18.0, color: Colors.white),
          width: double.infinity,
          extrusionHeight: 4.5,
          borderRadius: 16.0,
          fontSize: 14.5,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          onPressed: onViewPredictionPressed,
        );

      case MatchCardState.finished:
        final String badgeText = settlementOutcomeLabel ??
            (awardedPoints != null
                ? (awardedPoints! > 0 ? '+$awardedPoints PTS' : '0 PTS')
                : '+3 PTS');
        return GestureDetector(
          onTap: onTapResult ?? onCardTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF082818),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: PicoColors.primary.withValues(alpha: 0.25), width: 1.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 22.0),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Match Finished',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'FT: $homeTeamName $finalHomeScore - $finalAwayScore $awayTeamName',
                        style: const TextStyle(
                          color: Color(0xFF98E3B6),
                          fontWeight: FontWeight.w500,
                          fontSize: 11.0,
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
                    color: const Color(0xFFE6C687),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Color(0xFF2C1C02),
                      fontWeight: FontWeight.w900,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  /// Helper subtext below the action area
  Widget _buildSubtext() {
    final String text;
    switch (state) {
      case MatchCardState.unpredicted:
        text = isTeaser
            ? (teaserSubtext ?? 'Prediction window opens 3 days before kickoff')
            : (closesAtTime != null
                ? 'Not predicted yet · Closes at $closesAtTime'
                : (statusSubtext ?? 'Not predicted yet · Closes before kickoff'));
        break;
      case MatchCardState.predicted:
        text = editableUntilTime != null
            ? 'Editable until $editableUntilTime'
            : (statusSubtext ?? 'Prediction confirmed');
        break;
      case MatchCardState.locked:
        text = statusSubtext ?? 'Prediction locked · Kickoff in 10 mins';
        break;
      case MatchCardState.finished:
        text = statusSubtext ?? 'Full time · Points awarded to leaderboard';
        break;
    }

    return Center(
      child: Text(
        text,
        style: PicoTypography.bodySm.copyWith(
          color: PicoColors.textTactileMuted,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

/// Team block with squircle crest, bold team name, and Home/Away subtitle
class _TeamBlock extends StatelessWidget {
  const _TeamBlock({
    required this.name,
    required this.code,
    this.crest,
    this.badgeUrl,
    required this.isHome,
  });

  final String name;
  final String code;
  final Widget? crest;
  final String? badgeUrl;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Squircle Container for Crest
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            width: 58.0,
            height: 58.0,
            decoration: BoxDecoration(
              color: PicoColors.cardTray,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: PicoColors.cardBorder, width: 1.5),
            ),
            child: _buildCrestWidget(),
          ),
        ),
        const SizedBox(height: 8.0),

        // Team Name (Centered, up to 2 lines, completely visible like PredictionScreen)
        SizedBox(
          height: 38.0,
          child: Center(
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: PicoTypography.headlineMd.copyWith(
                color: PicoColors.textPitchInk,
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2.0),

        // Home / Away Label
        Text(
          isHome ? 'Home' : 'Away',
          textAlign: TextAlign.center,
          style: PicoTypography.bodySm.copyWith(
            color: PicoColors.textTactileMuted,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCrestWidget() {
    if (crest != null) return crest!;
    final bool isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest && badgeUrl != null && badgeUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14.0),
        child: CachedNetworkImage(
          imageUrl: badgeUrl!,
          width: 58.0,
          height: 58.0,
          fit: BoxFit.cover,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          placeholder: (context, url) => _buildDefaultCrest(code),
          errorWidget: (context, url, error) => _buildDefaultCrest(code),
        ),
      );
    }
    return _buildDefaultCrest(code);
  }

  Widget _buildDefaultCrest(String code) {
    if (code.trim().isEmpty) {
      return Container(
        width: 36.0,
        height: 36.0,
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A2B),
          shape: BoxShape.circle,
          border: Border.all(color: PicoColors.cardBorder, width: 1.0),
        ),
        child: const Center(
          child: Icon(
            Icons.shield_rounded,
            color: Colors.white70,
            size: 18.0,
          ),
        ),
      );
    }
    final colors = _teamColors(code);
    return Container(
      width: 36.0,
      height: 36.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: PicoColors.cardBorder, width: 1.0),
      ),
      child: Center(
        child: Text(
          code,
          style: TextStyle(
            color: colors.first == const Color(0xFFFFFFFF) ? Colors.black : Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 10.0,
          ),
        ),
      ),
    );
  }

  List<Color> _teamColors(String code) {
    switch (code.toUpperCase()) {
      case 'FCB':
      case 'BAR':
        return const [Color(0xFF004D98), Color(0xFFA50044)];
      case 'RMA':
        return const [Color(0xFFFFFFFF), Color(0xFF00529F)];
      case 'ARS':
        return const [Color(0xFFEF0107), Color(0xFF063672)];
      case 'CHE':
        return const [Color(0xFF034694), Color(0xFF0A2B5E)];
      case 'ATM':
        return const [Color(0xFFCB3524), Color(0xFF1B2C52)];
      case 'SEV':
        return const [Color(0xFFFFFFFF), Color(0xFFD40E1B)];
      case 'BAY':
        return const [Color(0xFFDC052D), Color(0xFF0066B2)];
      case 'PSG':
      case 'PAR':
        return const [Color(0xFF004170), Color(0xFFDA291C)];
      case 'LIV':
        return const [Color(0xFFC8102E), Color(0xFF00B2A9)];
      case 'MCI':
        return const [Color(0xFF6CABDD), Color(0xFF1C2C5B)];
      default:
        return const [PicoColors.pitchSurfaceElevated, PicoColors.primary];
    }
  }
}
