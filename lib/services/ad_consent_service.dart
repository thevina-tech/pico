import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pico/core/logging/app_logger.dart';

/// Singleton service managing GDPR and CPRA compliance via Google's
/// User Messaging Platform (UMP) integrated in the Google Mobile Ads SDK.
///
/// Responsibilities:
/// 1. Configures [ConsentRequestParameters] with testing geography in debug mode.
/// 2. Requests consent info updates via [ConsentInformation.instance.requestConsentInfoUpdate].
/// 3. Presents the consent form via [ConsentForm.loadAndShowConsentFormIfRequired].
/// 4. Checks [ConsentInformation.instance.canRequestAds] and initializes AdMob safely without redundancy.
/// 5. Evaluates [ConsentInformation.instance.getPrivacyOptionsRequirementStatus] and exposes
///    [showPrivacyOptionsForm] for the user to revoke or modify consent at any time.
class AdConsentService {
  AdConsentService._();

  static final AdConsentService _instance = AdConsentService._();
  static AdConsentService get instance => _instance;

  /// Default hashed test device ID for local testing on physical devices.
  static const String defaultTestDeviceId = 'D278E4C65E15EFC68E915591529113EF';

  bool _isMobileAdsInitializeCalled = false;
  bool get isMobileAdsInitializeCalled => _isMobileAdsInitializeCalled;

  /// Optional testing overrides for deterministic unit and widget testing.
  @visibleForTesting
  bool? isPrivacyOptionsRequiredOverride;

  @visibleForTesting
  bool? canRequestAdsOverride;

  /// Returns true when running under the Flutter test runner.
  bool get isTestEnvironment {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  /// Gathers user consent via Google UMP and initializes Google Mobile Ads if allowed.
  Future<void> gatherConsent({
    String? testDeviceId,
    bool forceTesting = false,
  }) async {
    if (isTestEnvironment) {
      AppLogger.info('AdConsentService: Skipping UMP in test environment');
      if (canRequestAdsOverride == true) {
        await initializeMobileAdsIfAllowed();
      }
      return;
    }

    final completer = Completer<void>();

    try {
      // In local testing/debug mode, use DebugGeography.debugGeographyEea to force GDPR dialog
      final debugSettings = (forceTesting || !kReleaseMode)
          ? ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea,
              testIdentifiers: [testDeviceId ?? defaultTestDeviceId],
            )
          : null;

      final params = ConsentRequestParameters(
        consentDebugSettings: debugSettings,
      );

      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          AppLogger.info('AdConsentService: Consent info update received');
          try {
            ConsentForm.loadAndShowConsentFormIfRequired(
              (FormError? formError) async {
                if (formError != null) {
                  AppLogger.warning(
                    'AdConsentService: Consent form error (${formError.errorCode}): ${formError.message}',
                  );
                } else {
                  AppLogger.info('AdConsentService: Consent form flow completed successfully');
                }
                await initializeMobileAdsIfAllowed();
                if (!completer.isCompleted) completer.complete();
              },
            );
          } catch (e, st) {
            AppLogger.error('AdConsentService: Failed to load/show consent form', e, st);
            await initializeMobileAdsIfAllowed();
            if (!completer.isCompleted) completer.complete();
          }
        },
        (FormError error) async {
          AppLogger.warning(
            'AdConsentService: Consent info update failed (${error.errorCode}): ${error.message}',
          );
          // In error scenarios (e.g. offline), safely attempt initialization if cached consent allows
          await initializeMobileAdsIfAllowed();
          if (!completer.isCompleted) completer.complete();
        },
      );
    } catch (e, st) {
      AppLogger.error('AdConsentService: Unexpected error requesting consent info', e, st);
      await initializeMobileAdsIfAllowed();
      if (!completer.isCompleted) completer.complete();
    }

    return completer.future;
  }

  /// Safely initializes Google Mobile Ads ONLY if [canRequestAds()] is true
  /// and AdMob has not yet been initialized.
  Future<bool> initializeMobileAdsIfAllowed() async {
    if (_isMobileAdsInitializeCalled) return true;

    if (isTestEnvironment && canRequestAdsOverride != true) {
      return false;
    }

    try {
      final canRequest = canRequestAdsOverride ??
          await ConsentInformation.instance.canRequestAds();

      if (canRequest && !_isMobileAdsInitializeCalled) {
        _isMobileAdsInitializeCalled = true;
        await MobileAds.instance.initialize();
        AppLogger.info('AdConsentService: Google Mobile Ads initialized successfully after consent verification');
        return true;
      } else {
        AppLogger.info(
          'AdConsentService: Ads cannot be requested yet (canRequestAds: $canRequest, alreadyInit: $_isMobileAdsInitializeCalled)',
        );
        return false;
      }
    } catch (e) {
      AppLogger.warning('AdConsentService: Error checking consent or initializing MobileAds: $e');
      return false;
    }
  }

  /// Checks whether privacy options (Ad Choices) must be offered to the user
  /// under GDPR/CPRA regulations.
  Future<bool> isPrivacyOptionsRequired() async {
    if (isPrivacyOptionsRequiredOverride != null) {
      return isPrivacyOptionsRequiredOverride!;
    }

    if (isTestEnvironment) {
      return false;
    }

    try {
      final status =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (e) {
      AppLogger.warning('AdConsentService: Failed to check privacy options status: $e');
      return false;
    }
  }

  /// Shows the Privacy Options (Ad Choices) form allowing the user to modify consent.
  Future<void> showPrivacyOptionsForm() async {
    if (isTestEnvironment) {
      AppLogger.info('AdConsentService: showPrivacyOptionsForm in test environment');
      return;
    }

    final completer = Completer<void>();
    try {
      ConsentForm.showPrivacyOptionsForm((FormError? formError) async {
        if (formError != null) {
          AppLogger.warning(
            'AdConsentService: showPrivacyOptionsForm error (${formError.errorCode}): ${formError.message}',
          );
        } else {
          AppLogger.info('AdConsentService: Privacy options updated by user');
        }
        // After user modifies options, check if ads can now be requested
        await initializeMobileAdsIfAllowed();
        if (!completer.isCompleted) completer.complete();
      });
    } catch (e, st) {
      AppLogger.error('AdConsentService: Failed to show privacy options form', e, st);
      if (!completer.isCompleted) completer.complete();
    }
    return completer.future;
  }

  /// Resets consent state (useful for testing or debugging).
  Future<void> resetConsent() async {
    if (isTestEnvironment) return;
    try {
      await ConsentInformation.instance.reset();
      _isMobileAdsInitializeCalled = false;
      AppLogger.info('AdConsentService: Consent state reset');
    } catch (e) {
      AppLogger.warning('AdConsentService: Failed to reset consent: $e');
    }
  }
}
