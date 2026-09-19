import 'package:flutter/material.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/shared/components/pico_companion.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';

/// The official Profile screen displaying user stats, streak, level, and trophies.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PicoColors.pitchBackground,
      body: PicoPitchBackground(
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440.0),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                children: [
                  // Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: PicoColors.pitchSurfaceElevated,
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        const Center(child: PicoCompanion.avatar(size: 64.0)),
                        const SizedBox(height: 14.0),
                        Text(
                          'Alex Pereira',
                          style: PicoTypography.headlineLgMobile.copyWith(
                            color: PicoColors.textWhite,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Level 7 Football Predictor',
                          style: PicoTypography.bodySm.copyWith(
                            color: PicoColors.primaryFixed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem('720', 'XP Pts', PicoColors.electricMint),
                            Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.1)),
                            _buildStatItem('4 🔥', 'Streak', const Color(0xFFEF4444)),
                            Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.1)),
                            _buildStatItem('83%', 'Accuracy', PicoColors.gold),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Trophies / Achievements Section
                  Text(
                    'Trophies & Badges',
                    style: PicoTypography.headlineMd.copyWith(
                      color: PicoColors.textWhite,
                      fontWeight: FontWeight.w800,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  _buildAchievementTile(
                    icon: Icons.military_tech_rounded,
                    title: 'Hat-Trick Predictor',
                    subtitle: 'Predicted 3 exact scores in a single matchday',
                    badgeColor: PicoColors.gold,
                  ),
                  const SizedBox(height: 10.0),
                  _buildAchievementTile(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Streak Master',
                    subtitle: 'Maintained a 5-day prediction streak',
                    badgeColor: const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: PicoTypography.headlineMd.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 18.0,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          label,
          style: PicoTypography.bodySm.copyWith(
            color: PicoColors.textWhiteMuted,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: PicoColors.cardFace,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: PicoColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, color: badgeColor, size: 24.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PicoTypography.headlineMd.copyWith(
                    color: PicoColors.textPitchInk,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: PicoTypography.bodySm.copyWith(
                    color: PicoColors.textTactileMuted,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
