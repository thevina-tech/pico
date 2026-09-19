import 'package:flutter/material.dart';
import '../../core/theme/pico_colors.dart';
import '../../core/theme/pico_typography.dart';

/// The floating translucent top app bar displaying user profile, level, and XP progress.
class PicoTopAppBar extends StatelessWidget {
  const PicoTopAppBar({
    super.key,
    required this.playerName,
    required this.level,
    required this.xpProgress,
    this.xpLabel = '720/1k',
    this.avatarUrl,
    this.streakCount,
    this.trailing,
    this.onProfileTap,
  });

  final String playerName;
  final int level;

  /// Progress from 0.0 to 1.0.
  final double xpProgress;

  /// Display text beside the progress bar (e.g. '720/1k').
  final String? xpLabel;
  final String? avatarUrl;
  final int? streakCount;
  final Widget? trailing;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: PicoColors.glassSurface,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: PicoColors.glassBorder, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar + Level Badge Anchor
          GestureDetector(
            onTap: onProfileTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    color: PicoColors.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: PicoColors.primaryFixedDim,
                      width: 2.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF00522C),
                        offset: Offset(0, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: avatarUrl != null
                        ? Image.network(
                            avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildAvatarFallback(),
                          )
                        : _buildAvatarFallback(),
                  ),
                ),
                Positioned(
                  bottom: -2.0,
                  right: -3.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: PicoColors.primary,
                      borderRadius: BorderRadius.circular(999.0),
                      border: Border.all(color: PicoColors.primaryFixed, width: 1.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF00210E),
                          offset: Offset(0, 1),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      '$level',
                      style: PicoTypography.labelPillSm.copyWith(
                        color: PicoColors.textWhite,
                        fontWeight: FontWeight.w800,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),

          // Player Name & XP Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      playerName,
                      style: PicoTypography.headlineMd.copyWith(
                        color: PicoColors.textWhite,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      'LVL $level',
                      style: PicoTypography.labelPillSm.copyWith(
                        color: PicoColors.primaryFixedDim,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.0,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.0),
                // XP Progress Bar & Label Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 78.0,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF13231A),
                        borderRadius: BorderRadius.circular(999.0),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: xpProgress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: PicoColors.primaryFixed,
                            borderRadius: BorderRadius.circular(999.0),
                          ),
                        ),
                      ),
                    ),
                    if (xpLabel != null && xpLabel!.isNotEmpty) ...[
                      const SizedBox(width: 8.0),
                      Text(
                        xpLabel!,
                        style: PicoTypography.labelPillSm.copyWith(
                          color: PicoColors.textWhiteMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12.0),

          // Trailing Indicator (Streak count or custom)
          if (trailing != null)
            trailing!
          else if (streakCount != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.5),
              decoration: BoxDecoration(
                color: const Color(0x33000000),
                borderRadius: BorderRadius.circular(999.0),
                border: Border.all(
                  color: PicoColors.gold.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 12.0)),
                  const SizedBox(width: 4.0),
                  Text(
                    '$streakCount',
                    style: PicoTypography.labelPill.copyWith(
                      color: PicoColors.gold,
                      fontWeight: FontWeight.w800,
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

  Widget _buildAvatarFallback() {
    return Image.asset(
      'assets/images/pico_avatar.png',
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Center(
        child: Text(
          playerName.isNotEmpty ? playerName[0].toUpperCase() : 'P',
          style: const TextStyle(
            color: PicoColors.textWhite,
            fontWeight: FontWeight.w800,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
