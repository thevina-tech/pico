import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/private_league.dart';
import 'package:pico/features/tournaments/domain/private_league_member.dart';
import 'package:pico/features/tournaments/presentation/widgets/tactile_leaderboard_card.dart';
import 'package:pico/shared/components/pico_confirmation_modal.dart';
import 'package:pico/features/matches/domain/competition.dart';
import 'package:pico/features/tournaments/presentation/private_league_controller.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/pico_snackbar.dart';

/// Modal bottom sheet displaying League details, invite code,
/// live standings leaderboard, admin kick controls, and leave league action.
class LeagueDetailsSheet extends ConsumerStatefulWidget {
  const LeagueDetailsSheet({
    super.key,
    required this.league,
    required this.initialMembers,
    this.competition,
  });

  final PrivateLeague league;
  final List<PrivateLeagueMember> initialMembers;
  final Competition? competition;

  static Future<void> show(
    BuildContext context, {
    required PrivateLeague league,
    required List<PrivateLeagueMember> initialMembers,
    Competition? competition,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LeagueDetailsSheet(
        league: league,
        initialMembers: initialMembers,
        competition: competition,
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

    final compsMap = ref.watch(competitionsMapProvider).value ?? {};
    final comp = widget.competition ?? compsMap[widget.league.competitionId];

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
                  // 1. Header (Name, Crest, Description, Base League, Admin Badge)
                  _buildHeader(isAdmin, comp),
                  const SizedBox(height: 16.0),

                  // 2. 6-Character Invite Code & Share
                  _buildInviteCodeBox(context),
                  const SizedBox(height: 16.0),

                  // 3. Admin Controls (for Admin) or Leave League (for Non-Admin)
                  if (isAdmin)
                    _buildAdminControls(context)
                  else
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

                      return TactileLeaderboardCard(
                        rank: index + 1,
                        username: member.username,
                        avatarUrl: member.avatarUrl,
                        picoPoints: member.picoPoints,
                        isCurrentUser: isCurrent,
                        isMemberAdmin: isMemberAdmin,
                        trailing: (isAdmin && !isCurrent)
                            ? IconButton(
                                icon: const Icon(
                                  Icons.person_remove_rounded,
                                  color: PicoColors.accentCoral,
                                  size: 18.0,
                                ),
                                tooltip: 'Kick from League',
                                onPressed: () => _confirmKickMember(context, member),
                              )
                            : null,
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

  /// League Header with crest, title, description, and base league
  Widget _buildHeader(bool isAdmin, Competition? comp) {
    final hasDescription = widget.league.description.trim().isNotEmpty;

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
        if (hasDescription) ...[
          const SizedBox(height: 6.0),
          Text(
            widget.league.description.trim(),
            style: PicoTypography.bodySm.copyWith(
              color: PicoColors.textWhiteMuted,
              fontSize: 13.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        // Base league info
        if (comp != null || widget.league.competitionName.isNotEmpty) ...[
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (comp?.flag != null) ...[
                  Text(comp!.flag, style: const TextStyle(fontSize: 13.0)),
                  const SizedBox(width: 5.0),
                ],
                Text(
                  'Base: ${comp?.name ?? widget.league.competitionName}',
                  style: PicoTypography.bodySm.copyWith(
                    color: PicoColors.textWhiteMuted,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
              final l10n = AppLocalizations.of(context);
              PicoSnackBar.showSuccess(
                context,
                l10n?.codeCopiedToast ?? 'Invite code copied to clipboard!',
                duration: const Duration(seconds: 2),
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

  /// Admin controls container with Delete League action (Admin Only)
  Widget _buildAdminControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1417),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: PicoColors.accentCoral.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.admin_panel_settings_rounded,
                color: PicoColors.accentCoral,
                size: 20.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                'ADMIN CONTROLS',
                style: PicoTypography.labelPillSm.copyWith(
                  color: PicoColors.accentCoral,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.0,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: _isProcessing ? null : () => _confirmDeleteLeague(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0x66EF4444), width: 1.2),
              backgroundColor: const Color(0x1AEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            ),
            icon: const Icon(
              Icons.delete_forever_rounded,
              color: PicoColors.accentCoral,
              size: 16.0,
            ),
            label: Text(
              'Delete League',
              style: PicoTypography.bodySm.copyWith(
                color: PicoColors.accentCoral,
                fontWeight: FontWeight.w700,
                fontSize: 12.0,
              ),
            ),
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



  /// Confirmation dialog for Deleting League (Admin Only)
  Future<void> _confirmDeleteLeague(BuildContext context) async {
    final confirmed = await showPicoConfirmationModal(
      context: context,
      title: 'Delete League?',
      message:
          'Are you sure you want to delete "${widget.league.name}"? This action cannot be undone and will remove all members.',
      cancelText: 'Cancel',
      confirmText: 'Delete',
      confirmStyle: PicoDialogButtonStyle.red,
      cancelStyle: PicoDialogButtonStyle.neutral,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      await ref.read(privateLeagueControllerProvider.notifier).deleteLeague(widget.league.id);
      if (!mounted) return;
      Navigator.of(this.context).pop(); // Close bottom sheet
      this.context.go('/tournaments'); // Navigate back to Tournaments screen
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      final l10n = AppLocalizations.of(this.context);
      PicoSnackBar.showError(
        this.context,
        l10n?.failedToDeleteLeague(e.toString()) ?? 'Failed to delete league: $e',
      );
    }
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
      final l10n = AppLocalizations.of(this.context);
      PicoSnackBar.showError(
        this.context,
        l10n?.failedToLeaveLeague(e.toString()) ?? 'Failed to leave league: $e',
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
      final l10n = AppLocalizations.of(this.context);
      PicoSnackBar.showSuccess(
        this.context,
        l10n?.memberRemovedFromLeague(memberName) ?? '$memberName has been removed from the league.',
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(this.context);
      PicoSnackBar.showError(
        this.context,
        l10n?.failedToKickMember(e.toString()) ?? 'Failed to remove member: $e',
      );
    }
  }
}
