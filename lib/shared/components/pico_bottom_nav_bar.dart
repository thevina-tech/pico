import 'package:flutter/material.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/l10n/app_localizations.dart';

/// Navigation destinations in the order specified by the Stitch "Friendly Football World" navbar:
/// 1. Shop (far left)
/// 2. Matches
/// 3. Home (centered)
/// 4. Tournaments
/// 5. Profile (far right)
enum PicoNavDestination { shop, matches, home, tournaments, profile }

/// The docked bottom navigation bar directly matching the Stitch navbar example.
///
/// Features:
/// - 5 destinations: Shop (far left), Matches, Home (center), Tournaments, Profile (far right).
/// - 3D illustrated icons directly from Stitch with tactile state changes.
/// - Tactile Warm Game Gold pill indicator (`#FCCB2B`) beneath the active tab label.
/// - Dark stadium pitch surface with elevated shadow and crisp edge border.
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
    final l10n = AppLocalizations.of(context);

    final List<_NavItemData> navItems = [
      _NavItemData(
        index: 0,
        label: l10n?.navShop ?? 'Shop',
        assetPath: 'assets/images/nav_shop.png',
        fallbackIcon: Icons.storefront_rounded,
        keyName: 'nav_shop',
      ),
      _NavItemData(
        index: 1,
        label: l10n?.navMatches ?? 'Matches',
        assetPath: 'assets/images/nav_matches.png',
        fallbackIcon: Icons.event_note_rounded,
        keyName: 'nav_matches',
      ),
      _NavItemData(
        index: 2,
        label: l10n?.navHome ?? 'Home',
        assetPath: 'assets/images/nav_home.png',
        fallbackIcon: Icons.sports_soccer_rounded,
        keyName: 'nav_home',
      ),
      _NavItemData(
        index: 3,
        label: l10n?.navTournaments ?? 'Tournaments',
        assetPath: 'assets/images/nav_tournaments.png',
        fallbackIcon: Icons.emoji_events_rounded,
        keyName: 'nav_tournaments',
      ),
      _NavItemData(
        index: 4,
        label: l10n?.navProfile ?? 'Profile',
        assetPath: 'assets/images/nav_profile.png',
        fallbackIcon: Icons.person_rounded,
        keyName: 'nav_profile',
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: PicoColors.pitchSurface,
        border: Border(
          top: BorderSide(color: Color(0x1AFFFFFF), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 74.0,
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.map((item) => _buildNavItem(context, item)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, _NavItemData item) {
    final bool isSelected = currentIndex == item.index;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: item.label,
        child: GestureDetector(
          key: ValueKey(item.keyName),
          onTap: () => onTap(item.index),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3D Illustrated Icon with elevation pop
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                transform: Matrix4.translationValues(0.0, isSelected ? -3.0 : 0.0, 0.0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isSelected ? 1.0 : 0.60,
                  child: SizedBox(
                    width: 38.0,
                    height: 38.0,
                    child: Image.asset(
                      item.assetPath,
                      width: 38.0,
                      height: 38.0,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        item.fallbackIcon,
                        size: 28.0,
                        color: isSelected
                            ? PicoColors.textWhite
                            : PicoColors.textTactileMuted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2.0),

              // Tab Label Text
              Text(
                item.label,
                style: PicoTypography.labelPillSm.copyWith(
                  color: isSelected ? PicoColors.textWhite : PicoColors.textTactileMuted,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 10.5,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),

              // Stitch Warm Game Gold Pill Indicator beneath the text
              Container(
                height: 3.5,
                alignment: Alignment.center,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  width: isSelected ? 22.0 : 0.0,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFCCB2B) : Colors.transparent,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.index,
    required this.label,
    required this.assetPath,
    required this.fallbackIcon,
    required this.keyName,
  });

  final int index;
  final String label;
  final String assetPath;
  final IconData fallbackIcon;
  final String keyName;
}
