import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/services/ad_consent_service.dart';
import 'package:pico/shared/components/in_app_web_browser_screen.dart';
import 'package:pico/shared/components/pico_app_bar.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
import 'package:url_launcher/url_launcher.dart';

/// Help & Support Hub featuring gamified options for:
/// 1. How to Play (In-App Browser)
/// 2. Terms & Conditions (In-App Browser)
/// 3. Privacy Policy (In-App Browser)
/// 4. Ad Choices & Privacy (Google UMP GDPR/CPRA consent management when required)
/// 5. Contact Us (Direct mailto: launcher)
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  static const String contactEmail = 'thevinatech.contact@gmail.com';
  static const String emailSubject = 'Pico App Support Request';

  // Placeholder URLs for in-app browser
  static const String howToPlayUrl = 'https://example.com/how-to-play';
  static const String termsUrl = 'https://example.com/terms';
  static const String privacyUrl = 'https://example.com/privacy';

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
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

  Future<void> _handleContactUs(BuildContext context) async {
    HapticFeedback.lightImpact();
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: HelpSupportScreen.contactEmail,
      queryParameters: {
        'subject': HelpSupportScreen.emailSubject,
      },
    );

    try {
      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF0F2B20),
            content: Text(
              'Could not open email client. Contact: ${HelpSupportScreen.contactEmail}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF0F2B20),
            content: Text(
              'Could not open email client. Contact: ${HelpSupportScreen.contactEmail}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  void _openWebPage(BuildContext context, String title, String url) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InAppWebBrowserScreen(title: title, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titleText = l10n?.helpAndSupportTitle ?? 'Help & Support';

    return PicoPitchBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PicoAppBar(
          title: titleText,
          showBackButton: true,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440.0),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
                children: [
                  // 1. Header Atmosphere Card
                  _buildAtmosphereHero(context),
                  const SizedBox(height: 18.0),

                  // 2. Options List
                  // Option 1: How to Play
                  _SupportOptionCard(
                    key: const Key('help_option_how_to_play'),
                    title: 'How to Play',
                    subtitle: 'Rules, scoring breakdown & XP progression',
                    icon: Icons.sports_soccer_rounded,
                    iconColor: const Color(0xFF34D399),
                    badgeBgColor: const Color(0x2610B981),
                    badgeBorderColor: const Color(0x4D34D399),
                    onTap: () => _openWebPage(
                      context,
                      'How to Play',
                      HelpSupportScreen.howToPlayUrl,
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Option 2: Terms & Conditions
                  _SupportOptionCard(
                    key: const Key('help_option_terms'),
                    title: 'Terms & Conditions',
                    subtitle: 'Terms of service and fair play guidelines',
                    icon: Icons.description_rounded,
                    iconColor: const Color(0xFF38BDF8),
                    badgeBgColor: const Color(0x260284C7),
                    badgeBorderColor: const Color(0x4D38BDF8),
                    onTap: () => _openWebPage(
                      context,
                      'Terms & Conditions',
                      HelpSupportScreen.termsUrl,
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Option 3: Privacy Policy
                  _SupportOptionCard(
                    key: const Key('help_option_privacy'),
                    title: 'Privacy Policy',
                    subtitle: 'How your account data and info are protected',
                    icon: Icons.privacy_tip_rounded,
                    iconColor: const Color(0xFFA78BFA),
                    badgeBgColor: const Color(0x267C3AED),
                    badgeBorderColor: const Color(0x4DA78BFA),
                    onTap: () => _openWebPage(
                      context,
                      'Privacy Policy',
                      HelpSupportScreen.privacyUrl,
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Option 4 (GDPR / CPRA Conditional): Ad Choices & Privacy Settings
                  if (_isPrivacyOptionsRequired) ...[
                    _SupportOptionCard(
                      key: const Key('help_option_ad_choices'),
                      title: l10n?.adChoicesTitle ?? 'Ad Choices & Privacy',
                      subtitle: l10n?.adChoicesSubtitle ??
                          'Review or change your ad personalization consent',
                      icon: Icons.tune_rounded,
                      iconColor: const Color(0xFFF43F5E),
                      badgeBgColor: const Color(0x26F43F5E),
                      badgeBorderColor: const Color(0x4DF43F5E),
                      onTap: _handleAdChoices,
                    ),
                    const SizedBox(height: 12.0),
                  ],

                  // Option 5: Contact Us
                  _SupportOptionCard(
                    key: const Key('help_option_contact_us'),
                    title: 'Contact Us',
                    subtitle: 'Email our team: ${HelpSupportScreen.contactEmail}',
                    icon: Icons.mail_rounded,
                    iconColor: const Color(0xFFFBBF24),
                    badgeBgColor: const Color(0x26D97706),
                    badgeBorderColor: const Color(0x4DFBBF24),
                    onTap: () => _handleContactUs(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAtmosphereHero(BuildContext context) {
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
                  blurRadius: 8.0,
                ),
              ],
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 28.0,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pico Support Center',
                  style: PicoTypography.headlineMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  'Everything you need for rules, policies, and direct developer support.',
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 11.5,
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

class _SupportOptionCard extends StatefulWidget {
  const _SupportOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.badgeBgColor,
    required this.badgeBorderColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color badgeBgColor;
  final Color badgeBorderColor;
  final VoidCallback onTap;

  @override
  State<_SupportOptionCard> createState() => _SupportOptionCardState();
}

class _SupportOptionCardState extends State<_SupportOptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bevel = 3.0;
    final double translationY = _isPressed ? bevel : 0.0;
    final double currentBevel = _isPressed ? 0.0 : bevel;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
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
            color: const Color(0x3310B981),
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
                      color: Colors.white,
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
