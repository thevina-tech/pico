import 'package:flutter/material.dart';
import '../../core/theme/pico_colors.dart';

/// Option B: Deep tactical football pitch background with atmospheric radial glows
/// and tactical pitch geometry contour lines (center circle, halfway line, penalty box).
class PicoPitchBackground extends StatelessWidget {
  const PicoPitchBackground({
    super.key,
    required this.child,
    this.showContours = true,
  });

  final Widget child;
  final bool showContours;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PicoColors.pitchBackground,
        gradient: RadialGradient(
          center: Alignment(0.0, -0.7),
          radius: 1.1,
          colors: [
            Color(0x382D8B55), // Ambient pitch turf glow
            PicoColors.pitchGradientTop,
            PicoColors.pitchBackground,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showContours)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _PitchGeometryPainter(),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _PitchGeometryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final halfwayY = size.height * 0.28;

    // 1. Halfway Line
    canvas.drawLine(
      Offset(0, halfwayY),
      Offset(size.width, halfwayY),
      linePaint,
    );

    // 2. Center Kick-off Point
    canvas.drawCircle(Offset(centerX, halfwayY), 3.5, dotPaint);

    // 3. Center Circle (dashed style effect)
    const circleRadius = 110.0;
    _drawDashedCircle(canvas, Offset(centerX, halfwayY), circleRadius, linePaint);

    // 4. Penalty Area Box (Top)
    final penaltyWidth = (size.width * 0.72).clamp(240.0, 320.0);
    const penaltyHeight = 85.0;
    final penaltyRect = Rect.fromLTWH(
      centerX - (penaltyWidth / 2),
      0,
      penaltyWidth,
      penaltyHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(penaltyRect, const Radius.circular(8.0)),
      linePaint,
    );

    // 5. Goal Area Box (Top)
    const goalWidth = 140.0;
    const goalHeight = 35.0;
    final goalRect = Rect.fromLTWH(
      centerX - (goalWidth / 2),
      0,
      goalWidth,
      goalHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(goalRect, const Radius.circular(4.0)),
      linePaint,
    );
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const dashCount = 36;
    const sweep = (3.141592653589793 * 2) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          i * sweep,
          sweep * 0.7,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
