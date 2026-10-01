import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pico/features/profile/presentation/trophy_cabinet_screen.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/game_button.dart';
import 'package:pico/shared/components/pico_app_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget({Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const TrophyCabinetScreen(),
    );
  }

  group('TrophyCabinetScreen', () {
    testWidgets('renders cabinet image, blur filter with sigma 5.0, and disabled GameButton',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // 1. Verify PicoAppBar with localized title
      expect(find.byType(PicoAppBar), findsOneWidget);
      expect(find.text('Trophy Cabinet'), findsOneWidget);

      // 2. Verify cabinet.png is rendered
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsWidgets);
      final cabinetImage = tester.widgetList<Image>(imageFinder).firstWhere(
            (img) =>
                img.image is AssetImage &&
                (img.image as AssetImage).assetName == 'assets/images/cabinet.png',
          );
      expect(cabinetImage.fit, BoxFit.contain);

      // 3. Verify BackdropFilter with sigma 5.0
      final backdropFilterFinder = find.byType(BackdropFilter);
      expect(backdropFilterFinder, findsWidgets);
      final backdropFilter = tester.widget<BackdropFilter>(backdropFilterFinder.first);
      expect(
        backdropFilter.filter,
        ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      );

      // 4. Verify disabled GameButton with localized "Coming Soon!" text
      final gameButtonFinder =
          find.byKey(const Key('trophy_cabinet_coming_soon_button'));
      expect(gameButtonFinder, findsOneWidget);
      final gameButton = tester.widget<GameButton>(gameButtonFinder);
      expect(gameButton.text, 'Coming Soon!');
      expect(gameButton.onPressed, isNull);
    });

    testWidgets('renders Spanish localized text correctly', (tester) async {
      await tester.pumpWidget(buildTestableWidget(locale: const Locale('es')));
      await tester.pumpAndSettle();

      // Spanish title
      expect(find.text('Vitrina de Trofeos'), findsOneWidget);

      // Spanish button text
      expect(find.text('¡Próximamente!'), findsOneWidget);
    });
  });
}
