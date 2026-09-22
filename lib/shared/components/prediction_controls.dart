import 'package:flutter/material.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/l10n/app_localizations.dart';

/// A chunky squircle stepper (+ / −) with spring tactile mechanical depression.
class ScoreStepperButton extends StatefulWidget {
  const ScoreStepperButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 36.0,
    this.bevelHeight = 3.0,
    this.borderRadius = 10.0,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double bevelHeight;
  final double borderRadius;
  final bool enabled;

  @override
  State<ScoreStepperButton> createState() => _ScoreStepperButtonState();
}

class _ScoreStepperButtonState extends State<ScoreStepperButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.enabled && widget.onPressed != null;
    final double currentBevel = _isPressed && isEnabled ? 0.0 : widget.bevelHeight;
    final double translationY = _isPressed && isEnabled ? widget.bevelHeight : 0.0;

    return GestureDetector(
      onTap: isEnabled ? () {} : null,
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0.0, translationY, 0.0),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: isEnabled
              ? PicoColors.cardFace
              : PicoColors.cardFace.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: isEnabled
                ? PicoColors.cardBevelDark
                : PicoColors.cardBevel.withValues(alpha: 0.3),
            width: 1.0,
          ),
          boxShadow: [
            if (currentBevel > 0.0 && isEnabled)
              BoxShadow(
                color: PicoColors.cardBevelDark,
                offset: Offset(0, currentBevel),
                blurRadius: 0,
              ),
          ],
        ),
        child: Icon(
          widget.icon,
          color: isEnabled
              ? PicoColors.textPitchInk
              : PicoColors.textTactileMuted.withValues(alpha: 0.6),
          size: 18.0,
        ),
      ),
    );
  }
}

/// A complete score stepper control with decrement, numeric display, and increment.
class ScoreStepper extends StatelessWidget {
  const ScoreStepper({
    super.key,
    required this.score,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
    this.enabled = true,
    this.size = 36.0,
  });

  final int score;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool enabled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScoreStepperButton(
          icon: Icons.remove,
          size: size,
          enabled: enabled,
          onPressed: (enabled && score > min) ? () => onChanged(score - 1) : null,
        ),
        Container(
          constraints: BoxConstraints(minWidth: size > 32 ? 38.0 : 30.0),
          alignment: Alignment.center,
          child: Text(
            '$score',
            style: PicoTypography.headlineMd.copyWith(
              color: enabled
                  ? PicoColors.textPitchInk
                  : PicoColors.textTactileMuted,
              fontWeight: FontWeight.w800,
              fontSize: size > 32 ? 22.0 : 18.0,
            ),
          ),
        ),
        ScoreStepperButton(
          icon: Icons.add,
          size: size,
          enabled: enabled,
          onPressed: (enabled && score < max) ? () => onChanged(score + 1) : null,
        ),
      ],
    );
  }
}

enum MatchOutcome { home, draw, away }

/// 1 / X / 2 Outcome Picker Tile matching Stitch's sunken well vs popped-up tile.
class WinnerSelector extends StatelessWidget {
  const WinnerSelector({
    super.key,
    required this.selectedOutcome,
    required this.onSelected,
    this.homeCode = '1',
    this.drawCode = 'X',
    this.awayCode = '2',
    this.homeLabel,
    this.drawLabel,
    this.awayLabel,
    this.enabled = true,
    this.isDark = false,
  });

  final MatchOutcome? selectedOutcome;
  final ValueChanged<MatchOutcome> onSelected;
  final String homeCode;
  final String drawCode;
  final String awayCode;
  final String? homeLabel;
  final String? drawLabel;
  final String? awayLabel;
  final bool enabled;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resolvedHome = homeLabel ?? l10n?.homeOutcome ?? 'Home';
    final resolvedDraw = drawLabel ?? l10n?.drawOutcome ?? 'Draw';
    final resolvedAway = awayLabel ?? l10n?.awayOutcome ?? 'Away';

    return Row(
      children: [
        Expanded(
          child: _OutcomeTile(
            label: homeCode,
            sublabel: resolvedHome,
            isSelected: selectedOutcome == MatchOutcome.home,
            enabled: enabled,
            isDark: isDark,
            onTap: enabled ? () => onSelected(MatchOutcome.home) : () {},
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: _OutcomeTile(
            label: drawCode,
            sublabel: resolvedDraw,
            isSelected: selectedOutcome == MatchOutcome.draw,
            enabled: enabled,
            isDark: isDark,
            onTap: enabled ? () => onSelected(MatchOutcome.draw) : () {},
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: _OutcomeTile(
            label: awayCode,
            sublabel: resolvedAway,
            isSelected: selectedOutcome == MatchOutcome.away,
            enabled: enabled,
            isDark: isDark,
            onTap: enabled ? () => onSelected(MatchOutcome.away) : () {},
          ),
        ),
      ],
    );
  }
}

class _OutcomeTile extends StatelessWidget {
  const _OutcomeTile({
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
    this.enabled = true,
    this.isDark = false,
  });

  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;
  final bool enabled;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bgColor = !enabled
        ? (isDark ? const Color(0xFF10261B) : PicoColors.cardTray.withValues(alpha: 0.5))
        : isSelected
            ? (isDark ? Colors.white : Colors.white)
            : (isDark ? const Color(0xFF132D20) : PicoColors.cardTray);

