import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/pico_colors.dart';

/// Full-bleed sunny stadium pitch & sky background.
///
/// Features:
/// - Sunny blue sky and fluffy cartoon clouds positioned at the topmost part of the UI.
/// - Subtle blur (sigma 2.0) with slight scaling to prevent edge bleed.
/// - Soft darkening overlay to tame bright saturation.
/// - Contrast vignette over the grass for console-grade legibility.
class PicoPitchBackground extends StatelessWidget {
  const PicoPitchBackground({
    super.key,
    required this.child,
    this.imageAsset = 'assets/images/home_pitch_background.png',
    this.blurSigma = 2.0,
    this.showVignette = true,
    this.showContours = false,
  });

  final Widget child;
  final String imageAsset;
  final double blurSigma;
  final bool showVignette;
  final bool showContours;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Full-Bleed Sunny Pitch Background (Clouds & sky at top, subtly softened)
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
            ),
            child: Transform.scale(
              scale: blurSigma > 0 ? 1.02 : 1.0,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: PicoColors.pitchBackground,
                ),
              ),
            ),
          ),
        ),

        // 2. Soft darkening overlay to tone down bright colors
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: Colors.black.withValues(alpha: 0.18),
            ),
          ),
        ),

        // 3. Subtle pitch contrast vignette over the middle/bottom grass
        if (showVignette)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.20, 0.50, 1.0],
                    colors: [
                      Colors.transparent, // Sky & clouds remain clean behind Top Bar
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.12),
                      Colors.black.withValues(alpha: 0.28),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 4. Content Child (e.g. Scaffold or inner layout)
        child,
      ],
    );
  }
}
