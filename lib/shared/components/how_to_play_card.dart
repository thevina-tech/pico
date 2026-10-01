import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pico/features/profile/presentation/help_support_screen.dart';
import 'package:pico/shared/components/game_button.dart';
import 'package:pico/shared/components/in_app_web_browser_screen.dart';

/// Reusable tactile "How to Play" card featuring:
/// - #F9F8F3 background container with subtle pitch watermark markings
/// - Side notches resembling a match ticket / VIP pass
/// - Deep meadow green squircle badge containing `assets/images/rules.png`
/// - "MANUAL" pill badge, "How to Play" bold title, and "Official Rules & Scoring ..." subtitle
/// - 2.5D "Read Guide [↗]" GameButton opening the in-app browser
class HowToPlayCard extends StatelessWidget {
  const HowToPlayCard({
    super.key,
    this.margin = const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
  });

  final EdgeInsetsGeometry margin;

  void _openGuide(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const InAppWebBrowserScreen(
          title: 'How to Play',
          url: HelpSupportScreen.howToPlayUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: GestureDetector(
        key: const Key('how_to_play_card'),
        onTap: () => _openGuide(context),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F8F3),
            borderRadius: BorderRadius.circular(22.0),
            border: Border.all(
              color: const Color(0xFFE5DFC9),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFD3CBBB),
                offset: Offset(0, 4.0),
                blurRadius: 0.0,
              ),
              BoxShadow(
                color: Color(0x14000000),
                offset: Offset(0, 4.0),
                blurRadius: 8.0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.5),
            child: Stack(
              children: [
                // Subtle dashed pitch watermark (midfield line + center circle)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PitchWatermarkPainter(),
                  ),
                ),

                // Left ticket notch (semicircle indentation)
                Positioned(
                  left: -8.0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 16.0,
                      height: 16.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3E26),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5DFC9),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // Right ticket notch (semicircle indentation)
                Positioned(
                  right: -8.0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 16.0,
                      height: 16.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3E26),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5DFC9),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // Card Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      // Left: rules.png blended seamlessly with the #F9F8F3 card
                      SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: Center(
                          child: Transform.scale(
                            scale: 1.35,
                            child: Image.asset(
                              'assets/images/rules.png',
                              color: const Color(0xFFF9F8F3),
                              colorBlendMode: BlendMode.modulate,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.menu_book_rounded,
                                color: Color(0xFF144D34),
                                size: 28.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),

                      // Center Column: MANUAL badge + How to Play + Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.5,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFE8DA),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: const Text(
                                    'MANUAL',
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF8A7242),
                                      letterSpacing: 0.8,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                const Flexible(
                                  child: Text(
                                    'How to Play',
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF13211B),
                                      letterSpacing: -0.2,
                                      height: 1.1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            const Text(
                              'Official Rules & Scoring ...',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF55675F),
                                letterSpacing: -0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),

                      // Right Action: 2.5D Gold GameButton "Read Guide [↗]"
                      GameButton(
                        key: const Key('how_to_play_read_guide_button'),
                        faceColor: const Color(0xFFEAB84C),
                        extrusionColor: const Color(0xFFBF8823),
                        outlineColor: const Color(0xFFBF8823),
                        glowColor: const Color(0x33FFE793),
                        borderRadius: 14.0,
                        extrusionHeight: 3.5,
                        pressedExtrusionHeight: 1.0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        onPressed: () => _openGuide(context),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Read Guide',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 13.0,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2A1A02),
                                letterSpacing: 0.1,
                              ),
                            ),
                            SizedBox(width: 4.5),
                            Icon(
                              Icons.open_in_new_rounded,
                              size: 14.0,
                              color: Color(0xFF2A1A02),
                            ),
                          ],
                        ),
                      ),
                    ],
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

/// Custom painter rendering subtle dotted football pitch markings
/// (vertical dashed center line and dashed midfield circle).
class _PitchWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDDD7C8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final centerX = size.width * 0.46;

    // Center vertical dashed line
    const dashHeight = 4.0;
    const dashSpace = 3.5;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(centerX, startY),
        Offset(centerX, math.min(startY + dashHeight, size.height)),
        paint,
      );
      startY += dashHeight + dashSpace;
    }

    // Midfield dashed circle
    final center = Offset(centerX, size.height / 2);
    final radius = size.height * 0.40;
    const dashCount = 28;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        final startAngle = (i * 2 * math.pi) / dashCount;
        final sweepAngle = (2 * math.pi) / (dashCount * 1.5);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
