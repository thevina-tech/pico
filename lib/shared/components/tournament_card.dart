import 'package:flutter/material.dart';
import '../../core/theme/pico_colors.dart';
import '../../core/theme/pico_typography.dart';
import 'pico_button.dart';
import 'pico_chip.dart';

/// The segmented filter tabs (General / Private) from the "Pico — Tournaments" screen.
class TournamentTabs extends StatelessWidget {
  const TournamentTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    this.privateCount = 2,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final int privateCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: PicoColors.darkTray,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 1.0),
      ),
      child: Row(
        children: [
          // Tab 0: General
          Expanded(
            child: _TabButton(
              label: 'General',
              icon: Icons.public_rounded,
              isSelected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 4.0),
          // Tab 1: Private
          Expanded(
            child: _TabButton(
              label: 'Private',
              icon: Icons.lock_rounded,
              badgeCount: privateCount,
              isSelected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 8.5),
        decoration: BoxDecoration(
          color: isSelected ? PicoColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0xFF00522C),
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17.0,
              color: isSelected ? PicoColors.textWhite : PicoColors.textWhiteMuted,
            ),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: PicoTypography.titleCard.copyWith(
                color: isSelected ? PicoColors.textWhite : PicoColors.textWhiteMuted,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
            if (badgeCount != null && badgeCount! > 0) ...[
              const SizedBox(width: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.0),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0x33000000) : const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(999.0),
                ),
                child: Text(
                  '$badgeCount',
                  style: PicoTypography.statCounterSm.copyWith(
                    color: isSelected ? PicoColors.primaryFixed : PicoColors.mintGlow,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The rich translucent tournament card from the "Pico — Tournaments" screen.
///
/// Features a dark glassmorphic container with league header, group icon,
/// mini standing preview (#2 · Only 2 pts behind Marco), and action triggers.
class TournamentCard extends StatelessWidget {
  const TournamentCard({
    super.key,
    required this.title,
    required this.category,
    required this.subtitle,
    required this.currentRank,
    required this.standingNote,
    required this.pointsLabel,
    this.isJoined = true,
    this.icon = Icons.groups_rounded,
    this.onViewStandings,
    this.onSecondaryAction,
    this.secondaryActionText = 'Banter',
  });

  final String title;
  final String category;
  final String subtitle;
  final int currentRank;
  final String standingNote;
  final String pointsLabel;
  final bool isJoined;
  final IconData icon;
  final VoidCallback? onViewStandings;
  final VoidCallback? onSecondaryAction;
  final String secondaryActionText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PicoColors.glassSurface,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: const Color(0x26FFFFFF), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            offset: Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category tag + Joined badge + Group Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0x1AFFFFFF),
                            borderRadius: BorderRadius.circular(999.0),
                            border: Border.all(color: const Color(0x26FFFFFF), width: 1.0),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: PicoTypography.labelPillSm.copyWith(
                              color: PicoColors.textWhite,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isJoined)
                          const PicoChip.status(
                            label: 'JOINED',
                            backgroundColor: Color(0x3300E599),
                            textColor: PicoColors.electricMint,
                            borderColor: Color(0x4D00E599),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      title,
                      style: PicoTypography.headlineMd.copyWith(
                        color: PicoColors.textWhite,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle,
                      style: PicoTypography.bodySm.copyWith(
                        color: PicoColors.textWhiteMuted,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10.0),
              // Group / Trophy Icon Disc
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: const Color(0x26FFFFFF), width: 1.0),
                ),
                child: Icon(icon, color: PicoColors.textWhite, size: 22.0),
              ),
            ],
          ),

          const SizedBox(height: 14.0),

          // Mini Standings Preview Well
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.0),
            decoration: BoxDecoration(
              color: const Color(0x33000000),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0x1AFFFFFF), width: 1.0),
            ),
            child: Row(
              children: [
                // Rank Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(color: const Color(0x33FFFFFF), width: 1.0),
                  ),
                  child: Text(
                    '#$currentRank',
                    style: PicoTypography.statCounterSm.copyWith(
                      color: PicoColors.textWhite,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    standingNote,
                    style: PicoTypography.bodySm.copyWith(
                      color: PicoColors.textWhite,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  pointsLabel,
                  style: PicoTypography.statCounterSm.copyWith(
                    color: PicoColors.mintGlow,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14.0),

          // Action Triggers
          Row(
            children: [
              Expanded(
                child: PicoButton.secondary(
                  text: secondaryActionText,
                  height: 42.0,
                  borderRadius: 12.0,
                  bevelHeight: 3.0,
                  onPressed: onSecondaryAction,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: PicoButton.gold(
                  text: 'View Standings',
                  height: 42.0,
                  borderRadius: 12.0,
                  bevelHeight: 3.0,
                  onPressed: onViewStandings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Configuration data for an item inside a [TournamentDirectoryCard].
class TournamentDirectoryItem {
  const TournamentDirectoryItem({
    required this.title,
    required this.icon,
    this.subtitle,
    this.iconBackgroundColor = const Color(0x33FDDc9B),
    this.iconBorderColor = const Color(0x66FFDFA0),
    this.iconColor = const Color(0xFFFFDFA0),
    this.onTap,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
  final Color iconBackgroundColor;
  final Color iconBorderColor;
  final Color iconColor;
  final VoidCallback? onTap;
}

/// The multi-tournament directory card used for public tournaments,
/// continental cups, and major leagues.
class TournamentDirectoryCard extends StatelessWidget {
  const TournamentDirectoryCard({
    super.key,
    required this.title,
    required this.items,
    this.badgeText = 'EXPLORE',
    this.badgeColor = const Color(0xFFFFDFA0),
    this.badgeBackgroundColor = const Color(0x33E2C384),
    this.badgeBorderColor = const Color(0x4DE2C384),
  });

  final String title;
  final List<TournamentDirectoryItem> items;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBackgroundColor;
  final Color badgeBorderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PicoColors.glassSurface,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: const Color(0x26FFFFFF), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            offset: Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: PicoTypography.titleCard.copyWith(
                    color: PicoColors.textWhite,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
                decoration: BoxDecoration(
                  color: badgeBackgroundColor,
                  borderRadius: BorderRadius.circular(999.0),
                  border: Border.all(color: badgeBorderColor, width: 1.0),
                ),
                child: Text(
                  badgeText.toUpperCase(),
                  style: PicoTypography.labelPillSm.copyWith(
                    color: badgeColor,
                    fontSize: 9.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          const Divider(color: Color(0x1AFFFFFF), height: 1.0),
          const SizedBox(height: 12.0),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8.0),
            _DirectoryItemRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _DirectoryItemRow extends StatelessWidget {
  const _DirectoryItemRow({required this.item});

  final TournamentDirectoryItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0x33000000),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0x1AFFFFFF), width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: item.iconBackgroundColor,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: item.iconBorderColor, width: 1.0),
                ),
                child: Icon(item.icon, size: 20.0, color: item.iconColor),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: PicoTypography.titleCard.copyWith(
                        color: PicoColors.textWhite,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 1.0),
                      Text(
                        item.subtitle!,
                        style: PicoTypography.bodySm.copyWith(
                          color: PicoColors.textWhiteMuted,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18.0,
                color: Color(0xB3A7F3D0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
