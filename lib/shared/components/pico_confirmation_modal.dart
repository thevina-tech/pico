import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pico/shared/components/pico_button.dart';

/// Style variants for 3D tactile buttons inside [PicoConfirmationModal].
enum PicoDialogButtonStyle {
  red,
  blue,
  green,
  gold,
  neutral,
}

/// A highly tactile, Clash/Stitch-style confirmation modal faithfully reproducing
/// Stitch screen `4479dd85c5b64355bf6e946dede51811` ("Pico — Exit Confirmation Modal").
///
/// Features:
/// - Crisp white card with 32px rounded corners and subtle faint football watermark.
/// - Prominent green "pico" brand wordmark with stylized football 'o' target icon.
/// - Bold [Rubik] headline and [Plus Jakarta Sans] description.
/// - Two side-by-side chunky 3D tactile action buttons with physical press-down feedback.
class PicoConfirmationModal extends StatelessWidget {
  const PicoConfirmationModal({
    super.key,
    this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmStyle = PicoDialogButtonStyle.blue,
    this.cancelStyle = PicoDialogButtonStyle.red,
    this.customIcon,
    this.showLogo = false,
    this.showWatermark = false,
    this.confirmKey,
    this.cancelKey,
    this.onConfirm,
    this.onCancel,
  });

  final String? title;
  final String message;
  final String confirmText;
  final String cancelText;
  final PicoDialogButtonStyle confirmStyle;
  final PicoDialogButtonStyle cancelStyle;
  final Widget? customIcon;
  final bool showLogo;
  final bool showWatermark;
  final Key? confirmKey;
  final Key? cancelKey;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 348.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x99000000),
                  offset: Offset(0, 20.0),
                  blurRadius: 50.0,
                ),
                BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(0, 4.0),
                  blurRadius: 12.0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32.0),
              child: Stack(
                children: [
                  // Subtle Faint Football Watermark Backdrop
                  if (showWatermark) ...[
                    Positioned(
                      top: -24.0,
                      left: -24.0,
                      child: CustomPaint(
                        size: const Size(120.0, 120.0),
                        painter: _SoccerBallWatermarkPainter(),
                      ),
                    ),
                    Positioned(
                      bottom: -24.0,
                      right: -24.0,
                      child: CustomPaint(
                        size: const Size(120.0, 120.0),
                        painter: _SoccerBallWatermarkPainter(),
                      ),
                    ),
                  ],

                  // Main Content
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      24.0,
                      customIcon != null ? 28.0 : 26.0,
                      24.0,
                      24.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Custom Icon (if provided)
                        if (customIcon != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14.0),
                            child: customIcon!,
                          ),

                        // Title
                        if (title != null && title!.isNotEmpty) ...[
                          Text(
                            title!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 21.0,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              letterSpacing: -0.3,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                        ],

                        // Subtitle / Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                              height: 1.45,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Action Buttons Row (Side by side)
                        Row(
                          children: [
                            // Left / Cancel / Secondary Button
                            Expanded(
                              child: _TactileModalButton(
                                key: cancelKey,
                                label: cancelText,
                                style: cancelStyle,
                                onPressed: () {
                                  if (onCancel != null) {
                                    onCancel!();
                                  } else {
                                    Navigator.of(context).pop(false);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            // Right / Confirm / Primary Button
                            Expanded(
                              child: _TactileModalButton(
                                key: confirmKey,
                                label: confirmText,
                                style: confirmStyle,
                                onPressed: () {
                                  if (onConfirm != null) {
                                    onConfirm!();
                                  } else {
                                    Navigator.of(context).pop(true);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
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
}

/// Helper function to display the [PicoConfirmationModal] with convenient defaults.
Future<bool?> showPicoConfirmationModal({
  required BuildContext context,
  String? title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  PicoDialogButtonStyle confirmStyle = PicoDialogButtonStyle.blue,
  PicoDialogButtonStyle cancelStyle = PicoDialogButtonStyle.red,
  Widget? customIcon,
  bool showLogo = false,
  bool showWatermark = false,
  Key? confirmKey,
  Key? cancelKey,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (dialogCtx) => PicoConfirmationModal(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmStyle: confirmStyle,
      cancelStyle: cancelStyle,
      customIcon: customIcon,
      showLogo: showLogo,
      showWatermark: showWatermark,
      confirmKey: confirmKey,
      cancelKey: cancelKey,
      onConfirm: () => Navigator.of(dialogCtx).pop(true),
      onCancel: () => Navigator.of(dialogCtx).pop(false),
    ),
  );
}


/// 3D tactile button with mechanical press feedback and thick bottom bevel.
class _TactileModalButton extends StatelessWidget {
  const _TactileModalButton({
    super.key,
    required this.label,
    required this.style,
    required this.onPressed,
  });

  final String label;
  final PicoDialogButtonStyle style;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    PicoButtonVariant variant;
    switch (style) {
      case PicoDialogButtonStyle.red:
        variant = PicoButtonVariant.red;
        break;
      case PicoDialogButtonStyle.blue:
        variant = PicoButtonVariant.blue;
        break;
      case PicoDialogButtonStyle.green:
        variant = PicoButtonVariant.primary;
        break;
      case PicoDialogButtonStyle.gold:
        variant = PicoButtonVariant.gold;
        break;
      case PicoDialogButtonStyle.neutral:
        variant = PicoButtonVariant.secondary;
        break;
    }

    return PicoButton(
      text: label,
      variant: variant,
      height: 48.0,
      borderRadius: 16.0,
      onPressed: onPressed,
    );
  }
}

/// Faint soccer ball watermark pattern.
class _SoccerBallWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.2;
    canvas.drawCircle(center, radius, paint);

    // Inner pentagon
    final pentagonPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 18) * math.pi / 180;
      final x = center.dx + (radius * 0.38) * math.cos(angle);
      final y = center.dy + (radius * 0.38) * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, pentagonPaint);
    canvas.drawPath(path, paint);

    // Radiating seam lines
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 18) * math.pi / 180;
      final x1 = center.dx + (radius * 0.38) * math.cos(angle);
      final y1 = center.dy + (radius * 0.38) * math.sin(angle);
      final x2 = center.dx + radius * math.cos(angle);
      final y2 = center.dy + radius * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
