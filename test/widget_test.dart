import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/main.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';

void main() {
  testWidgets('PicoApp smoke test - boots and displays bottom nav shell',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PicoApp()));
    await tester.pumpAndSettle();

    // Verify bottom nav bar is present with its 4 tabs
    final navBar = find.byType(PicoBottomNavBar);
    expect(navBar, findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Home')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Matches')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Tournaments')), findsOneWidget);
    expect(find.descendant(of: navBar, matching: find.text('Profile')), findsOneWidget);
  });

  testWidgets('PicoApp tab navigation - switches branches via bottom nav bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PicoApp()));
    await tester.pumpAndSettle();

    final navBar = find.byType(PicoBottomNavBar);

    // Tap Matches tab
    await tester.tap(find.descendant(of: navBar, matching: find.text('Matches')));
    await tester.pumpAndSettle();
    expect(find.text('Round 32 Predictions · Sunday'), findsOneWidget);

    // Tap Tournaments tab
    await tester.tap(find.descendant(of: navBar, matching: find.text('Tournaments')));
    await tester.pumpAndSettle();
    expect(find.text('Champions League Masters'), findsOneWidget);

    // Tap Profile tab
    await tester.tap(find.descendant(of: navBar, matching: find.text('Profile')));
    await tester.pumpAndSettle();
    expect(find.text('Alex Pereira'), findsOneWidget);

    // Tap Home tab back
    await tester.tap(find.descendant(of: navBar, matching: find.text('Home')));
    await tester.pumpAndSettle();
    expect(find.text('La Liga Season Hub'), findsOneWidget);
  });
}
