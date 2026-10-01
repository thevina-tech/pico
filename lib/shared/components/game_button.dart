import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pico/core/theme/pico_typography.dart';

/// A reusable tactile 3D mobile-game button with physical extrusion bevel,
/// rich solid face coloring, glossy rim highlights, and mechanical press feedback.
class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    this.text = '',
    required this.onPressed,
    this.onLongPress,
    this.child,
    this.faceColor = const Color(0xFFFCCB2B),
    this.extrusionColor = const Color(0xFFB86000),
    this.outlineColor = const Color(0xFFB86600),
    this.glowColor = const Color(0xFFFF9E00),
    this.textColor = Colors.white,
    this.textShadowColor = const Color(0x663D1800),
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 26.0, vertical: 12.5),
    this.borderRadius = 18.0,
    this.outlineWidth = 1.5,
    this.extrusionHeight = 5.5,
    this.pressedExtrusionHeight = 1.5,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w700,
    this.textStyle,
    this.icon,
    this.showHighlights = true,
    this.enabled = true,
  });

  /// Golden/yellow mobile game button preset.
  const GameButton.gold({
    super.key,
    this.text = '',
    required this.onPressed,
    this.onLongPress,
    this.child,
    this.faceColor = const Color(0xFFFCCB2B),
    this.extrusionColor = const Color(0xFFB86000),
    this.outlineColor = const Color(0xFFB86600),
    this.glowColor = const Color(0xFFFF9E00),
    this.textColor = Colors.white,
    this.textShadowColor = const Color(0x663D1800),
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 26.0, vertical: 12.5),
    this.borderRadius = 18.0,
    this.outlineWidth = 1.5,
    this.extrusionHeight = 5.5,
    this.pressedExtrusionHeight = 1.5,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w700,
    this.textStyle,
    this.icon,
    this.showHighlights = true,
    this.enabled = true,
  });

  /// Cream / ivory mobile game button preset (#F9F8F3).
  const GameButton.cream({
    super.key,
    this.text = '',
    required this.onPressed,
    this.onLongPress,
    this.child,
    this.faceColor = const Color(0xFFF9F8F3),
    this.extrusionColor = const Color(0xFFD8D1C3),
    this.outlineColor = const Color(0xFFC7BFB0),
    this.glowColor = const Color(0x22FFFFFF),
    this.textColor = const Color(0xFF13211B),
    this.textShadowColor = Colors.transparent,
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 26.0, vertical: 12.5),
    this.borderRadius = 18.0,
    this.outlineWidth = 1.5,
    this.extrusionHeight = 5.5,
    this.pressedExtrusionHeight = 1.5,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w700,
    this.textStyle,
    this.icon,
    this.showHighlights = true,
    this.enabled = true,
  });

  /// Meadow pitch green mobile game button preset.
  const GameButton.green({
    super.key,
    this.text = '',
    required this.onPressed,
    this.onLongPress,
    this.child,
    this.faceColor = const Color(0xFF2D8B55),
    this.extrusionColor = const Color(0xFF1E603A),
    this.outlineColor = const Color(0xFF174C2E),
    this.glowColor = const Color(0xFF00E599),
    this.textColor = Colors.white,
    this.textShadowColor = const Color(0x660B2416),
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 26.0, vertical: 12.5),
    this.borderRadius = 18.0,
    this.outlineWidth = 1.5,
    this.extrusionHeight = 5.5,
    this.pressedExtrusionHeight = 1.5,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w700,
    this.textStyle,
    this.icon,
    this.showHighlights = true,
    this.enabled = true,
  });

  /// Royal blue mobile game button preset.
  const GameButton.blue({
    super.key,
    this.text = '',
    required this.onPressed,
    this.onLongPress,
    this.child,
    this.faceColor = const Color(0xFF2563EB),
    this.extrusionColor = const Color(0xFF1D4ED8),
    this.outlineColor = const Color(0xFF1E40AF),
    this.glowColor = const Color(0xFF3B82F6),
    this.textColor = Colors.white,
    this.textShadowColor = const Color(0x660F172A),
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 26.0, vertical: 12.5),
    this.borderRadius = 18.0,
    this.outlineWidth = 1.5,
    this.extrusionHeight = 5.5,
    this.pressedExtrusionHeight = 1.5,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w700,
    this.textStyle,
    this.icon,
    this.showHighlights = true,
    this.enabled = true,
  });

  /// Coral red mobile game button preset.
  const GameButton.red({
    super.key,
    this.text = '',
    required this.onPressed,
    this.onLongPress,
    this.child,
    this.faceColor = const Color(0xFFEF4444),
    this.extrusionColor = const Color(0xFFB91C1C),
    this.outlineColor = const Color(0xFF991B1B),
    this.glowColor = const Color(0xFFF87171),
    this.textColor = Colors.white,
    this.textShadowColor = const Color(0x66450A0A),
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 26.0, vertical: 12.5),
    this.borderRadius = 18.0,
    this.outlineWidth = 1.5,
    this.extrusionHeight = 5.5,
    this.pressedExtrusionHeight = 1.5,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w700,
    this.textStyle,
    this.icon,
    this.showHighlights = true,
    this.enabled = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget? child;

  // Colors
  final Color faceColor;
  final Color extrusionColor;
  final Color outlineColor;
  final Color? glowColor;
  final Color textColor;
  final Color? textShadowColor;

  // Dimensions & Layout
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double outlineWidth;
  final double extrusionHeight;
  final double pressedExtrusionHeight;

  // Typography & Content
  final double fontSize;
  final FontWeight fontWeight;
  final TextStyle? textStyle;
  final Widget? icon;

  // Effects & State
  final bool showHighlights;
  final bool enabled;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _isPressed = false;

  bool get _isClickable => widget.enabled && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final double unpressedExtrusion = widget.extrusionHeight;
    final double pressedExtrusion = widget.pressedExtrusionHeight;
    final double currentExtrusion =
        _isPressed && _isClickable ? pressedExtrusion : unpressedExtrusion;
    final double translationY = _isPressed && _isClickable
        ? (unpressedExtrusion - pressedExtrusion)
        : 0.0;

    final outerRadius = widget.borderRadius + 4.0;
    final innerRadius = widget.borderRadius;

    return Listener(
      onPointerDown: (_) {
        if (_isClickable) {
          setState(() => _isPressed = true);
        }
      },
      onPointerUp: (_) {
        if (_isClickable) {
          setState(() => _isPressed = false);
        }
      },
      onPointerCancel: (_) {
        if (_isClickable) {
          setState(() => _isPressed = false);
        }
      },
      child: GestureDetector(
        onTap: () {
          if (_isClickable) {
            HapticFeedback.lightImpact();
            widget.onPressed?.call();
          }
        },
        onLongPress: () {
          if (_isClickable && widget.onLongPress != null) {
            HapticFeedback.mediumImpact();
            widget.onLongPress?.call();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, translationY, 0.0),
          width: widget.width,
          decoration: BoxDecoration(
            // Extruded 3D base layer
            color: _isClickable
                ? widget.extrusionColor
                : widget.extrusionColor.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(outerRadius),
            border: Border.all(
              color: _isClickable
                  ? widget.outlineColor
                  : widget.outlineColor.withValues(alpha: 0.45),
              width: widget.outlineWidth,
            ),
            boxShadow: [
              // Ambient ground drop shadow
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: _isClickable
                      ? (_isPressed ? 0.25 : 0.40)
                      : 0.12,
                ),
                offset: Offset(0, _isPressed && _isClickable ? 3.0 : (_isClickable ? 7.0 : 3.0)),
                blurRadius: _isPressed && _isClickable ? 5.0 : (_isClickable ? 12.0 : 6.0),
              ),
              // Optional ambient color glow (only when active and not pressed)
              if (widget.glowColor != null && _isClickable && !_isPressed)
                BoxShadow(
                  color: widget.glowColor!.withValues(alpha: 0.35),
                  offset: const Offset(0, 4.0),
                  blurRadius: 10.0,
                ),
            ],
          ),
          padding: EdgeInsets.only(bottom: currentExtrusion),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: _isClickable
                  ? widget.faceColor
                  : widget.faceColor.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(innerRadius),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Top glare line flush against the top inner edge
                if (widget.showHighlights)
                  Positioned(
                    top: 0.0,
                    left: innerRadius,
                    right: innerRadius,
                    height: 2.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: _isClickable ? 0.45 : 0.15,
                        ),
                        borderRadius: BorderRadius.circular(999.0),
                      ),
                    ),
                  ),

                // Pill-shaped glare in the absolute top-right corner
                if (widget.showHighlights && _isClickable)
                  Positioned(
                    top: 5.0,
                    right: 12.0,
                    child: Transform.rotate(
                      angle: -0.4,
                      child: Container(
                        width: 13.0,
                        height: 6.0,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(999.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.6),
                              blurRadius: 2.5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Button content (Custom child or Text and optional icon)
                Padding(
                  padding: widget.padding,
                  child: widget.child != null
                      ? SizedBox(
                          width: widget.width != null ? double.infinity : null,
                          child: widget.child,
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                widget.icon!,
                                const SizedBox(width: 8.0),
                              ],
                              Text(
                                widget.text,
                                textAlign: TextAlign.center,
                                style: widget.textStyle ??
                                    TextStyle(
                                      fontFamily: PicoTypography.headlineFontFamily,
                                      color: widget.textColor,
                                      fontWeight: widget.fontWeight,
                                      fontSize: widget.fontSize,
                                      letterSpacing: 0.2,
                                      shadows: _isClickable && widget.textShadowColor != null
                                          ? [
                                              Shadow(
                                                color: widget.textShadowColor!,
                                                offset: const Offset(0, 1.5),
                                                blurRadius: 2.0,
                                              ),
                                            ]
                                          : null,
                                    ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
