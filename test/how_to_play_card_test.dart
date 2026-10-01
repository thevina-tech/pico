import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/profile/presentation/help_support_screen.dart';
import 'package:pico/shared/components/how_to_play_card.dart';
import 'package:pico/shared/components/in_app_web_browser_screen.dart';

void main() {
  group('HowToPlayCard Widget Tests', () {
    testWidgets('renders all visual elements according to specification',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HowToPlayCard(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify container and card key
      expect(find.byKey(const Key('how_to_play_card')), findsOneWidget);

      // 2. Verify text hierarchy
      expect(find.text('MANUAL'), findsOneWidget);
      expect(find.text('How to Play'), findsOneWidget);
      expect(find.text('Official Rules & Scoring ...'), findsOneWidget);
      expect(find.text('Read Guide'), findsOneWidget);

      // 3. Verify icons and rules.png asset image
      expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);
      final imageFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == 'assets/images/rules.png',
      );
      expect(imageFinder, findsOneWidget);
    });

    testWidgets('tapping Read Guide button launches InAppWebBrowserScreen with how to play url',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HowToPlayCard(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the Read Guide button
      final readGuideBtn = find.byKey(const Key('how_to_play_read_guide_button'));
      expect(readGuideBtn, findsOneWidget);
      await tester.tap(readGuideBtn);
      await tester.pumpAndSettle();

      // InAppWebBrowserScreen should be pushed onto the navigator
      expect(find.byType(InAppWebBrowserScreen), findsOneWidget);
      final browserWidget =
          tester.widget<InAppWebBrowserScreen>(find.byType(InAppWebBrowserScreen));
      expect(browserWidget.title, 'How to Play');
      expect(browserWidget.url, HelpSupportScreen.howToPlayUrl);
    });

    testWidgets('tapping anywhere on the card launches InAppWebBrowserScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HowToPlayCard(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the card container
      await tester.tap(find.byKey(const Key('how_to_play_card')));
      await tester.pumpAndSettle();

      // InAppWebBrowserScreen should be pushed onto the navigator
      expect(find.byType(InAppWebBrowserScreen), findsOneWidget);
      final browserWidget =
          tester.widget<InAppWebBrowserScreen>(find.byType(InAppWebBrowserScreen));
      expect(browserWidget.title, 'How to Play');
      expect(browserWidget.url, HelpSupportScreen.howToPlayUrl);
    });
  });
}
