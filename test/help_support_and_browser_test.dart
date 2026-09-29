// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/profile/presentation/help_support_screen.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/in_app_web_browser_screen.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _FakeUrlLauncherPlatform extends UrlLauncherPlatform {
  String? launchedUrl;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = url;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildSubject(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  group('HelpSupportScreen Tests', () {
    late _FakeUrlLauncherPlatform fakeUrlLauncher;

    setUp(() {
      fakeUrlLauncher = _FakeUrlLauncherPlatform();
      UrlLauncherPlatform.instance = fakeUrlLauncher;
    });

    testWidgets('renders all 4 gamified support options and hero card',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject(const HelpSupportScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Pico Support Center'), findsOneWidget);

      expect(find.byKey(const Key('help_option_how_to_play')), findsOneWidget);
      expect(find.text('How to Play'), findsOneWidget);

      expect(find.byKey(const Key('help_option_terms')), findsOneWidget);
      expect(find.text('Terms & Conditions'), findsOneWidget);

      expect(find.byKey(const Key('help_option_privacy')), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);

      expect(find.byKey(const Key('help_option_contact_us')), findsOneWidget);
      expect(find.text('Contact Us'), findsOneWidget);
      expect(find.text('Email our team: thevinatech.contact@gmail.com'), findsOneWidget);
    });

    testWidgets('tapping "How to Play" navigates to InAppWebBrowserScreen with howToPlayUrl',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject(const HelpSupportScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('help_option_how_to_play')));
      await tester.pumpAndSettle();

      expect(find.byType(InAppWebBrowserScreen), findsOneWidget);
      final browser = tester.widget<InAppWebBrowserScreen>(
        find.byType(InAppWebBrowserScreen),
      );
      expect(browser.title, 'How to Play');
      expect(browser.url, HelpSupportScreen.howToPlayUrl);
    });

    testWidgets('tapping "Terms & Conditions" navigates to InAppWebBrowserScreen with termsUrl',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject(const HelpSupportScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('help_option_terms')));
      await tester.pumpAndSettle();

      expect(find.byType(InAppWebBrowserScreen), findsOneWidget);
      final browser = tester.widget<InAppWebBrowserScreen>(
        find.byType(InAppWebBrowserScreen),
      );
      expect(browser.title, 'Terms & Conditions');
      expect(browser.url, HelpSupportScreen.termsUrl);
    });

    testWidgets('tapping "Privacy Policy" navigates to InAppWebBrowserScreen with privacyUrl',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject(const HelpSupportScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('help_option_privacy')));
      await tester.pumpAndSettle();

      expect(find.byType(InAppWebBrowserScreen), findsOneWidget);
      final browser = tester.widget<InAppWebBrowserScreen>(
        find.byType(InAppWebBrowserScreen),
      );
      expect(browser.title, 'Privacy Policy');
      expect(browser.url, HelpSupportScreen.privacyUrl);
    });

    testWidgets('tapping "Contact Us" launches mailto with correct email and subject',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject(const HelpSupportScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('help_option_contact_us')));
      await tester.pumpAndSettle();

      expect(fakeUrlLauncher.launchedUrl, isNotNull);
      expect(fakeUrlLauncher.launchedUrl, contains('mailto:thevinatech.contact@gmail.com'));
      expect(
        fakeUrlLauncher.launchedUrl,
        anyOf(
          contains('Pico+App+Support+Request'),
          contains('Pico%20App%20Support%20Request'),
        ),
      );
    });
  });

  group('InAppWebBrowserScreen Tests', () {
    testWidgets('renders gamified AppBar with title, back button, and refresh action',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildSubject(
          const InAppWebBrowserScreen(
            title: 'Privacy Policy',
            url: 'https://example.com/privacy',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Privacy Policy'), findsWidgets);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });
  });
}
