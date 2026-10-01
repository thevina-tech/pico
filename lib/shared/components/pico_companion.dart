import 'package:flutter/material.dart';
import '../../core/theme/pico_colors.dart';
import '../../core/theme/pico_typography.dart';

/// Supported club kits for the Pico mascot.
enum PicoTeamKit {
  realMadrid('pico_real_madrid.png', 'Real Madrid'),
  barcelona('pico_barcelona.png', 'Barcelona'),
  manchesterUnited('pico_manchester_united.png', 'Manchester United'),
  chelsea('pico_chelsea.png', 'Chelsea'),
  liverpool('pico_liverpool.png', 'Liverpool'),
  juventus('pico_juventus.png', 'Juventus'),
  acMilan('pico_ac_milan.png', 'AC Milan'),
  interMilan('pico_inter_milan.png', 'Inter Milan'),
  arsenal('pico_arsenal.png', 'Arsenal'),
  bayernMunich('pico_bayern_munich.png', 'Bayern Munich');

  const PicoTeamKit(this.assetFile, this.displayName);
  final String assetFile;
  final String displayName;
}

/// The official Pico mascot component ('Pico' the football companion).
/// Supports standing hero pose, circular avatar, squircle app icon,
/// and team kit variations with optional speech bubbles.
class PicoCompanion extends StatelessWidget {
  const PicoCompanion.standing({
    super.key,
    this.height = 180.0,
    this.speechBubbleText,
    this.onTap,
  })  : _type = _PicoDisplayType.standing,
        size = null,
        teamKit = null;

  const PicoCompanion.avatar({
    super.key,
    this.size = 44.0,
    this.onTap,
  })  : _type = _PicoDisplayType.avatar,
        height = null,
        speechBubbleText = null,
        teamKit = null;

  const PicoCompanion.appIcon({
    super.key,
    this.size = 64.0,
    this.onTap,
  })  : _type = _PicoDisplayType.appIcon,
        height = null,
        speechBubbleText = null,
        teamKit = null;

  const PicoCompanion.teamKit({
    super.key,
    required this.teamKit,
    this.height = 140.0,
    this.speechBubbleText,
    this.onTap,
  })  : _type = _PicoDisplayType.teamKit,
        size = null;

  final _PicoDisplayType _type;
  final double? height;
  final double? size;
  final String? speechBubbleText;
  final PicoTeamKit? teamKit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (_type) {
      case _PicoDisplayType.standing:
        content = _buildStandingHero();
        break;
      case _PicoDisplayType.avatar:
        content = _buildAvatar();
        break;
      case _PicoDisplayType.appIcon:
        content = _buildAppIcon();
        break;
      case _PicoDisplayType.teamKit:
        content = _buildTeamKit();
        break;
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }

  Widget _buildStandingHero() {
    final imageWidget = Image.asset(
      'assets/images/pico_standing.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => _buildPlaceholder(height ?? 180, (height ?? 180) * 0.6),
    );

    if (speechBubbleText == null) {
      return imageWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSpeechBubble(speechBubbleText!),
        const SizedBox(height: 8.0),
        imageWidget,
      ],
    );
  }

  Widget _buildAvatar() {
    final s = size ?? 44.0;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: PicoColors.primaryContainer,
        border: Border.all(color: PicoColors.primaryFixedDim, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/pico_avatar.png',
          width: s,
          height: s,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _buildPlaceholder(s, s),
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    final s = size ?? 64.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(s * 0.22),
      child: Image.asset(
        'assets/images/pico_app_icon.png',
        width: s,
        height: s,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(s, s),
      ),
    );
  }

  Widget _buildTeamKit() {
    final kit = teamKit ?? PicoTeamKit.realMadrid;
    final imageWidget = Image.asset(
      'assets/images/${kit.assetFile}',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => _buildPlaceholder(height ?? 140, (height ?? 140) * 0.5),
    );

    if (speechBubbleText == null) {
      return imageWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSpeechBubble(speechBubbleText!),
        const SizedBox(height: 8.0),
        imageWidget,
      ],
    );
  }

  Widget _buildSpeechBubble(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      constraints: const BoxConstraints(maxWidth: 220),
      decoration: BoxDecoration(
        color: PicoColors.cardFace,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: PicoColors.cardBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A000000),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: PicoTypography.labelPill.copyWith(
          color: PicoColors.textPitchInk,
          fontSize: 12.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(double h, double w) {
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: PicoColors.cardFace,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PicoColors.primaryFixedDim),
      ),
      child: const Center(
        child: Icon(Icons.sports_soccer, color: PicoColors.primary, size: 28),
      ),
    );
  }
}

enum _PicoDisplayType {
  standing,
  avatar,
  appIcon,
  teamKit,
}
