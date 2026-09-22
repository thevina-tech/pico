import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/tournaments/domain/private_league_exceptions.dart';
import 'package:pico/features/tournaments/presentation/private_league_controller.dart';
import 'package:pico/l10n/app_localizations.dart';

/// Screen allowing users to join an existing Private League via a 6-character code.
class JoinPrivateLeagueScreen extends ConsumerStatefulWidget {
  const JoinPrivateLeagueScreen({super.key});

  @override
  ConsumerState<JoinPrivateLeagueScreen> createState() =>
      _JoinPrivateLeagueScreenState();
}

class _JoinPrivateLeagueScreenState
    extends ConsumerState<JoinPrivateLeagueScreen> {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto-focus the input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null && text.isNotEmpty) {
      // Extract first 6 uppercase alphanumeric characters
      final clean = text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      final code = clean.length > 6 ? clean.substring(0, 6) : clean;
      _codeController.text = code;
      setState(() {
        _errorMessage = null;
      });
      if (code.length == 6) {
        _handleJoin();
      }
    }
  }

  Future<void> _handleJoin() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() {
        _errorMessage = l10n.leagueCodeFormatError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final joinedLeague = await ref
          .read(privateLeagueControllerProvider.notifier)
          .joinLeague(inviteCode: code);

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.leagueJoinedSuccessSubtitle(joinedLeague.name),
          ),
          backgroundColor: PicoColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back to Tournaments
      context.pop();
    } catch (e) {
      if (!mounted) return;
      String errorDisplay;
      if (e is LeagueNotFoundException) {
        errorDisplay = l10n.invalidLeagueCodeError;
      } else if (e is LeagueCreatorCannotRejoinException) {
        errorDisplay = l10n.creatorCannotRejoinError;
      } else if (e is LeagueAlreadyMemberException) {
        errorDisplay = l10n.alreadyMemberOfLeagueError;
      } else {
        final raw = e.toString().toLowerCase();
        if (raw.contains('creator_cannot_rejoin') || raw.contains('creator')) {
          errorDisplay = l10n.creatorCannotRejoinError;
        } else if (raw.contains('already_member') ||
            raw.contains('already a member') ||
            raw.contains('already')) {
          errorDisplay = l10n.alreadyMemberOfLeagueError;
        } else if (raw.contains('league_not_found') ||
            raw.contains('no league found') ||
            raw.contains('invalid invite code') ||
            raw.contains('invalid')) {
          errorDisplay = l10n.invalidLeagueCodeError;
        } else {
          errorDisplay = l10n.invalidLeagueCodeError;
        }
      }

      setState(() {
        _isLoading = false;
        _errorMessage = errorDisplay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentCode = _codeController.text.toUpperCase();

    return Scaffold(
      backgroundColor: PicoColors.pitchBackground,
      appBar: AppBar(
        backgroundColor: PicoColors.darkTray,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: PicoColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.joinPrivateLeagueTitle,
          style: PicoTypography.headlineMd.copyWith(
            color: PicoColors.textWhite,
            fontWeight: FontWeight.w700,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: PicoColors.textWhiteMuted),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440.0),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
              children: [
                // Atmosphere Hero Card
                _buildHeroHeader(l10n),
                const SizedBox(height: 20.0),

                // Code Input Card
                Container(
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: PicoColors.darkTray,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Paste Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.pin_rounded,
                                size: 16.0,
                                color: PicoColors.primary,
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                l10n.enterLeagueCodeLabel,
                                style: PicoTypography.labelPillSm.copyWith(
                                  color: PicoColors.textWhiteMuted,
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          // Paste button
                          InkWell(
                            onTap: _handlePaste,
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: PicoColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: PicoColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.content_paste_rounded,
                                    size: 13.0,
                                    color: PicoColors.primary,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    l10n.pasteCode,
                                    style: PicoTypography.bodySm.copyWith(
                                      color: PicoColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Segmented 6-Box Character Display (Tap to type)
                      GestureDetector(
                        onTap: () => _focusNode.requestFocus(),
                        child: _buildSegmentedDisplay(currentCode),
                      ),

                      // Off-screen TextField capturing keyboard input
                      Opacity(
                        opacity: 0.0,
                        child: SizedBox(
                          height: 1.0,
                          child: TextField(
                            controller: _codeController,
                            focusNode: _focusNode,
                            maxLength: 6,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]'),
                              ),
                              UpperCaseTextFormatter(),
                            ],
                            onChanged: (_) {
                              setState(() {
                                _errorMessage = null;
                              });
                            },
                            onSubmitted: (_) => _handleJoin(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Error Banner if any
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: PicoColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: PicoColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: PicoColors.error,
                          size: 18.0,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: PicoTypography.bodySm.copyWith(
                              color: PicoColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],

                // Join CTA Button (Tactile Gold Button)
                ElevatedButton(
                  onPressed: _isLoading || currentCode.length != 6
                      ? null
                      : _handleJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PicoColors.gold,
                    foregroundColor: const Color(0xFF261A00),
                    disabledBackgroundColor:
                        PicoColors.gold.withValues(alpha: 0.3),
                    disabledForegroundColor:
                        const Color(0xFF261A00).withValues(alpha: 0.4),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22.0,
                          width: 22.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xFF261A00)),
                          ),
                        )
                      : Text(
                          l10n.joinLeagueButton,
                          style: PicoTypography.titleCard.copyWith(
                            color: const Color(0xFF261A00),
                            fontWeight: FontWeight.w800,
                            fontSize: 16.0,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1A12),
            Color(0xFF0D2319),
            Color(0xFF050D09),
          ],
        ),
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: PicoColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF020604),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: const Color(0xFF143322),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: PicoColors.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF00381E),
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.vpn_key_rounded,
              color: PicoColors.primary,
              size: 24.0,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: const BoxDecoration(
                        color: PicoColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      l10n.friendsAndColleaguesBadge,
                      style: PicoTypography.labelPillSm.copyWith(
                        color: PicoColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3.0),
                Text(
                  l10n.privateCommunitySubtitle,
                  style: PicoTypography.headlineMd.copyWith(
                    color: PicoColors.textWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 17.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedDisplay(String currentCode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B13),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (index) {
          final hasChar = index < currentCode.length;
          final isCurrent = index == currentCode.length;
          final char = hasChar ? currentCode[index] : '';

          return Container(
            width: 44.0,
            height: 52.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              color: isCurrent
                  ? PicoColors.primary.withValues(alpha: 0.15)
                  : const Color(0xFF14261C),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: isCurrent
                    ? PicoColors.primary
                    : (hasChar
                        ? PicoColors.primary.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.1)),
                width: isCurrent ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isCurrent
                      ? const Color(0xFF00522C)
                      : const Color(0x33000000),
                  offset: const Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: hasChar
                ? Text(
                    char,
                    style: PicoTypography.headlineLgMobile.copyWith(
                      color: PicoColors.textWhite,
                      fontWeight: FontWeight.w800,
                      fontSize: 22.0,
                    ),
                  )
                : (isCurrent
                    ? Container(
                        width: 2.0,
                        height: 22.0,
                        decoration: BoxDecoration(
                          color: PicoColors.primary,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      )
                    : null),
          );
        }),
      ),
    );
  }
}

/// Formatter that automatically converts all characters to uppercase.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
