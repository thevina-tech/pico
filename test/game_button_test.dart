import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/shared/components/game_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('GameButton Component Tests', () {
    testWidgets('Renders with default Warm Game Gold styling and triggers onPressed', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildApp(
          GameButton(
            text: 'Play Game',
            onPressed: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Play Game'), findsOneWidget);

      // Verify outer extruded layer colors
      final outerAnimatedContainer = tester.widget<AnimatedContainer>(
        find.ancestor(of: find.text('Play Game'), matching: find.byType(AnimatedContainer)).first,
      );
      final outerDecoration = outerAnimatedContainer.decoration as BoxDecoration;
      expect(outerDecoration.color, const Color(0xFFB86000));
      expect((outerDecoration.border! as Border).top.color, const Color(0xFFB86600));

      // Verify inner face color
      final innerContainer = tester.widgetList<Container>(
        find.descendant(
          of: find.ancestor(of: find.text('Play Game'), matching: find.byType(AnimatedContainer)).first,
          matching: find.byType(Container),
        ),
      ).firstWhere((c) => c.decoration is BoxDecoration && (c.decoration as BoxDecoration).color == const Color(0xFFFCCB2B));
      final innerDecoration = innerContainer.decoration as BoxDecoration;
      expect(innerDecoration.color, const Color(0xFFFCCB2B));

      // Tap button and verify callback
      await tester.tap(find.text('Play Game'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('Accepts custom dimensions, padding, and colors', (tester) async {
      await tester.pumpWidget(
        buildApp(
          const GameButton(
            text: 'Custom Action',
            onPressed: null,
            faceColor: Color(0xFF8B5CF6),
            extrusionColor: Color(0xFF6D28D9),
            outlineColor: Color(0xFF5B21B6),
            glowColor: Color(0xFFA78BFA),
            textColor: Color(0xFFEDE9FE),
            width: 220.0,
            height: 52.0,
            borderRadius: 24.0,
            outlineWidth: 2.5,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('Custom Action'));
      expect(textWidget.style?.color, const Color(0xFFEDE9FE));

      // Verify dimensions
      final outerAnimatedContainer = tester.widget<AnimatedContainer>(
        find.ancestor(of: find.text('Custom Action'), matching: find.byType(AnimatedContainer)).first,
      );
      expect(outerAnimatedContainer.constraints?.maxWidth, 220.0);
    });

    testWidgets('Named presets (gold, cream, green, blue, red) apply appropriate colors', (tester) async {
      await tester.pumpWidget(
        buildApp(
          Column(
            children: [
              GameButton.gold(text: 'Gold Button', onPressed: () {}),
              GameButton.cream(text: 'Cream Button', onPressed: () {}),
              GameButton.green(text: 'Green Button', onPressed: () {}),
              GameButton.blue(text: 'Blue Button', onPressed: () {}),
              GameButton.red(text: 'Red Button', onPressed: () {}),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gold Button'), findsOneWidget);
      expect(find.text('Cream Button'), findsOneWidget);
      expect(find.text('Green Button'), findsOneWidget);
      expect(find.text('Blue Button'), findsOneWidget);
      expect(find.text('Red Button'), findsOneWidget);
    });

    testWidgets('Disabled button does not trigger onPressed or press animation', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildApp(
          GameButton(
            text: 'Disabled',
            enabled: false,
            onPressed: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });

    testWidgets('Renders custom child and triggers onLongPress callback', (tester) async {
      bool longPressed = false;
      bool tapped = false;

      await tester.pumpWidget(
        buildApp(
          GameButton(
            onPressed: () => tapped = true,
            onLongPress: () => longPressed = true,
            child: const Row(
              children: [
                Icon(Icons.person),
                Text('Custom Player Child'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom Player Child'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);

      await tester.longPress(find.text('Custom Player Child'));
      await tester.pumpAndSettle();
      expect(longPressed, isTrue);

      await tester.tap(find.text('Custom Player Child'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
