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
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/matches/domain/competition.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/league_message.dart';
import 'package:pico/features/tournaments/domain/private_league.dart';
import 'package:pico/features/tournaments/domain/private_league_member.dart';
import 'package:pico/features/tournaments/presentation/widgets/league_details_sheet.dart';

/// Private League Room screen featuring a Chat-First layout (Clash Royale style),
/// Supabase Realtime messaging feed, interactive trigger AppBar, and League Details Sheet.
class LeagueChatScreen extends ConsumerStatefulWidget {
  const LeagueChatScreen({
    super.key,
    required this.leagueId,
    this.initialLeague,
  });

  final String leagueId;
  final PrivateLeague? initialLeague;

  @override
  ConsumerState<LeagueChatScreen> createState() => _LeagueChatScreenState();
}

class _LeagueChatScreenState extends ConsumerState<LeagueChatScreen> {
  final List<LeagueMessage> _messages = [];
  bool _isLoadingMessages = true;
  bool _isSending = false;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
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

  /// Initial Fetch (Join): Retrieves messages joined with profiles
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

  /// Connects feed using Supabase Realtime and maps incoming user_id
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

  /// Realtime Payload Handling: Maps user_id against members list to inject username & avatar
  void _handleNewRealtimeRecord(Map<String, dynamic> record) {
    final messageId = record['id']?.toString();
    if (messageId == null) return;

    // Deduplicate if message already exists in state
    if (_messages.any((m) => m.id == messageId)) return;

    final senderUserId = record['user_id']?.toString() ?? '';

    // Map incoming user_id against loaded members list
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

  /// Inserts a new row into league_messages via repository
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
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

      // Insert optimistically if not already inserted by Realtime
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

  @override
  Widget build(BuildContext context) {
    final leagueAsync = ref.watch(privateLeagueDetailsProvider(widget.leagueId));
    final currentLeague = leagueAsync.value ?? widget.initialLeague;

    final membersAsync = ref.watch(privateLeagueMembersProvider(widget.leagueId));
    final members = membersAsync.value ?? const <PrivateLeagueMember>[];

    final compsMap = ref.watch(competitionsMapProvider).value ?? {};
    final competition = currentLeague != null ? compsMap[currentLeague.competitionId] : null;

    final authState = ref.watch(authProvider);
    final currentUserId = authState is PicoAuthAuthenticated ? authState.user?.id : null;

    return Scaffold(
      backgroundColor: PicoColors.pitchBackground,
      resizeToAvoidBottomInset: true,
      appBar: _buildInteractiveAppBar(
        currentLeague: currentLeague,
        competition: competition,
        members: members,
        currentUserId: currentUserId,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500.0),
            child: Column(
              children: [
                // Realtime Chat Message Feed
                Expanded(
                  child: _isLoadingMessages
                      ? const Center(
                          child: CircularProgressIndicator(color: PicoColors.primary),
                        )
                      : _messages.isEmpty
                          ? _buildEmptyState(currentLeague)
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

                // Bottom Input Field
                _buildMessageInputBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 3. Interactive AppBar (The Trigger)
  /// Shows League Crest, Name, and "Active Members" count.
  /// Wrapped in InkWell: When tapped, triggers showModalBottomSheet(LeagueDetailsSheet)
  PreferredSizeWidget _buildInteractiveAppBar({
    required PrivateLeague? currentLeague,
    required Competition? competition,
    required List<PrivateLeagueMember> members,
    required String? currentUserId,
  }) {
    final leagueName = currentLeague?.name ?? 'Private League';
    final memberCount = members.isNotEmpty
        ? members.length
        : (currentLeague?.memberCount ?? 1);

    return AppBar(
      backgroundColor: const Color(0xFF0F1722),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: PicoColors.textWhite,
          size: 20.0,
        ),
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          if (currentLeague != null) {
            _openDetailsSheet(currentLeague, members);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // League Crest / Competition Emblem
              _buildCrestIcon(competition),
              const SizedBox(width: 10.0),

              // Title and Member Count
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leagueName,
                      style: PicoTypography.headlineMd.copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        color: PicoColors.textWhite,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$memberCount Active Members',
                          style: PicoTypography.bodySm.copyWith(
                            fontSize: 11.5,
                            color: PicoColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2.0),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16.0,
                          color: PicoColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.leaderboard_rounded,
            color: Color(0xFFFFD41D),
            size: 22.0,
          ),
          tooltip: 'League Details & Leaderboard',
          onPressed: () {
            if (currentLeague != null) {
              _openDetailsSheet(currentLeague, members);
            }
          },
        ),
      ],
    );
  }

  /// League Crest / Emblem Icon
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
      child: const Center(
        child: Icon(Icons.shield_rounded, size: 16.0, color: PicoColors.primary),
      ),
    );
  }

  /// Triggers LeagueDetailsSheet modal bottom sheet
  void _openDetailsSheet(PrivateLeague league, List<PrivateLeagueMember> members) {
    LeagueDetailsSheet.show(
      context,
      league: league,
      initialMembers: members,
    );
  }

  /// Empty Chat State with Clash Royale / Game feel
  Widget _buildEmptyState(PrivateLeague? league) {
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
              'League Room Chat',
              style: PicoTypography.headlineMd.copyWith(
                color: PicoColors.textWhite,
                fontWeight: FontWeight.w800,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'No messages yet! Say hi to your league rivals 👋\nPredict together, banter, and climb the leaderboard!',
              style: PicoTypography.bodyMd.copyWith(
                color: PicoColors.textWhiteMuted,
                fontSize: 13.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Chat Bubble Builder
  Widget _buildChatBubble(LeagueMessage message, bool isCurrentUser) {
    final timeStr = DateFormat('h:mm a').format(message.createdAt.toLocal());
    final senderName = message.username ?? 'Player';

    if (isCurrentUser) {
      // Current User Message (Aligned Right, vibrant green bubble)
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeStr,
              style: PicoTypography.bodySm.copyWith(
                color: PicoColors.textWhiteMuted.withValues(alpha: 0.6),
                fontSize: 10.0,
              ),
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00E676), Color(0xFF00C853)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(4.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3300E676),
                      blurRadius: 8.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message.message,
                  style: PicoTypography.bodyMd.copyWith(
                    color: const Color(0xFF09140E),
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Other User Message (Aligned Left, with sender avatar & username)
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 16.0,
            backgroundColor: const Color(0xFF1E2D3D),
            backgroundImage: message.avatarUrl != null && message.avatarUrl!.isNotEmpty
                ? CachedNetworkImageProvider(message.avatarUrl!)
                : null,
            child: message.avatarUrl == null || message.avatarUrl!.isEmpty
                ? Text(
                    senderName.isNotEmpty ? senderName.substring(0, 1).toUpperCase() : 'P',
                    style: PicoTypography.bodySm.copyWith(
                      color: PicoColors.textWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.0,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10.0),

          // Message Body with Name & Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  senderName,
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFFFFD41D),
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 3.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16222F),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4.0),
                      topRight: Radius.circular(16.0),
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    message.message,
                    style: PicoTypography.bodyMd.copyWith(
                      color: PicoColors.textWhite,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  timeStr,
                  style: PicoTypography.bodySm.copyWith(
                    color: PicoColors.textWhiteMuted.withValues(alpha: 0.6),
                    fontSize: 10.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Text Input Field Bar
  Widget _buildMessageInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 12.0),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1722),
        border: Border(
          top: BorderSide(color: Color(0x1AFFFFFF), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF16222F),
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: TextField(
                controller: _textController,
                style: PicoTypography.bodyMd.copyWith(color: PicoColors.textWhite),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Message league...',
                  hintStyle: PicoTypography.bodyMd.copyWith(
                    color: PicoColors.textWhiteMuted,
                    fontSize: 14.0,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          // Send Button
          InkWell(
            onTap: _isSending ? null : _sendMessage,
            borderRadius: BorderRadius.circular(24.0),
            child: Container(
              width: 44.0,
              height: 44.0,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00C853)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3300E676),
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _isSending
                  ? const Center(
                      child: SizedBox(
                        width: 18.0,
                        height: 18.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Color(0xFF09140E),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.send_rounded,
                        color: Color(0xFF09140E),
                        size: 20.0,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