    final borderColor = !enabled
        ? (isDark ? const Color(0xFF1D4531) : PicoColors.cardBevel.withValues(alpha: 0.3))
        : isSelected
            ? PicoColors.primary
            : (isDark ? const Color(0xFF225039) : PicoColors.cardBevel);

    final textColor = !enabled
        ? PicoColors.textTactileMuted
        : isSelected
            ? PicoColors.primary
            : (isDark ? Colors.white : PicoColors.textPitchInk);

    final subtextColor = !enabled
        ? PicoColors.textTactileMuted
        : isSelected
            ? PicoColors.primary
            : (isDark ? PicoColors.primaryFixedDim : PicoColors.textTactileMuted);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 58.0,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: !enabled
              ? const []
              : isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0xFF1B5E3A),
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                      BoxShadow(
                        color: Color(0x26006A3A),
                        offset: Offset(0, 6),
                        blurRadius: 10,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: isDark ? const Color(0xFF081810) : PicoColors.cardBevel,
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected && enabled)
              Positioned(
                top: 4.0,
                right: 5.0,
                child: Container(
                  width: 14.0,
                  height: 14.0,
                  decoration: const BoxDecoration(
                    color: PicoColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10.0,
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: PicoTypography.headlineMd.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sublabel.toUpperCase(),
                  style: PicoTypography.labelPillSm.copyWith(
                    color: subtextColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A complete vertical exact score stepper arena displaying [+] button, score count,
/// and [-] button for both the home and away teams.
class ScoreStepperArena extends StatelessWidget {
  const ScoreStepperArena({
    super.key,
    required this.homeScore,
    required this.awayScore,
    required this.homeTeamCode,
    required this.awayTeamCode,
    required this.onHomeScoreChanged,
    required this.onAwayScoreChanged,
    this.enabled = true,
    this.isDark = false,
  });

  final int homeScore;
  final int awayScore;
  final String homeTeamCode;
  final String awayTeamCode;
  final ValueChanged<int> onHomeScoreChanged;
  final ValueChanged<int> onAwayScoreChanged;
  final bool enabled;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bool homeWinning = homeScore > awayScore;
    final bool awayWinning = awayScore > homeScore;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132D20) : const Color(0xFFF5F2E9),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? const Color(0xFF225039) : const Color(0xFFDED8C9),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Home Team Stepper Column
          _buildTeamColumn(
            teamCode: homeTeamCode,
            score: homeScore,
            isWinning: homeWinning,
            onIncrement: enabled ? () => onHomeScoreChanged(homeScore + 1) : null,
            onDecrement: (enabled && homeScore > 0)
                ? () => onHomeScoreChanged(homeScore - 1)
                : null,
          ),

          // Colon Separator
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Text(
              ':',
              style: PicoTypography.statCounter.copyWith(
                color: isDark ? const Color(0xFF336C4F) : const Color(0xFFBECABE),
                fontSize: 32.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Away Team Stepper Column
          _buildTeamColumn(
            teamCode: awayTeamCode,
            score: awayScore,
            isWinning: awayWinning,
            onIncrement: enabled ? () => onAwayScoreChanged(awayScore + 1) : null,
            onDecrement: (enabled && awayScore > 0)
                ? () => onAwayScoreChanged(awayScore - 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamColumn({
    required String teamCode,
    required int score,
    required bool isWinning,
    required VoidCallback? onIncrement,
    required VoidCallback? onDecrement,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          teamCode.toUpperCase(),
          style: PicoTypography.labelPillSm.copyWith(
            color: isDark ? PicoColors.primaryFixedDim : const Color(0xFF5C6B64),
            fontSize: 11.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8.0),
        ScoreStepperButton(
          icon: Icons.add,
          size: 44.0,
          borderRadius: 12.0,
          bevelHeight: 3.0,
          enabled: onIncrement != null,
          onPressed: onIncrement,
        ),
        const SizedBox(height: 8.0),
        Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F261B) : Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: isWinning
                  ? (isDark ? PicoColors.primaryFixed : PicoColors.primary.withValues(alpha: 0.5))
                  : (isDark ? const Color(0xFF225039) : const Color(0xFFD2CCC0)),
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$score',
              style: PicoTypography.statCounter.copyWith(
                color: isWinning
                    ? (isDark ? PicoColors.primaryFixed : PicoColors.primary)
                    : (isDark ? Colors.white : PicoColors.textPitchInk),
                fontSize: 30.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        ScoreStepperButton(
          icon: Icons.remove,
          size: 44.0,
          borderRadius: 12.0,
          bevelHeight: 3.0,
          enabled: onDecrement != null,
          onPressed: onDecrement,
        ),
      ],
    );
  }
}
