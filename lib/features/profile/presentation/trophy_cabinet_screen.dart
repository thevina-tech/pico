import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/game_button.dart';
import 'package:pico/shared/components/pico_app_bar.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';

/// Trophy Cabinet feature teaser screen.
///
/// Displays a full-screen blurred preview of the trophy cabinet asset
/// with a centered disabled "Coming Soon!" GameButton and standard back navigation.
class TrophyCabinetScreen extends StatelessWidget {
  const TrophyCabinetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n?.trophyCabinet ?? 'Trophy Cabinet';
    final comingSoon = l10n?.comingSoon ?? 'Coming Soon!';

    return PicoPitchBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PicoAppBar(
          title: title,
          isTransparent: true,
          showBackButton: true,
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Base Layer: Center the assets/images/cabinet.png image on the screen
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Image.asset(
                  'assets/images/cabinet.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Blur Layer: Apply BackdropFilter with frosted glass blur over the image
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.20),
                  ),
                ),
              ),
            ),

            // Overlay Layer: Inactive/disabled GameButton centered on top of blur
            Center(
              child: GameButton.gold(
                key: const Key('trophy_cabinet_coming_soon_button'),
                text: comingSoon,
                textColor: const Color(0xFF3D1800),
                textShadowColor: Colors.transparent,
                onPressed: null,
                width: 220.0,
                height: 54.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
