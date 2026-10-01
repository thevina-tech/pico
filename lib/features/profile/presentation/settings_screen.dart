import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/network/supabase_client_provider.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/services/ad_consent_service.dart';
import 'package:pico/shared/components/pico_app_bar.dart';
import 'package:pico/shared/components/pico_confirmation_modal.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
import 'package:pico/shared/components/pico_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Settings Hub offering user controls for:
/// 1. Sign Out (terminates session & routes to login/onboarding)
/// 2. Delete Account (destructive confirmation & secure backend RPC user deletion)
/// 3. Ad Choices & Privacy (Google UMP GDPR/CPRA consent management when required)
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isProcessing = false;
  bool _isPrivacyOptionsRequired = false;

  @override
  void initState() {
    super.initState();
    _checkPrivacyOptionsStatus();
  }

  Future<void> _checkPrivacyOptionsStatus() async {
    final isRequired = await AdConsentService.instance.isPrivacyOptionsRequired();
    if (mounted) {
      setState(() => _isPrivacyOptionsRequired = isRequired);
    }
  }

  Future<void> _handleAdChoices() async {
    HapticFeedback.lightImpact();
    await AdConsentService.instance.showPrivacyOptionsForm();
    if (mounted) {
      _checkPrivacyOptionsStatus();
    }
  }

  Future<void> _handleSignOut() async {
    HapticFeedback.lightImpact();
    setState(() => _isProcessing = true);
    final authNotifier = ref.read(authProvider.notifier);
    try {
      await authNotifier.signOut();
      if (mounted) {
        try {
          context.go('/onboarding');
        } catch (_) {
          Navigator.of(context).maybePop();
        }
      }
    } catch (e, st) {
      AppLogger.error('Failed to sign out', e, st);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        PicoSnackBar.showError(
          context,
          l10n?.signOutFailed(e.toString()) ?? 'Sign out failed: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleDeleteAccount(AppLocalizations? l10n) async {
    HapticFeedback.mediumImpact();

    final confirmed = await showPicoConfirmationModal(
      context: context,
      title: l10n?.deleteAccountConfirmTitle ?? 'Delete Account?',
      message: l10n?.deleteAccountConfirmBody ??
          'Are you sure? This will permanently delete your predictions, league memberships, and account data. This cannot be undone.',
      confirmText: l10n?.deleteAccountAction ?? 'Delete Account',
      cancelText: l10n?.cancelButton ?? 'Cancel',
      confirmStyle: PicoDialogButtonStyle.red,
      cancelStyle: PicoDialogButtonStyle.neutral,
      confirmKey: const Key('confirm_delete_account_button'),
      cancelKey: const Key('cancel_delete_account_button'),
      customIcon: Container(
        width: 52.0,
        height: 52.0,
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color(0xFFFCA5A5),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.delete_forever_rounded,
          color: Color(0xFFDC2626),
          size: 30.0,
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    final authNotifier = ref.read(authProvider.notifier);
    SupabaseClient? supabase = ref.read(supabaseClientProvider);
    if (supabase == null) {
      try {
        supabase = Supabase.instance.client;
      } catch (_) {}
    }

    try {
      // 1. Call secure backend RPC function to delete from auth.users (cascading all data)
      if (supabase != null) {
        await supabase.rpc('delete_user_account');
      }

      // 2. Clear local auth session in Riverpod & sign out from Supabase and Google
      await authNotifier.signOut();

      if (mounted) {
        PicoSnackBar.showSuccess(
          context,
          l10n?.accountDeletedToast ?? 'Your account has been deleted.',
        );
        try {
          context.go('/onboarding');
        } catch (_) {
          Navigator.of(context).maybePop();
        }
      }
    } catch (e, st) {
      AppLogger.error('Failed to execute account deletion', e, st);
      if (mounted) {
        PicoSnackBar.showError(
          context,
          l10n?.deleteAccountError ?? 'Failed to delete account. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titleText = l10n?.settingsTitle ?? 'Settings';

    return PicoPitchBackground(
      imageAsset: 'assets/images/main_background.png',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PicoAppBar(
          title: titleText,
          showBackButton: true,
          isTransparent: true,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440.0),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 32.0),
                    children: [
                      // Atmosphere Card
                      _buildAtmosphereCard(l10n),
                      const SizedBox(height: 18.0),

                      // Section Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          (l10n?.accountSettingsAria ?? 'Account Settings').toUpperCase(),
                          style: PicoTypography.labelPillSm.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // Option 1: Sign Out
                      _SettingsOptionCard(
                        key: const Key('settings_sign_out_tile'),
                        title: l10n?.signOutButton ?? 'Sign Out',
                        subtitle: l10n?.signOutSubtitle ?? 'Log out of your Pico session',
                        icon: Icons.logout_rounded,
                        iconColor: const Color(0xFFFBBF24),
                        badgeBgColor: const Color(0x26D97706),
                        badgeBorderColor: const Color(0x4DFBBF24),
                        onTap: _isProcessing ? null : _handleSignOut,
                      ),
                      const SizedBox(height: 14.0),

                      // Option 2: Delete Account (Severe & Destructive)
                      _SettingsOptionCard(
                        key: const Key('settings_delete_account_tile'),
                        title: l10n?.deleteAccountOption ?? 'Delete Account',
                        subtitle: l10n?.deleteAccountSubtitle ??
                            'Permanently remove your account and data',
                        icon: Icons.delete_forever_rounded,
                        iconColor: const Color(0xFFEF4444),
                        badgeBgColor: const Color(0x33EF4444),
                        badgeBorderColor: const Color(0x66EF4444),
                        cardBorderColor: const Color(0x4DEF4444),
                        titleColor: const Color(0xFFFCA5A5),
                        onTap: _isProcessing ? null : () => _handleDeleteAccount(l10n),
                      ),

                      // Option 3 (GDPR/CPRA Conditional): Ad Choices & Privacy
                      if (_isPrivacyOptionsRequired) ...[
                        const SizedBox(height: 14.0),
                        _SettingsOptionCard(
                          key: const Key('settings_ad_choices_tile'),
                          title: l10n?.adChoicesTitle ?? 'Ad Choices & Privacy',
                          subtitle: l10n?.adChoicesSubtitle ??
                              'Review or change your ad personalization consent',
                          icon: Icons.tune_rounded,
                          iconColor: const Color(0xFF38BDF8),
                          badgeBgColor: const Color(0x260284C7),
                          badgeBorderColor: const Color(0x4D38BDF8),
                          onTap: _isProcessing ? null : _handleAdChoices,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (_isProcessing)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAtmosphereCard(AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F3224),
            Color(0xFF0A2218),
            Color(0xFF06140E),
          ],
        ),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0x4D10B981),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF020906),
            offset: Offset(0, 4.0),
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
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(14.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D10B981),
                  offset: Offset(0, 3.0),
                  blurRadius: 6.0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 26.0,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.settingsTitle ?? 'Settings',
                  style: PicoTypography.headlineMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  l10n?.settingsSubtitle ?? 'Account, sign out & preferences',
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFF6EE7B7),
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
}

/// 3D Tactile Card for Settings options.
class _SettingsOptionCard extends StatefulWidget {
  const _SettingsOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.badgeBgColor,
    required this.badgeBorderColor,
    this.cardBorderColor,
    this.titleColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color badgeBgColor;
  final Color badgeBorderColor;
  final Color? cardBorderColor;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  State<_SettingsOptionCard> createState() => _SettingsOptionCardState();
}

class _SettingsOptionCardState extends State<_SettingsOptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bevel = 4.0;
    final double translationY = _isPressed ? bevel : 0.0;
    final double currentBevel = _isPressed ? 0.0 : bevel;

    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(
          top: translationY,
          bottom: bevel - translationY,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0D251C),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: widget.cardBorderColor ?? const Color(0x3310B981),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF040F0B),
              offset: Offset(0, currentBevel),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            // Illuminated badge container
            Container(
              width: 42.0,
              height: 42.0,
              decoration: BoxDecoration(
                color: widget.badgeBgColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: widget.badgeBorderColor,
                  width: 1.0,
                ),
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: 22.0,
              ),
            ),
            const SizedBox(width: 14.0),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: PicoTypography.headlineMd.copyWith(
                      color: widget.titleColor ?? Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    widget.subtitle,
                    style: PicoTypography.bodySm.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 22.0,
            ),
          ],
        ),
      ),
    );
  }
}
