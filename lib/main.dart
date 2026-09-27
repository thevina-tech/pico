import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/routing/app_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables based on compile mode
  final envFile = kReleaseMode ? '.env.prod' : '.env.dev';
  await dotenv.load(fileName: envFile);
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
      AppLogger.info('Supabase initialized successfully ($envFile)');
    } catch (e, st) {
      AppLogger.error('Failed to initialize Supabase', e, st);
    }
  } else {
    AppLogger.warning('Supabase credentials missing in $envFile');
  }

  // Set immersive dark system UI matching Pico pitch world
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: PicoColors.pitchSurface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: PicoApp(),
    ),
  );
}

class PicoApp extends ConsumerWidget {
  const PicoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Pico',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: PicoColors.pitchBackground,
        primaryColor: PicoColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: PicoColors.primary,
          surface: PicoColors.pitchSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
    );
  }
}
