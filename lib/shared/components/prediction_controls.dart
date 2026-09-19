import 'package:flutter/material.dart';
import '../../core/theme/pico_colors.dart';
import '../../core/theme/pico_typography.dart';

/// A chunky squircle stepper (+ / −) with spring tactile mechanical depression.
class ScoreStepperButton extends StatefulWidget {
  const ScoreStepperButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 36.0,
    this.bevelHeight = 3.0,
    this.borderRadius = 10.0,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double bevelHeight;
  final double borderRadius;

  @override
  State<ScoreStepperButton> createState() => _ScoreStepperButtonState();
}

class _ScoreStepperButtonState extends State<ScoreStepperButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
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
          color: isEnabled ? PicoColors.cardFace : PicoColors.cardFace.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: PicoColors.cardBevelDark,
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
          color: isEnabled ? PicoColors.textPitchInk : PicoColors.textTactileMuted,
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
  });

  final int score;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScoreStepperButton(
          icon: Icons.remove,
          onPressed: score > min ? () => onChanged(score - 1) : null,
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 38.0),
          alignment: Alignment.center,
          child: Text(
            '$score',
            style: PicoTypography.headlineMd.copyWith(
              color: PicoColors.textPitchInk,
              fontWeight: FontWeight.w800,
              fontSize: 22.0,
            ),
          ),
        ),
        ScoreStepperButton(
          icon: Icons.add,
          onPressed: score < max ? () => onChanged(score + 1) : null,
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
  });

  final MatchOutcome? selectedOutcome;
  final ValueChanged<MatchOutcome> onSelected;
  final String homeCode;
  final String drawCode;
  final String awayCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OutcomeTile(
            label: homeCode,
            sublabel: 'Home',
            isSelected: selectedOutcome == MatchOutcome.home,
            onTap: () => onSelected(MatchOutcome.home),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: _OutcomeTile(
            label: drawCode,
            sublabel: 'Draw',
            isSelected: selectedOutcome == MatchOutcome.draw,
            onTap: () => onSelected(MatchOutcome.draw),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: _OutcomeTile(
            label: awayCode,
            sublabel: 'Away',
            isSelected: selectedOutcome == MatchOutcome.away,
            onTap: () => onSelected(MatchOutcome.away),
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
  });

  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 58.0,
        decoration: BoxDecoration(
          color: isSelected ? PicoColors.cardFace : PicoColors.cardTray,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? PicoColors.primary : PicoColors.cardBevel,
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
                    blurRadius: 10,
                  ),
                ]
              : const [
                  BoxShadow(
                    color: PicoColors.cardBevel,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Positioned(
                top: 5.0,
                right: 6.0,
                child: Container(
                  width: 7.0,
                  height: 7.0,
                  decoration: const BoxDecoration(
                    color: PicoColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: PicoTypography.headlineMd.copyWith(
                    color: isSelected ? PicoColors.primaryDark : PicoColors.textPitchInk,
                    fontWeight: FontWeight.w800,
                    fontSize: 18.0,
                  ),
                ),
                Text(
                  sublabel.toUpperCase(),
                  style: PicoTypography.labelPillSm.copyWith(
                    color: isSelected ? PicoColors.primary : PicoColors.textTactileMuted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
