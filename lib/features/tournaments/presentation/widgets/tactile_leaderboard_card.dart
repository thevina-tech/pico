import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/features/profile/domain/division.dart';
import 'package:pico/l10n/app_localizations.dart';

/// 2.5D Tactile Leaderboard Card used across all tournament and league leaderboards.
///
/// Styled after "Pico — 2.5D Premier League Leaderboard" with reduced height for
/// high-density, sleek information display. Features embossed metallic medals, tactile bevel
/// drop shadows, division badges, clear Pico Points, and crisp offline monogram game icons.
class TactileLeaderboardCard extends StatelessWidget {
  const TactileLeaderboardCard({
    super.key,
    required this.rank,
    required this.username,
    this.avatarUrl,
    required this.picoPoints,
    this.isCurrentUser = false,
    this.isOwner = false,
    this.isMemberAdmin = false,
    this.trailing,
    this.onTap,
  });

  final int rank;
  final String? username;
  final String? avatarUrl;
  final int picoPoints;
  final bool isCurrentUser;
  final bool isOwner;
  final bool isMemberAdmin;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final division = DivisionTier.fromPoints(picoPoints);

    if (rank == 1) {
      return _buildGoldCard(context, division, l10n);
    } else if (rank == 2) {
      return _buildSilverCard(context, division, l10n);
    } else if (rank == 3) {
      return _buildBronzeCard(context, division, l10n);
    } else {
      return _buildEmeraldCard(context, division, l10n);
    }
  }

  // ==========================================
  // RANK 1: 2.5D GOLD TACTILE CARD (REDUCED HEIGHT)
  // ==========================================
  Widget _buildGoldCard(BuildContext context, DivisionTier division, AppLocalizations? l10n) {
    final divisionTitle = l10n != null ? division.localizedTitle(l10n) : division.defaultTitle;
    final pointsLabel = l10n?.picoPointsLabel ?? 'Pico Points';
    final creatorLabel = l10n?.creatorBadge ?? 'CREATOR';

    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFDE68A), // Amber 200 sheen
            Color(0xFFF59E0B), // Amber 500 gold
          ],
        ),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: const Color(0xFFFCD34D),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFC98B00), // Tactile 3D bottom bevel
            offset: Offset(0, 2.5),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Color(0x25000000),
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              children: [
                // 2.5D Embossed Gold Medal #1
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(9.0),
                    border: Border.all(color: const Color(0xFFFFFBEB), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFB45309),
                        offset: Offset(0, 1.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '1',
                    style: TextStyle(
                      color: Color(0xFF451A03),
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      fontSize: 16.0,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),

                // Leaderboard Monogram Icon (No network avatar needed)
                _buildLeaderboardIcon(
                  size: 32.0,
                  radius: 10.0,
                  borderColor: Colors.white.withValues(alpha: 0.8),
                  bgColor: const Color(0xFF064E3B),
                  textColor: const Color(0xFFFDE68A),
                ),
                const SizedBox(width: 8.0),

                // User details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              username ?? 'Player',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (isOwner) ...[
                            const SizedBox(width: 4.0),
                            _buildTagBadge(
                              label: creatorLabel,
                              bgColor: const Color(0xFF78350F),
                              textColor: const Color(0xFFFEF3C7),
                            ),
                          ] else if (isMemberAdmin) ...[
                            const SizedBox(width: 4.0),
                            _buildTagBadge(
                              label: 'ADMIN',
                              bgColor: const Color(0xFF78350F),
                              textColor: const Color(0xFFFEF3C7),
                            ),
                          ],
                          if (isCurrentUser) ...[
                            const SizedBox(width: 4.0),
                            _buildTagBadge(
                              label: 'YOU',
                              bgColor: const Color(0xFF78350F),
                              textColor: const Color(0xFFFEF3C7),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1.5),
                      // Division Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 8.5)),
                            const SizedBox(width: 3.0),
                            Flexible(
                              child: Text(
                                divisionTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF78350F),
                                  fontFamily: 'Rubik',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Score + Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NumberFormat.decimalPattern().format(picoPoints),
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w900,
                        fontSize: 15.0,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      pointsLabel,
                      style: TextStyle(
                        color: const Color(0xFF78350F).withValues(alpha: 0.85),
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w700,
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 4.0),
                  trailing!,
                ] else if (onTap != null) ...[
                  const SizedBox(width: 4.0),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: const Color(0xFF78350F).withValues(alpha: 0.5),
                    size: 16.0,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // RANK 2: 2.5D SILVER TACTILE CARD (REDUCED HEIGHT)
  // ==========================================
  Widget _buildSilverCard(BuildContext context, DivisionTier division, AppLocalizations? l10n) {
    final divisionTitle = l10n != null ? division.localizedTitle(l10n) : division.defaultTitle;
    final pointsLabel = l10n?.picoPointsLabel ?? 'Pico Points';
    final creatorLabel = l10n?.creatorBadge ?? 'CREATOR';

    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFCBD5E1),
          ],
        ),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF8C9FB5), // Tactile 3D bottom bevel
            offset: Offset(0, 2.5),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Color(0x20000000),
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              children: [
                // 2.5D Embossed Silver Medal #2
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF8FAFC), Color(0xFF94A3B8)],
                    ),
                    borderRadius: BorderRadius.circular(9.0),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF64748B),
                        offset: Offset(0, 1.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      fontSize: 16.0,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),

                // Leaderboard Monogram Icon (No network avatar needed)
                _buildLeaderboardIcon(
                  size: 32.0,
                  radius: 10.0,
                  borderColor: Colors.white.withValues(alpha: 0.8),
                  bgColor: const Color(0xFF0F3320),
                  textColor: const Color(0xFFF8FAFC),
                ),
                const SizedBox(width: 8.0),

                // User details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              username ?? 'Player',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (isOwner) ...[
                            const SizedBox(width: 4.0),
                            _buildTagBadge(
                              label: creatorLabel,
                              bgColor: const Color(0xFF334155),
                              textColor: const Color(0xFFF8FAFC),
                            ),
                          ] else if (isMemberAdmin) ...[
                            const SizedBox(width: 4.0),
                            _buildTagBadge(
                              label: 'ADMIN',
                              bgColor: const Color(0xFF334155),
                              textColor: const Color(0xFFF8FAFC),
                            ),
                          ],
                          if (isCurrentUser) ...[
                            const SizedBox(width: 4.0),
                            _buildTagBadge(
                              label: 'YOU',
                              bgColor: const Color(0xFF334155),
                              textColor: const Color(0xFFF8FAFC),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1.5),
                      // Division Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: const Color(0xFF94A3B8).withValues(alpha: 0.6),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 8.5)),
                            const SizedBox(width: 3.0),
                            Flexible(
                              child: Text(
                                divisionTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF334155),
                                  fontFamily: 'Rubik',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Score + Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NumberFormat.decimalPattern().format(picoPoints),
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w900,
                        fontSize: 15.0,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      pointsLabel,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w700,
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 4.0),
                  trailing!,
                ] else if (onTap != null) ...[
                  const SizedBox(width: 4.0),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: const Color(0xFF64748B).withValues(alpha: 0.5),
                    size: 16.0,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // RANK 3: 2.5D BRONZE TACTILE CARD (REDUCED HEIGHT)
  // ==========================================
  Widget _buildBronzeCard(BuildContext context, DivisionTier division, AppLocalizations? l10n) {
    final divisionTitle = l10n != null ? division.localizedTitle(l10n) : division.defaultTitle;
    final pointsLabel = l10n?.picoPointsLabel ?? 'Pico Points';
    final creatorLabel = l10n?.creatorBadge ?? 'CREATOR';

    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFED7AA), // Orange 200
            Color(0xFFFB923C), // Orange 400 bronze
          ],
        ),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: const Color(0xFFFDBA74),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFAF5F24), // Tactile 3D bottom bevel
            offset: Offset(0, 2.5),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Color(0x20000000),
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              children: [
                // 2.5D Embossed Bronze Medal #3
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFFEDD5), Color(0xFFEA580C)],
                    ),
                    borderRadius: BorderRadius.circular(9.0),
                    border: Border.all(color: const Color(0xFFFFEDD5), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF9A3412),
                        offset: Offset(0, 1.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Color(0xFF431407),
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      fontSize: 16.0,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),

                // Leaderboard Monogram Icon (No network avatar needed)
                _buildLeaderboardIcon(
                  size: 32.0,
                  radius: 10.0,
                  borderColor: Colors.white.withValues(alpha: 0.8),
                  bgColor: const Color(0xFF0F3320),
                  textColor: const Color(0xFFFFEDD5),
                ),
                const SizedBox(width: 8.0),

                // User details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              username ?? 'Player',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (isOwner) ...[
                            const SizedBox(width: 4.0),
                            _buildTagBadge(
                              label: creatorLabel,
                              bgColor: const Color(0xFF7C2D12),
                              textColor: const Color(0xFFFFEDD5),
                            ),
                          ] else if (isMemberAdmin) ...[
                            const SizedBox(width: 4.0),
                            _buildTagBadge(
                              label: 'ADMIN',
                              bgColor: const Color(0xFF7C2D12),
                              textColor: const Color(0xFFFFEDD5),
                            ),
                          ],
                          if (isCurrentUser) ...[
                            const SizedBox(width: 4.0),
                            _buildTagBadge(
                              label: 'YOU',
                              bgColor: const Color(0xFF7C2D12),
                              textColor: const Color(0xFFFFEDD5),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1.5),
                      // Division Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: const Color(0xFFFB923C).withValues(alpha: 0.6),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 8.5)),
                            const SizedBox(width: 3.0),
                            Flexible(
                              child: Text(
                                divisionTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF7C2D12),
                                  fontFamily: 'Rubik',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Score + Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NumberFormat.decimalPattern().format(picoPoints),
                      style: const TextStyle(
                        color: Color(0xFF431407),
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w900,
                        fontSize: 15.0,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      pointsLabel,
                      style: TextStyle(
                        color: const Color(0xFF7C2D12).withValues(alpha: 0.85),
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w700,
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 4.0),
                  trailing!,
                ] else if (onTap != null) ...[
                  const SizedBox(width: 4.0),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: const Color(0xFF7C2D12).withValues(alpha: 0.5),
                    size: 16.0,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // RANKS 4+: 2.5D EMERALD TACTILE CARD (REDUCED HEIGHT)
  // ==========================================
  Widget _buildEmeraldCard(BuildContext context, DivisionTier division, AppLocalizations? l10n) {
    final divisionTitle = l10n != null ? division.localizedTitle(l10n) : division.defaultTitle;
    final pointsLabel = l10n?.picoPointsLabel ?? 'Pico Points';
    final creatorLabel = l10n?.creatorBadge ?? 'CREATOR';

    return Container(
      margin: const EdgeInsets.only(bottom: 4.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isCurrentUser
              ? const [Color(0xFF144D2E), Color(0xFF0C3820)]
              : const [Color(0xFF105934), Color(0xFF0A3C23)],
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isCurrentUser ? PicoColors.gold : const Color(0x3334D399),
          width: isCurrentUser ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF062B18), // Tactile 3D bottom bevel
            offset: Offset(0, 2.0),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Color(0x25000000),
            offset: Offset(0, 3),
            blurRadius: 5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5),
            child: Row(
              children: [
                // Rank Number
                SizedBox(
                  width: 20.0,
                  child: Text(
                    '$rank',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const SizedBox(width: 6.0),

                // Leaderboard Monogram Icon (No network avatar needed)
                _buildLeaderboardIcon(
                  size: 30.0,
                  radius: 9.0,
                  borderColor: const Color(0x6634D399),
                  bgColor: const Color(0xFF064E3B),
                  textColor: Colors.white,
                ),
                const SizedBox(width: 8.0),

                // User details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              username ?? 'Player',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w800,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                          if (isOwner) ...[
                            const SizedBox(width: 4.0),
                            _buildTagBadge(
                              label: creatorLabel,
                              bgColor: PicoColors.gold.withValues(alpha: 0.25),
                              textColor: PicoColors.gold,
                            ),
                          ] else if (isMemberAdmin) ...[
                            const SizedBox(width: 4.0),
                            _buildTagBadge(
                              label: 'ADMIN',
                              bgColor: PicoColors.gold.withValues(alpha: 0.25),
                              textColor: PicoColors.gold,
                            ),
                          ],
                          if (isCurrentUser) ...[
                            const SizedBox(width: 4.0),
                            _buildTagBadge(
                              label: 'YOU',
                              bgColor: PicoColors.primary,
                              textColor: PicoColors.pitchBackground,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1.5),
                      // Division Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(
                            color: division.accentColor.withValues(alpha: 0.4),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 4.0,
                              height: 4.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: division.accentColor,
                              ),
                            ),
                            const SizedBox(width: 3.0),
                            Flexible(
                              child: Text(
                                divisionTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: division.accentColor,
                                  fontFamily: 'Rubik',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 8.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Score + Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NumberFormat.decimalPattern().format(picoPoints),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w900,
                        fontSize: 14.0,
                      ),
                    ),
                    Text(
                      pointsLabel,
                      style: TextStyle(
                        color: const Color(0xFF6EE7B7).withValues(alpha: 0.8),
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w600,
                        fontSize: 8.0,
                      ),
                    ),
                  ],
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 4.0),
                  trailing!,
                ] else if (onTap != null) ...[
                  const SizedBox(width: 4.0),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0x8034D399),
                    size: 16.0,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SHARED SUB-COMPONENTS
  // ==========================================
  Widget _buildLeaderboardIcon({
    required double size,
    required double radius,
    required Color borderColor,
    required Color bgColor,
    required Color textColor,
  }) {
    final initial = (username != null && username!.isNotEmpty)
        ? username!.characters.first.toUpperCase()
        : 'P';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: bgColor,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20000000),
            offset: Offset(0, 1.5),
            blurRadius: 3,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Rubik',
          fontWeight: FontWeight.w900,
          fontSize: size * 0.42,
        ),
      ),
    );
  }

  Widget _buildTagBadge({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Rubik',
          fontWeight: FontWeight.w900,
          fontSize: 7.5,
        ),
      ),
    );
  }
}
