import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/pico_colors.dart';
import '../../core/theme/pico_typography.dart';

enum PicoButtonVariant { primary, secondary, gold, blue, red, dark }

/// A physical, tactile 3D game button with mechanical extrusion bevel,
/// crisp solid surfaces, clean borders, and physical press feedback
/// matching the Stitch confirmation modal style.
class PicoButton extends StatefulWidget {
  const PicoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = PicoButtonVariant.primary,
    this.icon,
    this.child,
    this.isFullWidth = true,
    this.height = 48.0,
    this.bevelHeight = 4.0,
    this.borderRadius = 16.0,
    this.fontSize,
    this.isLoading = false,
    this.textStyle,
  });

  const PicoButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.child,
    this.isFullWidth = true,
    this.height = 48.0,
    this.bevelHeight = 4.0,
    this.borderRadius = 16.0,
    this.fontSize,
    this.isLoading = false,
    this.textStyle,
  }) : variant = PicoButtonVariant.primary;

  const PicoButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.child,
    this.isFullWidth = true,
    this.height = 48.0,
    this.bevelHeight = 4.0,
    this.borderRadius = 16.0,
    this.fontSize,
    this.isLoading = false,
    this.textStyle,
  }) : variant = PicoButtonVariant.secondary;

  const PicoButton.gold({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.child,
    this.isFullWidth = true,
    this.height = 48.0,
    this.bevelHeight = 4.0,
    this.borderRadius = 16.0,
    this.fontSize,
    this.isLoading = false,
    this.textStyle,
  }) : variant = PicoButtonVariant.gold;

  const PicoButton.blue({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.child,
    this.isFullWidth = true,
    this.height = 48.0,
    this.bevelHeight = 4.0,
    this.borderRadius = 16.0,
    this.fontSize,
    this.isLoading = false,
    this.textStyle,
  }) : variant = PicoButtonVariant.blue;

  const PicoButton.red({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.child,
    this.isFullWidth = true,
    this.height = 48.0,
    this.bevelHeight = 4.0,
    this.borderRadius = 16.0,
    this.fontSize,
    this.isLoading = false,
    this.textStyle,
  }) : variant = PicoButtonVariant.red;

  const PicoButton.dark({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.child,
    this.isFullWidth = true,
    this.height = 48.0,
    this.bevelHeight = 4.0,
    this.borderRadius = 16.0,
    this.fontSize,
    this.isLoading = false,
    this.textStyle,
  }) : variant = PicoButtonVariant.dark;

  final String text;
  final VoidCallback? onPressed;
  final PicoButtonVariant variant;
  final Widget? icon;
  final Widget? child;
  final bool isFullWidth;
  final double height;
  final double bevelHeight;
  final double borderRadius;
  final double? fontSize;
  final bool isLoading;
  final TextStyle? textStyle;

  @override
  State<PicoButton> createState() => _PicoButtonState();
}

class _PicoButtonState extends State<PicoButton> {
  bool _isPressed = false;

  _ButtonColorTokens _getTokens(PicoButtonVariant variant) {
    switch (variant) {
      case PicoButtonVariant.primary:
        return const _ButtonColorTokens(
          backgroundColor: Color(0xFF16A34A),
          bevelColor: Color(0xFF14532D),
          shadowColor: Color(0xFF16A34A),
          textColor: Colors.white,
          borderColor: Color(0x4DFFFFFF),
        );
      case PicoButtonVariant.gold:
        return const _ButtonColorTokens(
          backgroundColor: Color(0xFFFFD41D),
          bevelColor: Color(0xFF9E6500),
          shadowColor: Color(0x33FFD41D),
          textColor: Color(0xFF261700),
          borderColor: Color(0xFFFFF7C2),
        );
      case PicoButtonVariant.secondary:
        return const _ButtonColorTokens(
          backgroundColor: PicoColors.cardFace,
          bevelColor: Color(0xFFD8D1C3),
          shadowColor: Color(0x20000000),
          textColor: Color(0xFF13211B),
          borderColor: Color(0xFFECE7DC),
        );
      case PicoButtonVariant.blue:
        return const _ButtonColorTokens(
          backgroundColor: Color(0xFF0085FF),
          bevelColor: Color(0xFF004BA3),
          shadowColor: Color(0xFF0085FF),
          textColor: Colors.white,
          borderColor: Color(0x4DFFFFFF),
        );
      case PicoButtonVariant.red:
        return const _ButtonColorTokens(
          backgroundColor: Color(0xFFE0112B),
          bevelColor: Color(0xFF9F071A),
          shadowColor: Color(0xFFE0112B),
          textColor: Colors.white,
          borderColor: Color(0x4DFFFFFF),
        );
      case PicoButtonVariant.dark:
        return const _ButtonColorTokens(
          backgroundColor: Color(0xFF162A1F),
          bevelColor: Color(0xFF08120C),
          shadowColor: Color(0x40000000),
          textColor: Colors.white,
          borderColor: Color(0x26FFFFFF),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;
    final tokens = _getTokens(widget.variant);
    final double currentBevel = _isPressed && isEnabled ? widget.bevelHeight * 0.35 : widget.bevelHeight;
    final double translationY = _isPressed && isEnabled ? widget.bevelHeight * 0.65 : 0.0;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: widget.text,
      child: GestureDetector(
        onTapDown: isEnabled
            ? (_) {
                HapticFeedback.lightImpact();
                setState(() => _isPressed = true);
              }
            : null,
        onTapUp: isEnabled
            ? (_) {
                setState(() => _isPressed = false);
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(
            top: translationY,
            bottom: isEnabled ? (widget.bevelHeight - translationY) : 0.0,
          ),
          child: Container(
            height: widget.height,
            width: widget.isFullWidth ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            decoration: BoxDecoration(
              color: isEnabled
                  ? tokens.backgroundColor
                  : tokens.backgroundColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: isEnabled
                    ? tokens.borderColor
                    : tokens.borderColor.withValues(alpha: 0.2),
                width: 1.0,
              ),
              boxShadow: [
                if (currentBevel > 0.0 && isEnabled) ...[
                  // Solid 3D Bevel Lip
                  BoxShadow(
                    color: tokens.bevelColor,
                    offset: Offset(0, currentBevel),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                  // Ambient soft glow / drop shadow
                  BoxShadow(
                    color: tokens.shadowColor.withValues(alpha: _isPressed ? 0.20 : 0.35),
                    offset: Offset(0, _isPressed ? 2.5 : currentBevel + 2.0),
                    blurRadius: _isPressed ? 4.0 : 12.0,
                    spreadRadius: 0,
                  ),
                ],
              ],
            ),
            alignment: Alignment.center,
            child: widget.isLoading
                ? SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(tokens.textColor),
                    ),
                  )
                : (widget.child ??
                    Row(
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
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: widget.textStyle ??
                                TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: widget.fontSize ?? 15.0,
                                  fontWeight: FontWeight.w800,
                                  color: isEnabled
                                      ? tokens.textColor
                                      : tokens.textColor.withValues(alpha: 0.5),
                                  letterSpacing: 0.2,
                                ),
                          ),
                        ),
                      ],
                    )),
          ),
        ),
      ),
    );
  }
}

class _ButtonColorTokens {
  const _ButtonColorTokens({
    required this.backgroundColor,
    required this.bevelColor,
    required this.shadowColor,
    required this.textColor,
    required this.borderColor,
  });

  final Color backgroundColor;
  final Color bevelColor;
  final Color shadowColor;
  final Color textColor;
  final Color borderColor;
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
