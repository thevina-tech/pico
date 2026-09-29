import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/profile/presentation/help_support_screen.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/services/ad_consent_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AdConsentService.instance.isPrivacyOptionsRequiredOverride = null;
    AdConsentService.instance.canRequestAdsOverride = null;
  });

  tearDown(() {
    AdConsentService.instance.isPrivacyOptionsRequiredOverride = null;
    AdConsentService.instance.canRequestAdsOverride = null;
  });

  group('Sprint 8: AdConsentService Unit Tests', () {
    test('Default test device ID matches configured test identifier', () {
      expect(AdConsentService.defaultTestDeviceId, 'D278E4C65E15EFC68E915591529113EF');
    });

    test('initializeMobileAdsIfAllowed returns false when ads cannot be requested', () async {
      AdConsentService.instance.canRequestAdsOverride = false;
      final result = await AdConsentService.instance.initializeMobileAdsIfAllowed();
      expect(result, isFalse);
    });

    test('isPrivacyOptionsRequired reflects testing override', () async {
      AdConsentService.instance.isPrivacyOptionsRequiredOverride = true;
      expect(await AdConsentService.instance.isPrivacyOptionsRequired(), isTrue);

      AdConsentService.instance.isPrivacyOptionsRequiredOverride = false;
      expect(await AdConsentService.instance.isPrivacyOptionsRequired(), isFalse);
    });

    test('gatherConsent and showPrivacyOptionsForm complete safely in test environment', () async {
      await expectLater(AdConsentService.instance.gatherConsent(), completes);
      await expectLater(AdConsentService.instance.showPrivacyOptionsForm(), completes);
    });
  });

  group('Sprint 8: HelpSupportScreen Ad Choices Option Tests', () {
    Widget buildSubject() {
      return const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HelpSupportScreen(),
      );
    }

    testWidgets('Does not display Ad Choices option when privacy options are not required',
        (WidgetTester tester) async {
      AdConsentService.instance.isPrivacyOptionsRequiredOverride = false;

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('help_option_how_to_play')), findsOneWidget);
      expect(find.byKey(const Key('help_option_terms')), findsOneWidget);
      expect(find.byKey(const Key('help_option_privacy')), findsOneWidget);
      expect(find.byKey(const Key('help_option_contact_us')), findsOneWidget);

      // Ad Choices must NOT be visible
      expect(find.byKey(const Key('help_option_ad_choices')), findsNothing);
      expect(find.text('Ad Choices & Privacy'), findsNothing);
    });

    testWidgets('Displays Ad Choices option card when privacy options are required by GDPR/CPRA',
        (WidgetTester tester) async {
      AdConsentService.instance.isPrivacyOptionsRequiredOverride = true;

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // All standard cards are visible
      expect(find.byKey(const Key('help_option_how_to_play')), findsOneWidget);
      expect(find.byKey(const Key('help_option_terms')), findsOneWidget);
      expect(find.byKey(const Key('help_option_privacy')), findsOneWidget);
      expect(find.byKey(const Key('help_option_contact_us')), findsOneWidget);

      // Ad Choices IS visible
      final adChoicesFinder = find.byKey(const Key('help_option_ad_choices'));
      expect(adChoicesFinder, findsOneWidget);
      expect(find.text('Ad Choices & Privacy'), findsOneWidget);
      expect(find.text('Review or change your ad personalization consent'), findsOneWidget);

      // Tap Ad Choices option
      await tester.tap(adChoicesFinder);
      await tester.pumpAndSettle();
    });
  });
}
