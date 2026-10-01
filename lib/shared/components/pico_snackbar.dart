import 'package:flutter/material.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';

/// Standardized tactile, high-contrast floating SnackBar component.
///
/// Ensures all alerts and feedback use clear, light backgrounds that stand out
/// distinctly on top of Pico's dark stadium pitch canvas.
abstract final class PicoSnackBar {
  /// Displays a success SnackBar with a clear light background and crisp ink text.
  static void showSuccess(
    BuildContext context,
    String message, {
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      createSuccessSnackBar(
        message: message,
        subtitle: subtitle,
        duration: duration,
      ),
    );
  }

  /// Displays an error SnackBar with a clear soft-rose/white background and high-visibility text.
  static void showError(
    BuildContext context,
    String message, {
    String? subtitle,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      createErrorSnackBar(
        message: message,
        subtitle: subtitle,
        duration: duration,
      ),
    );
  }

  /// Displays an informational SnackBar with a clear light background.
  static void showInfo(
    BuildContext context,
    String message, {
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      createInfoSnackBar(
        message: message,
        subtitle: subtitle,
        duration: duration,
      ),
    );
  }

  /// Builds a success [SnackBar] with clear white background and vivid green accents.
  static SnackBar createSuccessSnackBar({
    required String message,
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
  }) {
    return _buildCustomSnackBar(
      message: message,
      subtitle: subtitle,
      duration: duration,
      backgroundColor: PicoColors.snackBarSurface,
      borderColor: const Color(0xFFE2DDD2),
      icon: Icons.check_circle_rounded,
      iconColor: const Color(0xFF16A34A),
      iconBackgroundColor: const Color(0xFFDCFCE7),
      textColor: PicoColors.snackBarText,
    );
  }

  /// Builds an error [SnackBar] with clear soft-rose/white background and vivid red accents.
  static SnackBar createErrorSnackBar({
    required String message,
    String? subtitle,
    Duration duration = const Duration(seconds: 4),
  }) {
    return _buildCustomSnackBar(
      message: message,
      subtitle: subtitle,
      duration: duration,
      backgroundColor: PicoColors.snackBarErrorSurface,
      borderColor: const Color(0xFFFECACA),
      icon: Icons.error_outline_rounded,
      iconColor: const Color(0xFFDC2626),
      iconBackgroundColor: const Color(0xFFFEE2E2),
      textColor: PicoColors.snackBarErrorText,
    );
  }

  /// Builds an informational [SnackBar] with clear white background and blue accents.
  static SnackBar createInfoSnackBar({
    required String message,
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
  }) {
    return _buildCustomSnackBar(
      message: message,
      subtitle: subtitle,
      duration: duration,
      backgroundColor: PicoColors.snackBarSurface,
      borderColor: const Color(0xFFE2DDD2),
      icon: Icons.info_outline_rounded,
      iconColor: const Color(0xFF2563EB),
      iconBackgroundColor: const Color(0xFFDBEAFE),
      textColor: PicoColors.snackBarText,
    );
  }

  static SnackBar _buildCustomSnackBar({
    required String message,
    String? subtitle,
    required Duration duration,
    required Color backgroundColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required Color textColor,
  }) {
    return SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: duration,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      padding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 6),
              blurRadius: 18.0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34.0,
              height: 34.0,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 20.0),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: PicoTypography.titleCard.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle,
                      style: PicoTypography.bodySm.copyWith(
                        color: PicoColors.textTactileMuted,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
