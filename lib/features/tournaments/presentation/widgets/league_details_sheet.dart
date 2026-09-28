import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/private_league.dart';
import 'package:pico/features/tournaments/domain/private_league_member.dart';
import 'package:pico/shared/components/division_badge.dart';
import 'package:pico/shared/components/pico_confirmation_modal.dart';

/// Modal bottom sheet displaying League details, invite code,
/// live standings leaderboard, admin kick controls, and leave league action.
class LeagueDetailsSheet extends ConsumerStatefulWidget {
  const LeagueDetailsSheet({
    super.key,
    required this.league,
    required this.initialMembers,
  });

  final PrivateLeague league;
  final List<PrivateLeagueMember> initialMembers;

  static Future<void> show(
    BuildContext context, {
    required PrivateLeague league,
    required List<PrivateLeagueMember> initialMembers,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LeagueDetailsSheet(
        league: league,
        initialMembers: initialMembers,
      ),
    );
  }

  @override
  ConsumerState<LeagueDetailsSheet> createState() => _LeagueDetailsSheetState();
}

class _LeagueDetailsSheetState extends ConsumerState<LeagueDetailsSheet> {
  bool _isProcessing = false;
  bool _hasCopiedCode = false;

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(privateLeagueMembersProvider(widget.league.id));
    final members = membersAsync.value ?? widget.initialMembers;

    // Sort members by picoPoints descending
    final sortedMembers = List<PrivateLeagueMember>.from(members)
      ..sort((a, b) => b.picoPoints.compareTo(a.picoPoints));

