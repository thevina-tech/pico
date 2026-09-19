import 'package:flutter/material.dart';
import '../../core/theme/pico_colors.dart';
import '../../core/theme/pico_typography.dart';

enum PicoButtonVariant { primary, secondary, gold }

/// A physical, tactile 3D push button with a mechanical extrusion bevel that
/// translates downwards when pressed, matching the Stitch design system.
class PicoButton extends StatefulWidget {
  const PicoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = PicoButtonVariant.primary,
    this.icon,
    this.isFullWidth = true,
    this.height = 52.0,
    this.bevelHeight = 4.0,
    this.borderRadius = 14.0,
  });

  const PicoButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isFullWidth = true,
    this.height = 52.0,
    this.bevelHeight = 4.0,
    this.borderRadius = 14.0,
  }) : variant = PicoButtonVariant.primary;

  const PicoButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isFullWidth = true,
    this.height = 52.0,
    this.bevelHeight = 4.0,
    this.borderRadius = 14.0,
  }) : variant = PicoButtonVariant.secondary;

  const PicoButton.gold({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isFullWidth = true,
    this.height = 52.0,
    this.bevelHeight = 4.0,
    this.borderRadius = 14.0,
  }) : variant = PicoButtonVariant.gold;

  final String text;
  final VoidCallback? onPressed;
  final PicoButtonVariant variant;
  final Widget? icon;
  final bool isFullWidth;
  final double height;
  final double bevelHeight;
  final double borderRadius;

  @override
  State<PicoButton> createState() => _PicoButtonState();
}

class _PicoButtonState extends State<PicoButton> {
  bool _isPressed = false;

  Color get _surfaceColor {
    switch (widget.variant) {
      case PicoButtonVariant.primary:
        return PicoColors.primary;
      case PicoButtonVariant.secondary:
        return PicoColors.cardBevel;
      case PicoButtonVariant.gold:
        return PicoColors.gold;
    }
  }

  Color get _bevelColor {
    switch (widget.variant) {
      case PicoButtonVariant.primary:
        return PicoColors.primaryBevel;
      case PicoButtonVariant.secondary:
        return PicoColors.cardBevelDark;
      case PicoButtonVariant.gold:
        return PicoColors.goldBevel;
    }
  }

  Color get _textColor {
    switch (widget.variant) {
      case PicoButtonVariant.primary:
        return PicoColors.textWhite;
      case PicoButtonVariant.secondary:
      case PicoButtonVariant.gold:
        return PicoColors.textPitchInk;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final double currentBevel = _isPressed && isEnabled ? 0.0 : widget.bevelHeight;
    final double translationY = _isPressed && isEnabled ? widget.bevelHeight : 0.0;

    return GestureDetector(
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
        child: Container(
          height: widget.height,
          width: widget.isFullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: isEnabled ? _surfaceColor : _surfaceColor.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              if (currentBevel > 0.0 && isEnabled)
                BoxShadow(
                  color: _bevelColor,
                  offset: Offset(0, currentBevel),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8.0),
              ],
              Flexible(
                child: Text(
                  widget.text,
                  style: PicoTypography.titleCard.copyWith(
                    color: isEnabled ? _textColor : _textColor.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w700,
                    fontSize: 16.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact 3D tactile icon button used for back navigation and quick actions.
class PicoIconButton extends StatefulWidget {
  const PicoIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 42.0,
    this.bevelHeight = 2.5,
    this.borderRadius = 12.0,
    this.backgroundColor = PicoColors.glassSurface,
    this.bevelColor = const Color(0xFF060E0A),
    this.iconColor = PicoColors.textWhite,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double bevelHeight;
  final double borderRadius;
  final Color backgroundColor;
  final Color bevelColor;
  final Color iconColor;

  @override
  State<PicoIconButton> createState() => _PicoIconButtonState();
}

class _PicoIconButtonState extends State<PicoIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final double currentBevel = _isPressed && isEnabled ? 0.0 : widget.bevelHeight;
    final double translationY = _isPressed && isEnabled ? widget.bevelHeight : 0.0;

    return GestureDetector(
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
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: PicoColors.glassBorder, width: 1.0),
          boxShadow: [
            if (currentBevel > 0.0 && isEnabled)
              BoxShadow(
                color: widget.bevelColor,
                offset: Offset(0, currentBevel),
                blurRadius: 0,
                spreadRadius: 0,
              ),
          ],
        ),
        child: Icon(
          widget.icon,
          color: widget.iconColor,
          size: 20.0,
        ),
      ),
    );
  }
}

/// A clean, minimalist text button with tactile opacity feedback.
class PicoTextButton extends StatefulWidget {
  const PicoTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = PicoColors.textWhiteMuted,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color color;

  @override
  State<PicoTextButton> createState() => _PicoTextButtonState();
}

class _PicoTextButtonState extends State<PicoTextButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _isPressed ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            widget.text,
            style: PicoTypography.bodyMdBold.copyWith(color: widget.color),
          ),
        ),
      ),
    );
  }
}
