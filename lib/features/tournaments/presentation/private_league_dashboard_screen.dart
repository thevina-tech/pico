import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/network/supabase_client_provider.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/core/utils/input_sanitizer.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/matches/domain/competition.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/predictions/presentation/prediction_controller.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/league_message.dart';
import 'package:pico/features/tournaments/domain/private_league.dart';
import 'package:pico/features/tournaments/domain/private_league_member.dart';
import 'package:pico/features/tournaments/presentation/private_league_controller.dart';
import 'package:pico/features/tournaments/presentation/widgets/league_details_sheet.dart';
import 'package:pico/shared/components/match_card.dart';
import 'package:pico/shared/components/prediction_bottom_sheet.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
import 'package:pico/shared/components/division_badge.dart';
import 'package:pico/shared/components/pico_confirmation_modal.dart';
import 'package:pico/shared/components/pico_app_bar.dart';
import 'package:pico/l10n/app_localizations.dart';

/// Unified Clan Dashboard for Private Leagues.
/// Combines Realtime Chat, Competition Matches, and Member Standings into a single screen.
class PrivateLeagueDashboardScreen extends ConsumerStatefulWidget {
  const PrivateLeagueDashboardScreen({
    super.key,
    required this.leagueId,
    this.initialLeague,
    this.initialTabIndex = 0,
  });

  final String leagueId;
  final PrivateLeague? initialLeague;
  final int initialTabIndex; // 0: Chat, 1: Matches, 2: Standings

  @override
  ConsumerState<PrivateLeagueDashboardScreen> createState() =>
      _PrivateLeagueDashboardScreenState();
}

