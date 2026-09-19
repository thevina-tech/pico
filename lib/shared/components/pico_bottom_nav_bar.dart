import 'package:flutter/material.dart';
import '../../core/theme/pico_colors.dart';
import '../../core/theme/pico_typography.dart';

enum PicoNavDestination { home, matches, tournaments, profile }

/// The docked bottom navigation bar directly matching the "Pico — Tournaments" screen.
///
/// Features 4 primary destinations (Home, Matches, Tournaments, Profile) with
/// an elevated tactile 3D pill indicator for the active item.
class PicoBottomNavBar extends StatelessWidget {
  const PicoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PicoColors.pitchSurface,
        border: Border(
          top: BorderSide(color: Color(0x14FFFFFF), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x4D000000),
            offset: Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Home',
                icon: Icons.sports_soccer_rounded,
              ),
              _buildNavItem(
                index: 1,
                label: 'Matches',
                icon: Icons.event_note_rounded,
              ),
              _buildNavItem(
                index: 2,
                label: 'Tournaments',
                icon: Icons.emoji_events_rounded,
              ),
              _buildNavItem(
                index: 3,
                label: 'Profile',
                icon: Icons.person_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0.0, isSelected ? -3.0 : 0.0, 0.0),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14.0 : 10.0,
          vertical: 5.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? PicoColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: PicoColors.primaryBevel,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0x33006A3A),
                    offset: Offset(0, 6),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20.0,
              color: isSelected ? PicoColors.textWhite : PicoColors.textTactileMuted,
            ),
            const SizedBox(height: 2.0),
            Text(
              label,
              style: PicoTypography.labelPillSm.copyWith(
                color: isSelected ? PicoColors.textWhite : PicoColors.textTactileMuted,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 10.0,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