    final authState = ref.watch(authProvider);
    final currentUserId = authState is PicoAuthAuthenticated ? authState.user?.id : null;
    final isAdmin = currentUserId != null &&
        (widget.league.effectiveAdminId == currentUserId || widget.league.ownerId == currentUserId);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF131E29),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0x3300E676), width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle
            const SizedBox(height: 12.0),
            Center(
              child: Container(
                width: 44.0,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 12.0),

            // Main Scrollable Content
            Flexible(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  // 1. Header (Name, Crest, Description, Admin Badge)
                  _buildHeader(isAdmin),
                  const SizedBox(height: 16.0),

                  // 2. 6-Character Invite Code & Share
                  _buildInviteCodeBox(context),
                  const SizedBox(height: 16.0),

                  // 3. Leave League Action Button
                  _buildLeaveLeagueButton(context, currentUserId, isAdmin),
                  const SizedBox(height: 24.0),

                  // 4. Leaderboard Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LEADERBOARD',
                        style: PicoTypography.labelPill.copyWith(
                          color: PicoColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Members: ${sortedMembers.length}/${widget.league.maxCapacity}',
                        style: PicoTypography.bodySm.copyWith(
                          color: PicoColors.textWhiteMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  // 5. Members List
                  if (sortedMembers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Text(
                          'No members found',
                          style: PicoTypography.bodyMd.copyWith(
                            color: PicoColors.textWhiteMuted,
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(sortedMembers.length, (index) {
                      final member = sortedMembers[index];
                      final isCurrent = currentUserId != null && member.userId == currentUserId;
                      final isMemberAdmin = member.userId == widget.league.effectiveAdminId;

                      return _buildLeaderboardTile(
                        rank: index + 1,
                        member: member,
                        isCurrent: isCurrent,
                        isMemberAdmin: isMemberAdmin,
                        canKick: isAdmin && !isCurrent,
                        onKick: () => _confirmKickMember(context, member),
                      );
                    }),

                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// League Header with crest, title, and description
  Widget _buildHeader(bool isAdmin) {
    final descriptionText = widget.league.description.isNotEmpty
        ? widget.league.description
        : (widget.league.competitionName.isNotEmpty
            ? 'Climb the leaderboards or compete with friends in ${widget.league.competitionName}'
            : 'Climb the leaderboards or compete with friends');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2D3D),
                shape: BoxShape.circle,
                border: Border.all(color: PicoColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: PicoColors.primary,
                size: 24.0,
              ),
            ),
            const SizedBox(width: 10.0),
            Flexible(
              child: Text(
                widget.league.name,
                style: PicoTypography.headlineMd.copyWith(
                  color: PicoColors.textWhite,
                  fontWeight: FontWeight.w800,
                  fontSize: 20.0,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD41D).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFFFFD41D), width: 1.0),
                ),
                child: Text(
                  'ADMIN',
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFFFFD41D),
                    fontWeight: FontWeight.w800,
                    fontSize: 10.0,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6.0),
        Text(
          descriptionText,
          style: PicoTypography.bodySm.copyWith(
            color: PicoColors.textWhiteMuted,
            fontSize: 13.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 6-Character Invite Code Box with copy & share actions
  Widget _buildInviteCodeBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INVITE CODE',
                  style: PicoTypography.labelPillSm.copyWith(
                    color: PicoColors.textWhiteMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.0,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  widget.league.inviteCode,
                  style: PicoTypography.headlineMd.copyWith(
                    color: const Color(0xFFFFD41D),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                    fontSize: 22.0,
                  ),
                ),
              ],
            ),
          ),
          // Copy button
          IconButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: widget.league.inviteCode));
              if (!context.mounted) return;
              setState(() => _hasCopiedCode = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invite code copied to clipboard!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFF1E2D3D),
                ),
              );
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) setState(() => _hasCopiedCode = false);
              });
            },
            icon: Icon(
              _hasCopiedCode ? Icons.check_circle_rounded : Icons.copy_rounded,
              color: _hasCopiedCode ? PicoColors.primary : PicoColors.textWhite,
              size: 20.0,
            ),
            tooltip: 'Copy Invite Code',
          ),
          // Share button
          IconButton(
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  text: 'Join my prediction league "${widget.league.name}" on Pico! Use invite code: ${widget.league.inviteCode}',
                ),
              );
            },
            icon: const Icon(
              Icons.share_rounded,
              color: PicoColors.primary,
              size: 20.0,
            ),
            tooltip: 'Share Invite Code',
          ),
        ],
      ),
    );
  }

  /// Leave League button wired to RPC
  Widget _buildLeaveLeagueButton(BuildContext context, String? currentUserId, bool isAdmin) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isProcessing
            ? null
            : () => _confirmLeaveLeague(context, currentUserId, isAdmin),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0x66EF4444), width: 1.2),
          backgroundColor: const Color(0x1AEF4444),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
        icon: const Icon(
          Icons.logout_rounded,
          color: PicoColors.accentCoral,
          size: 18.0,
        ),
        label: Text(
          'Leave League',
          style: PicoTypography.bodySm.copyWith(
            color: PicoColors.accentCoral,
            fontWeight: FontWeight.w700,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  /// Single Leaderboard Tile
  Widget _buildLeaderboardTile({
    required int rank,
    required PrivateLeagueMember member,
    required bool isCurrent,
    required bool isMemberAdmin,
    required bool canKick,
    required VoidCallback onKick,
  }) {
    Color rankColor;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD41D); // Gold
    } else if (rank == 2) {
      rankColor = const Color(0xFFCFD8DC); // Silver
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
    } else {
      rankColor = PicoColors.textWhiteMuted;
    }

    final displayName = member.username != null && member.username!.isNotEmpty
        ? member.username!
        : 'Player';

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFF1A2B20) : const Color(0xFF0F1722),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isCurrent ? PicoColors.primary : Colors.white.withValues(alpha: 0.06),
          width: isCurrent ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          SizedBox(
            width: 26.0,
            child: Text(
              '#$rank',
              style: PicoTypography.labelPill.copyWith(
                color: rankColor,
                fontWeight: FontWeight.w900,
                fontSize: 14.0,
              ),
            ),
          ),
          const SizedBox(width: 8.0),

          // User Avatar
          CircleAvatar(
            radius: 18.0,
            backgroundColor: const Color(0xFF1E2D3D),
            backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                ? CachedNetworkImageProvider(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                ? Text(
                    displayName.substring(0, 1).toUpperCase(),
                    style: PicoTypography.bodySm.copyWith(
                      color: PicoColors.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12.0),

          // Username & Tags
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    displayName,
                    style: PicoTypography.bodyMd.copyWith(
                      color: isCurrent ? PicoColors.primary : PicoColors.textWhite,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 14.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(width: 6.0),
                  Text(
                    '(You)',
                    style: PicoTypography.bodySm.copyWith(
                      color: PicoColors.primary,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (isMemberAdmin) ...[
                  const SizedBox(width: 6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD41D).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      'ADMIN',
                      style: PicoTypography.bodySm.copyWith(
                        color: const Color(0xFFFFD41D),
                        fontSize: 9.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Division Badge & Points
          DivisionBadge.fromPoints(
            points: member.picoPoints,
            size: DivisionBadgeSize.small,
          ),
          const SizedBox(width: 8.0),
          Text(
            '${member.picoPoints} PTS',
            style: PicoTypography.labelPill.copyWith(
              color: PicoColors.textWhite,
              fontWeight: FontWeight.w800,
              fontSize: 13.0,
            ),
          ),

          // Admin Kick Control
          if (canKick) ...[
            const SizedBox(width: 4.0),
            IconButton(
              icon: const Icon(
                Icons.person_remove_rounded,
                color: PicoColors.accentCoral,
                size: 18.0,
              ),
              tooltip: 'Kick from League',
              onPressed: onKick,
            ),
          ],
        ],
      ),
    );
  }

  /// Confirmation dialog for Leaving League
  Future<void> _confirmLeaveLeague(
    BuildContext context,
    String? currentUserId,
    bool isAdmin,
  ) async {
    if (currentUserId == null) return;

    final confirmed = await showPicoConfirmationModal(
      context: context,
      title: 'Leave League?',
      message: isAdmin
          ? 'You are the league admin. If you leave, another member will be chosen at random as the new admin. If no members remain, the league will be deleted.'
          : 'Are you sure you want to leave "${widget.league.name}"?',
      cancelText: 'Cancel',
      confirmText: 'Leave',
      confirmStyle: PicoDialogButtonStyle.red,
      cancelStyle: PicoDialogButtonStyle.neutral,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final repo = ref.read(tournamentRepositoryProvider);
      await repo.leavePrivateLeague(
        leagueId: widget.league.id,
        userId: currentUserId,
      );

      // Invalidate providers
      ref.invalidate(userPrivateLeaguesProvider);
      ref.invalidate(privateLeagueDetailsProvider(widget.league.id));
      ref.invalidate(privateLeagueMembersProvider(widget.league.id));

      if (!mounted) return;
      Navigator.of(this.context).pop(); // Close bottom sheet
      this.context.go('/tournaments'); // Navigate back to Tournaments screen
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Failed to leave league: $e'),
          backgroundColor: PicoColors.accentCoral,
        ),
      );
    }
  }

  /// Confirmation dialog for Kicking Member (Admin Only)
  Future<void> _confirmKickMember(
    BuildContext context,
    PrivateLeagueMember member,
  ) async {
    final memberName = member.username ?? 'this member';

    final confirmed = await showPicoConfirmationModal(
      context: context,
      title: 'Kick $memberName?',
      message: 'Are you sure you want to remove $memberName from "${widget.league.name}"?',
      cancelText: 'Cancel',
      confirmText: 'Kick',
      confirmStyle: PicoDialogButtonStyle.red,
      cancelStyle: PicoDialogButtonStyle.neutral,
    );

    if (confirmed != true || !mounted) return;

    try {
      final authState = ref.read(authProvider);
      final adminUserId = authState is PicoAuthAuthenticated ? authState.user?.id : null;
      if (adminUserId == null) return;

      final repo = ref.read(tournamentRepositoryProvider);
      await repo.removeMemberFromPrivateLeague(
        leagueId: widget.league.id,
        targetUserId: member.userId,
        adminUserId: adminUserId,
      );

      // Invalidate members provider to refresh the list
      ref.invalidate(privateLeagueMembersProvider(widget.league.id));

      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('$memberName has been removed from the league.'),
          backgroundColor: const Color(0xFF1E2D3D),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Failed to kick member: $e'),
          backgroundColor: PicoColors.accentCoral,
        ),
      );
    }
  }
}