class _PrivateLeagueDashboardScreenState
    extends ConsumerState<PrivateLeagueDashboardScreen> {
  late int _selectedTabIndex;
  int _selectedMatchCategoryIndex = 0; // 0: Upcoming, 1: Live, 2: Finished
  bool _isProcessing = false;

  // Realtime Chat State
  final List<LeagueMessage> _messages = [];
  bool _isLoadingMessages = true;
  bool _isSending = false;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    _loadInitialMessages();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==========================================
  // REALTIME CHAT METHODS
  // ==========================================

  Future<void> _loadInitialMessages() async {
    try {
      final repo = ref.read(tournamentRepositoryProvider);
      final messages = await repo.getLeagueMessages(widget.leagueId);
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
          _isLoadingMessages = false;
        });
      }
    } catch (e, st) {
      AppLogger.error('Failed to load initial league messages', e, st);
      if (mounted) {
        setState(() => _isLoadingMessages = false);
      }
    }
  }

  void _setupRealtimeSubscription() {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;

    try {
      _realtimeChannel = client
          .channel('public:league_messages:${widget.leagueId}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'league_messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'league_id',
              value: widget.leagueId,
            ),
            callback: (payload) {
              _handleNewRealtimeRecord(payload.newRecord);
            },
          )
          .subscribe();
    } catch (e) {
      AppLogger.warning('Failed to subscribe to realtime channel: $e');
    }
  }

  void _handleNewRealtimeRecord(Map<String, dynamic> record) {
    final messageId = record['id']?.toString();
    if (messageId == null) return;

    if (_messages.any((m) => m.id == messageId)) return;

    final senderUserId = record['user_id']?.toString() ?? '';
    final members = ref.read(privateLeagueMembersProvider(widget.leagueId)).value ?? [];
    final matchingMember = members.where((m) => m.userId == senderUserId).firstOrNull;

    final authState = ref.read(authProvider);
    final currentUserId = authState is PicoAuthAuthenticated ? authState.user?.id : null;

    String? resolvedUsername = matchingMember?.username;
    String? resolvedAvatarUrl = matchingMember?.avatarUrl;

    if (senderUserId == currentUserId && (resolvedUsername == null || resolvedUsername.isEmpty)) {
      final userProfile = ref.read(currentUserProfileProvider).value;
      resolvedUsername = userProfile?.username ?? 'You';
      resolvedAvatarUrl = userProfile?.avatarUrl;
    }

    final newLeagueMessage = LeagueMessage(
      id: messageId,
      leagueId: record['league_id']?.toString() ?? widget.leagueId,
      userId: senderUserId,
      message: record['message']?.toString() ?? '',
      createdAt: record['created_at'] != null
          ? DateTime.tryParse(record['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      username: resolvedUsername ?? 'Player',
      avatarUrl: resolvedAvatarUrl,
    );

    if (mounted) {
      setState(() {
        _messages.insert(0, newLeagueMessage);
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = InputSanitizer.sanitizeChatMessage(_textController.text);
    if (text.isEmpty || _isSending) return;

    final authState = ref.read(authProvider);
    final currentUserId = authState is PicoAuthAuthenticated ? authState.user?.id : null;
    if (currentUserId == null) return;

    final userProfile = ref.read(currentUserProfileProvider).value;
    final username = userProfile?.username ?? 'You';
    final avatarUrl = userProfile?.avatarUrl;

    setState(() => _isSending = true);
    _textController.clear();

    try {
      final repo = ref.read(tournamentRepositoryProvider);
      final sentMessage = await repo.sendLeagueMessage(
        leagueId: widget.leagueId,
        userId: currentUserId,
        message: text,
        username: username,
        avatarUrl: avatarUrl,
      );

      if (mounted && !_messages.any((m) => m.id == sentMessage.id)) {
        setState(() {
          _messages.insert(0, sentMessage);
        });
      }
    } catch (e, st) {
      AppLogger.error('Failed to send message: $e', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: PicoColors.accentCoral,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  // ==========================================
  // MAIN BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final leagueAsync = ref.watch(privateLeagueDetailsProvider(widget.leagueId));
    final currentLeague = leagueAsync.value ?? widget.initialLeague;

    final membersAsync = ref.watch(privateLeagueMembersProvider(widget.leagueId));
    final members = membersAsync.value ?? const <PrivateLeagueMember>[];

    final compsMap = ref.watch(competitionsMapProvider).value ?? {};
    final competition = currentLeague != null ? compsMap[currentLeague.competitionId] : null;

    final authState = ref.watch(authProvider);
    final currentUserId = authState is PicoAuthAuthenticated ? authState.user?.id : null;
    final isOwner = currentLeague != null && currentUserId != null && currentLeague.ownerId == currentUserId;

    final screenBackground = _selectedTabIndex == 0
        ? 'assets/images/league_chat_background.png'
        : 'assets/images/main_background.png';

    return PicoPitchBackground(
      imageAsset: screenBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(
          currentLeague: currentLeague,
          competition: competition,
          members: members,
          isOwner: isOwner,
          l10n: l10n,
        ),
        body: currentLeague == null
            ? const Center(
                child: CircularProgressIndicator(color: PicoColors.primary),
              )
            : SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500.0),
                    child: Column(
                      children: [
                        // Top Segmented Tab Selector ("Chat" | "Matches" | "Standings")
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 8.0),
                          child: _buildTopTabBar(l10n),
                        ),

                        // Active Tab Body
                        Expanded(
                          child: _buildActiveTabBody(
                            currentLeague: currentLeague,
                            competition: competition,
                            isOwner: isOwner,
                            currentUserId: currentUserId,
                            l10n: l10n,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildActiveTabBody({
    required PrivateLeague currentLeague,
    required Competition? competition,
    required bool isOwner,
    required String? currentUserId,
    required AppLocalizations? l10n,
  }) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildChatTab(currentLeague, currentUserId);
      case 1:
        return _buildMatchesView(currentLeague.competitionId ?? '', l10n);
      case 2:
      default:
        return _buildLeaderboardView(currentLeague, competition, isOwner, currentUserId, l10n);
    }
  }

  // ==========================================
  // APP BAR
  // ==========================================

  PreferredSizeWidget _buildAppBar({
    required PrivateLeague? currentLeague,
    required Competition? competition,
    required List<PrivateLeagueMember> members,
    required bool isOwner,
    required AppLocalizations? l10n,
  }) {
    final leagueName = currentLeague?.name ?? 'Private League';

    return PicoAppBar(
      showBackButton: true,
      onBack: () => context.pop(),
      titleWidget: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          if (currentLeague != null) {
            _openDetailsSheet(currentLeague, members, competition);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCrestIcon(competition),
              const SizedBox(width: 8.0),
              Flexible(
                child: Text(
                  leagueName,
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Color(0x99000000),
                        offset: Offset(0, 2),
                        blurRadius: 4.0,
                      ),
                      Shadow(
                        color: Color(0x6610B981),
                        offset: Offset(0, 1),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (currentLeague != null)
          IconButton(
            key: const Key('league_settings_button'),
            icon: const Icon(
              Icons.settings_rounded,
              color: PicoColors.textWhite,
              size: 22.0,
            ),
            tooltip: 'Settings & Info',
            onPressed: () {
              _openDetailsSheet(currentLeague, members, competition);
            },
          ),
      ],
    );
  }

  Widget _buildCrestIcon(Competition? competition) {
    if (competition?.emblemUrl != null && competition!.emblemUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: competition.emblemUrl!,
        width: 28.0,
        height: 28.0,
        placeholder: (context, url) => Container(
          width: 28.0,
          height: 28.0,
          decoration: const BoxDecoration(
            color: Color(0xFF1E2D3D),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.shield_rounded, size: 16.0, color: PicoColors.primary),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 28.0,
          height: 28.0,
          decoration: const BoxDecoration(
            color: Color(0xFF1E2D3D),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              competition.flag,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 28.0,
      height: 28.0,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D3D),
        shape: BoxShape.circle,
        border: Border.all(color: PicoColors.primary.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Text(
          competition?.flag ?? '⚽',
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  void _openDetailsSheet(
    PrivateLeague league,
    List<PrivateLeagueMember> members, [
    Competition? competition,
  ]) {
    LeagueDetailsSheet.show(
      context,
      league: league,
      initialMembers: members,
      competition: competition,
    );
  }

  // ==========================================
  // TOP TAB BAR ("Chat" | "Matches" | "Standings")
  // ==========================================

  Widget _buildTopTabBar(AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A24),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildClashTabButton(
            title: 'Chat',
            icon: Icons.chat_bubble_outline_rounded,
            isSelected: _selectedTabIndex == 0,
            onTap: () => setState(() => _selectedTabIndex = 0),
          ),
          const SizedBox(width: 8.0),
          _buildClashTabButton(
            title: l10n?.matchesTab ?? 'Matches',
            icon: Icons.sports_soccer_rounded,
            isSelected: _selectedTabIndex == 1,
            onTap: () => setState(() => _selectedTabIndex = 1),
          ),
          const SizedBox(width: 8.0),
          _buildClashTabButton(
            title: l10n?.leaderboardTab ?? 'Standings',
            icon: Icons.leaderboard_rounded,
            isSelected: _selectedTabIndex == 2,
            onTap: () => setState(() => _selectedTabIndex = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildClashTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const activeColor = PicoColors.primary;
    const activeBorderBottom = Color(0xFF009650);
    const inactiveColor = Color(0xFF162534);
    const inactiveBorderBottom = Color(0xFF090F16);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(top: isSelected ? 2.0 : 0.0),
          decoration: BoxDecoration(
            color: isSelected ? activeBorderBottom : inactiveBorderBottom,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.35),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          padding: EdgeInsets.only(bottom: isSelected ? 2.0 : 4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              color: isSelected ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24.0,
                  color: isSelected ? PicoColors.pitchBackground : PicoColors.textWhiteMuted,
                ),
                const SizedBox(height: 6.0),
                Text(
                  title,
                  style: PicoTypography.labelPillSm.copyWith(
                    color: isSelected ? PicoColors.pitchBackground : PicoColors.textWhiteMuted,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    fontSize: 12.0,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 0: CHAT FEED & INPUT
  // ==========================================

  Widget _buildChatTab(PrivateLeague league, String? currentUserId) {
    return Stack(
      children: [
        // Chat Wallpaper Background (Normal/Crisp)
        Positioned.fill(
          child: Image.asset(
            'assets/images/league_chat_background.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),
        // Subtle dark scrim so messages pop crisply
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: _isLoadingMessages
                  ? const Center(
                      child: CircularProgressIndicator(color: PicoColors.primary),
                    )
                  : _messages.isEmpty
                      ? _buildEmptyChatState(league)
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isCurrentUser =
                                currentUserId != null && message.userId == currentUserId;
                            return _buildChatBubble(message, isCurrentUser);
                          },
                        ),
            ),
            _buildMessageInputBar(),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyChatState(PrivateLeague league) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFF141F2C),
                shape: BoxShape.circle,
                border: Border.all(color: PicoColors.primary.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 40.0,
                color: PicoColors.primary,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'No messages yet!',
              style: PicoTypography.headlineMd.copyWith(
                color: PicoColors.textWhite,
                fontWeight: FontWeight.w800,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Break the ice and share your predictions for upcoming matches!',
              textAlign: TextAlign.center,
              style: PicoTypography.bodySm.copyWith(
                color: PicoColors.textWhiteMuted,
                fontSize: 13.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(LeagueMessage message, bool isCurrentUser) {
    final timeStr = DateFormat('h:mm a').format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 15.0,
              backgroundColor: const Color(0xFF1E2D3D),
              backgroundImage:
                  message.avatarUrl != null && message.avatarUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(message.avatarUrl!)
                      : null,
              child: (message.avatarUrl == null || message.avatarUrl!.isEmpty)
                  ? Text(
                      (message.username ?? 'P').characters.first.toUpperCase(),
                      style: const TextStyle(
                        color: PicoColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser && message.username != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                    child: Text(
                      message.username!,
                      style: const TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: Color(0x99000000),
                            offset: Offset(0, 1),
                            blurRadius: 2.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    // Game-like off-white (not harsh/sharp pure white)
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isCurrentUser
                          ? const [
                              Color(0xFFE8F7EE), // Soft game mint-white
                              Color(0xFFDCF4E5),
                            ]
                          : const [
                              Color(0xFFF3F6F9), // Soft pearl off-white
                              Color(0xFFE5EBF1),
                            ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16.0),
                      topRight: const Radius.circular(16.0),
                      bottomLeft: Radius.circular(isCurrentUser ? 16.0 : 4.0),
                      bottomRight: Radius.circular(isCurrentUser ? 4.0 : 16.0),
                    ),
                    border: Border.all(
                      color: isCurrentUser
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                    boxShadow: [
                      // Tactile 3D bottom bevel
                      BoxShadow(
                        color: isCurrentUser
                            ? const Color(0xFF059669)
                            : const Color(0xFF94A3B8),
                        offset: const Offset(0, 2.5),
                        blurRadius: 0,
                      ),
                      // Soft ambient drop shadow
                      const BoxShadow(
                        color: Color(0x2E000000),
                        offset: Offset(0, 4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      color: isCurrentUser
                          ? const Color(0xFF064E3B) // High-contrast deep game green
                          : const Color(0xFF0F172A), // High-contrast deep slate
                      fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 14.0,
                      height: 1.3,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                  child: Text(
                    timeStr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(
                          color: Color(0x99000000),
                          offset: Offset(0, 1),
                          blurRadius: 2.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser) const SizedBox(width: 8.0),
        ],
      ),
    );
  }

  Widget _buildMessageInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: PicoColors.darkTray,
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141F2C),
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  inputFormatters: InputSanitizer.chatMessageFormatters,
                  style: const TextStyle(color: PicoColors.textWhite, fontSize: 14.0),
                  decoration: const InputDecoration(
                    hintText: 'Message league...',
                    hintStyle: TextStyle(
                      color: PicoColors.textWhiteMuted,
                      fontSize: 14.0,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24.0),
                onTap: _isSending ? null : _sendMessage,
                child: Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: const BoxDecoration(
                    color: PicoColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: _isSending
                      ? const Center(
                          child: SizedBox(
                            width: 18.0,
                            height: 18.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: PicoColors.pitchBackground,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: PicoColors.pitchBackground,
                          size: 18.0,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: MATCHES FEED (FILTERED & SYNCED)
  // ==========================================

  Widget _buildMatchesView(String competitionId, AppLocalizations? l10n) =>
      _buildMatchesTab(competitionId, l10n);

  Widget _buildMatchesTab(String competitionId, AppLocalizations? l10n) {
    // 1. Dynamic Match Filtering: filtered specifically to this League's competition
    final matchesAsync = ref.watch(competitionMatchesProvider(competitionId));
    // 2. Single Source of Truth: reads global user predictions
    final predictionsAsync = ref.watch(predictionControllerProvider);

    return matchesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: PicoColors.primary),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: PicoColors.accentCoral),
        ),
      ),
      data: (allMatches) {
        if (allMatches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_busy_rounded, size: 48.0, color: PicoColors.textWhiteMuted),
                const SizedBox(height: 12.0),
                Text(
                  l10n?.noMatchesForCompetition ?? 'No matches scheduled for this competition yet.',
                  style: PicoTypography.bodyLg.copyWith(color: PicoColors.textWhiteMuted),
                ),
              ],
            ),
          );
        }

        // Filter strictly to this League's competition
        final matches = allMatches
            .whereType<PicoMatch>()
            .where((m) => m.competitionId == competitionId)
            .toList();
        final liveMatches = matches.where((m) => m.status == MatchStatus.live).toList();
        final upcomingMatches = matches.where((m) => m.status == MatchStatus.upcoming).toList()
          ..sort((a, b) => a.kickoffAt.compareTo(b.kickoffAt));
        final finishedMatches = matches.where((m) => m.status == MatchStatus.finished).toList()
          ..sort((a, b) => b.kickoffAt.compareTo(a.kickoffAt));

        final List<PicoMatch> currentCategoryMatches;
        if (_selectedMatchCategoryIndex == 0) {
          currentCategoryMatches = upcomingMatches;
        } else if (_selectedMatchCategoryIndex == 1) {
          currentCategoryMatches = liveMatches;
        } else {
          currentCategoryMatches = finishedMatches;
        }

        return Column(
          children: [
            // Sub-Chips: Upcoming | Live | Finished
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: _buildMatchCategoryChips(
                upcomingCount: upcomingMatches.length,
                liveCount: liveMatches.length,
                finishedCount: finishedMatches.length,
                l10n: l10n,
              ),
            ),
            const SizedBox(height: 8.0),

            // Matches List
            Expanded(
              child: currentCategoryMatches.isEmpty
                  ? _buildMatchEmptyCategoryState(_selectedMatchCategoryIndex, l10n)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                      itemCount: currentCategoryMatches.length,
                      itemBuilder: (context, index) {
                        final match = currentCategoryMatches[index];
                        // Sourced from single global predictions provider
                        final userPred = predictionsAsync.value?[match.id];
                        final predictedHomeScore = userPred?.homeScore;
                        final predictedAwayScore = userPred?.awayScore;
                        final points = match.calculateSettlementPoints(
                          predictedHomeScore,
                          predictedAwayScore,
                        );

                        String? outcomeLabel;
                        if (match.status == MatchStatus.finished) {
                          if (userPred != null) {
                            if (points != null && points == 5) {
                              outcomeLabel = l10n?.pointsOutcomeExact ?? 'Exact Score (+5)';
                            } else if (points != null && points == 3) {
                              outcomeLabel = l10n?.pointsOutcomeWinner ?? 'Correct Winner (+3)';
                            } else {
                              outcomeLabel = l10n?.pointsOutcomeIncorrect ?? 'Missed';
                            }
                          } else {
                            outcomeLabel = l10n?.pointsOutcomeNone ?? 'No Prediction';
                          }
                        }

                        String? teaserLabel;
                        if (match.isTeaser) {
                          final countdown = match.teaserCountdown;
                          if (countdown.inDays >= 1) {
                            teaserLabel = l10n?.teaserOpensInDays(countdown.inDays) ?? 'Opens in ${countdown.inDays}d';
                          } else if (countdown.inHours >= 1) {
                            teaserLabel = l10n?.teaserOpensInHours(countdown.inHours) ?? 'Opens in ${countdown.inHours}h';
                          } else {
                            teaserLabel = l10n?.teaserOpensInMinutes(countdown.inMinutes.clamp(1, 60)) ?? 'Opens in ${countdown.inMinutes.clamp(1, 60)}m';
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: MatchCard.fromMatch(
                            match: match,
                            predictedHomeScore: predictedHomeScore,
                            predictedAwayScore: predictedAwayScore,
                            awardedPoints: points,
                            settlementOutcomeLabel: outcomeLabel,
                            teaserCountdownLabel: teaserLabel,
                            teaserSubtext: l10n?.teaserCountdownSubtext ?? 'Prediction window opens 3 days before kickoff',
                            onCardTap: match.isTeaser
                                ? null
                                : () {
                                    if (match.status == MatchStatus.finished || match.isLocked) {
                                      context.push('/prediction/${match.id}', extra: match);
                                    } else {
                                      showPicoPredictionBottomSheet(
                                        context: context,
                                        ref: ref,
                                        match: match,
                                      );
                                    }
                                  },
                            onPredictPressed: match.isTeaser
                                ? null
                                : () => showPicoPredictionBottomSheet(
                                      context: context,
                                      ref: ref,
                                      match: match,
                                    ),
                            onModifyPressed: () => showPicoPredictionBottomSheet(
                              context: context,
                              ref: ref,
                              match: match,
                            ),
                            onViewPredictionPressed: () =>
                                context.push('/prediction/${match.id}', extra: match),
                            onTapResult: () =>
                                context.push('/prediction/${match.id}', extra: match),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMatchCategoryChips({
    required int upcomingCount,
    required int liveCount,
    required int finishedCount,
    required AppLocalizations? l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2117),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMatchCategoryItem(
              title: l10n?.feedTabUpcoming ?? 'Upcoming',
              count: upcomingCount,
              isSelected: _selectedMatchCategoryIndex == 0,
              onTap: () => setState(() => _selectedMatchCategoryIndex = 0),
            ),
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: _buildMatchCategoryItem(
              title: l10n?.feedTabLive ?? 'Live',
              count: liveCount,
              isSelected: _selectedMatchCategoryIndex == 1,
              isLive: true,
              onTap: () => setState(() => _selectedMatchCategoryIndex = 1),
            ),
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: _buildMatchCategoryItem(
              title: l10n?.feedTabFinished ?? 'Finished',
              count: finishedCount,
              isSelected: _selectedMatchCategoryIndex == 2,
              onTap: () => setState(() => _selectedMatchCategoryIndex = 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCategoryItem({
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    bool isLive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected ? PicoColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(11.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLive && count > 0) ...[
              Container(
                width: 6.0,
                height: 6.0,
                margin: const EdgeInsets.only(right: 5.0),
                decoration: const BoxDecoration(
                  color: PicoColors.accentCoral,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            Text(
              title,
              style: PicoTypography.labelPillSm.copyWith(
                color: isSelected ? PicoColors.textWhite : PicoColors.textWhiteMuted,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(width: 4.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999.0),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : PicoColors.textWhiteMuted,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchEmptyCategoryState(int categoryIndex, AppLocalizations? l10n) {
    final String title;
    final String subtitle;
    final IconData icon;

    if (categoryIndex == 1) {
      title = l10n?.noLiveMatches ?? 'No Live Matches';
      subtitle = l10n?.noLiveMatchesSub ?? 'There are no matches currently in play.';
      icon = Icons.sensors_off_rounded;
    } else if (categoryIndex == 0) {
      title = l10n?.feedNoUpcomingMatches ?? 'No Upcoming Matches';
      subtitle = l10n?.noUpcomingMatchesSub ?? 'Check back later for newly scheduled matches.';
      icon = Icons.event_busy_rounded;
    } else {
      title = l10n?.noFinishedMatches ?? 'No Finished Matches';
      subtitle = l10n?.noFinishedMatchesSub ?? 'Past matches will appear here.';
      icon = Icons.history_toggle_off_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44.0, color: PicoColors.textWhiteMuted.withValues(alpha: 0.6)),
            const SizedBox(height: 12.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: PicoTypography.headlineMd.copyWith(
                color: PicoColors.textWhite,
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: PicoTypography.bodySm.copyWith(
                color: PicoColors.textWhiteMuted,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: STANDINGS & LEADERBOARD VIEW
  // ==========================================

  Widget _buildLeaderboardView(
    PrivateLeague league,
    Competition? competition,
    bool isOwner,
    String? currentUserId,
    AppLocalizations? l10n,
  ) =>
      _buildStandingsTab(league, competition, isOwner, currentUserId, l10n);

  Widget _buildStandingsTab(
    PrivateLeague league,
    Competition? competition,
    bool isOwner,
    String? currentUserId,
    AppLocalizations? l10n,
  ) {
    final membersAsync = ref.watch(privateLeagueMembersProvider(league.id));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 24.0),
      children: [

        // 4. Standings Section Title
        Text(
          'STANDINGS',
          style: PicoTypography.labelPillSm.copyWith(
            color: PicoColors.textWhiteMuted,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8.0),

        // 5. Members List
        membersAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: CircularProgressIndicator(color: PicoColors.primary),
            ),
          ),
          error: (e, _) => Center(
            child: Text(
              e.toString(),
              style: const TextStyle(color: PicoColors.accentCoral),
            ),
          ),
          data: (members) {
            if (members.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group_off_rounded, size: 48.0, color: PicoColors.textWhiteMuted),
                      const SizedBox(height: 12.0),
                      Text(
                        l10n?.noParticipantsYet ?? 'No participants yet',
                        style: PicoTypography.bodyLg.copyWith(color: PicoColors.textWhiteMuted),
                      ),
                    ],
                  ),
                ),
              );
            }

            final sortedMembers = List<PrivateLeagueMember>.from(members)
              ..sort((a, b) => b.picoPoints.compareTo(a.picoPoints));

            return Column(
              children: List.generate(sortedMembers.length, (index) {
                final member = sortedMembers[index];
                final rank = index + 1;
                final isCurrentUser = member.userId == currentUserId;
                final isMemberOwner = member.userId == league.ownerId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? const Color(0xFF143322)
                        : PicoColors.darkTray,
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: isCurrentUser
                          ? PicoColors.primary
                          : Colors.white.withValues(alpha: 0.06),
                      width: isCurrentUser ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Rank badge
                      _buildRankBadge(rank),
                      const SizedBox(width: 12.0),

                      // Avatar
                      CircleAvatar(
                        radius: 17.0,
                        backgroundColor: const Color(0xFF1B3828),
                        backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(member.avatarUrl!)
                            : null,
                        child: (member.avatarUrl == null || member.avatarUrl!.isEmpty)
                            ? Text(
                                (member.username ?? 'P').characters.first.toUpperCase(),
                                style: const TextStyle(
                                  color: PicoColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.0,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10.0),

                      // Username + Creator / You tags
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    member.username ?? 'Player',
                                    style: PicoTypography.titleCard.copyWith(
                                      color: PicoColors.textWhite,
                                      fontWeight: isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                                      fontSize: 14.0,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isMemberOwner) ...[
                                  const SizedBox(width: 6.0),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                                    decoration: BoxDecoration(
                                      color: PicoColors.gold.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: const Text(
                                      'CREATOR',
                                      style: TextStyle(
                                        color: PicoColors.gold,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 8.5,
                                      ),
                                    ),
                                  ),
                                ] else if (isCurrentUser) ...[
                                  const SizedBox(width: 6.0),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                                    decoration: BoxDecoration(
                                      color: PicoColors.primary,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: const Text(
                                      'YOU',
                                      style: TextStyle(
                                        color: PicoColors.pitchBackground,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 8.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Division Badge
                      DivisionBadge.fromPoints(
                        points: member.picoPoints,
                        size: DivisionBadgeSize.small,
                      ),
                      const SizedBox(width: 8.0),

                      // Points Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1B13),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: rank <= 3 ? PicoColors.gold : Colors.white.withValues(alpha: 0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          '${member.picoPoints} ${l10n?.pointsAbbreviation ?? "PTS"}',
                          style: PicoTypography.headlineMd.copyWith(
                            color: rank <= 3 ? PicoColors.gold : PicoColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.0,
                          ),
                        ),
                      ),

                      // Admin Kick Action
                      if (isOwner && !isMemberOwner) ...[
                        const SizedBox(width: 6.0),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: PicoColors.accentCoral,
                            size: 20.0,
                          ),
                          tooltip: l10n?.removeMemberButton ?? 'Remove Member',
                          onPressed: _isProcessing ? null : () => _confirmRemoveMember(league.id, member, l10n),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }



  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    Color textColor;

    if (rank == 1) {
      badgeColor = PicoColors.gold;
      textColor = const Color(0xFF261A00);
    } else if (rank == 2) {
      badgeColor = const Color(0xFFE2E8F0);
      textColor = const Color(0xFF1E293B);
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32);
      textColor = Colors.white;
    } else {
      badgeColor = const Color(0xFF1E2922);
      textColor = PicoColors.textWhiteMuted;
    }

    return Container(
      width: 26.0,
      height: 26.0,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 11.5,
        ),
      ),
    );
  }

  // ==========================================
  // CONFIRMATION DIALOGS & ACTIONS
  // ==========================================



  Future<void> _confirmRemoveMember(
    String leagueId,
    PrivateLeagueMember member,
    AppLocalizations? l10n,
  ) async {
    final confirmed = await showPicoConfirmationModal(
      context: context,
      title: l10n?.removeMemberConfirmTitle ?? 'Remove Member',
      message: l10n?.removeMemberConfirmBody(member.username ?? 'Player') ??
          'Are you sure you want to remove ${member.username ?? "this member"}?',
      cancelText: l10n?.cancelButton ?? 'Cancel',
      confirmText: l10n?.removeMemberButton ?? 'Remove Member',
      confirmStyle: PicoDialogButtonStyle.red,
      cancelStyle: PicoDialogButtonStyle.neutral,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      await ref.read(privateLeagueControllerProvider.notifier).removeMember(
        leagueId: leagueId,
        targetUserId: member.userId,
      );
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.memberRemovedToast ?? 'Member removed successfully'),
          backgroundColor: PicoColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: PicoColors.accentCoral,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


}
