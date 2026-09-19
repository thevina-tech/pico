import 'package:flutter/material.dart';
import '../../core/theme/pico_colors.dart';
import '../../core/theme/pico_typography.dart';

enum PicoChipType { live, multiplier, status, category }

/// Reusable pill/chip components for match status, odds multipliers, and category tags.
class PicoChip extends StatefulWidget {
  const PicoChip({
    super.key,
    required this.label,
    this.type = PicoChipType.status,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  /// A vibrant live match badge with an animated pulsing indicator dot.
  const PicoChip.live({
    super.key,
    required this.label,
  })  : type = PicoChipType.live,
        icon = null,
        backgroundColor = null,
        textColor = null,
        borderColor = null;

  /// A champagne gold badge highlighting XP multipliers or streak bonuses.
  const PicoChip.multiplier({
    super.key,
    required this.label,
    this.icon,
  })  : type = PicoChipType.multiplier,
        backgroundColor = null,
        textColor = null,
        borderColor = null;

  /// A clean status badge (e.g., 'UPCOMING', 'LOCKED', '4/5 Steps').
  const PicoChip.status({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  }) : type = PicoChipType.status;

  final String label;
  final PicoChipType type;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  @override
  State<PicoChip> createState() => _PicoChipState();
}

class _PicoChipState extends State<PicoChip> with SingleTickerProviderStateMixin {
  late final AnimationController? _pulseController;
  late final Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.type == PicoChipType.live) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true);
      _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
    } else {
      _pulseController = null;
      _pulseAnimation = null;
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case PicoChipType.live:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: PicoColors.electricMint,
            borderRadius: BorderRadius.circular(999.0),
            boxShadow: [
              BoxShadow(
                color: PicoColors.electricMint.withValues(alpha: 0.35),
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation!,
                builder: (context, child) {
                  return Opacity(
                    opacity: _pulseAnimation.value,
                    child: Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: const BoxDecoration(
                        color: PicoColors.textPitchInk,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 5.0),
              Text(
                widget.label.toUpperCase(),
                style: PicoTypography.labelPill.copyWith(
                  color: PicoColors.textPitchInk,
                  fontWeight: FontWeight.w800,
                  fontSize: 10.5,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );

      case PicoChipType.multiplier:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
          decoration: BoxDecoration(
            color: PicoColors.cardFace,
            borderRadius: BorderRadius.circular(999.0),
            border: Border.all(
              color: PicoColors.gold,
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 4.0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 4.0),
              ],
              Text(
                widget.label,
                style: PicoTypography.labelPill.copyWith(
                  color: const Color(0xFF7A5C1E),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
        );

      case PicoChipType.status:
      case PicoChipType.category:
        final bg = widget.backgroundColor ?? const Color(0x33000000);
        final fg = widget.textColor ?? PicoColors.textWhite;
        final border = widget.borderColor ?? const Color(0x1AFFFFFF);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.5),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999.0),
            border: Border.all(color: border, width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 4.0),
              ],
              Text(
                widget.label.toUpperCase(),
                style: PicoTypography.labelPill.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.0,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        );
    }
  }
}
