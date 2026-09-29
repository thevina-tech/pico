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
import 'package:pico/services/ad_consent_service.dart';
import 'package:pico/services/revenuecat_ad_service.dart';

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

  // 1. Gather GDPR/CPRA Ad Consent via Google UMP SDK
  try {
    await AdConsentService.instance.gatherConsent();
  } catch (e) {
    AppLogger.warning('AdConsentService initialization skipped: $e');
  }

  // 2. Initialize RevenueCat & Google Mobile Ads AdTracker Service
  try {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    await RevenueCatAdService.instance.initialize(initialUserId: currentUserId);

    // Sync RevenueCat identity on auth changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      RevenueCatAdService.instance.syncUser(user?.id);
    });
  } catch (e) {
    AppLogger.warning('RevenueCatAdService initialization skipped: $e');
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
          error: PicoColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: PicoColors.snackBarSurface,
          contentTextStyle: const TextStyle(
            color: PicoColors.snackBarText,
            fontWeight: FontWeight.w600,
            fontSize: 14.0,
            fontFamily: 'Rubik',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(color: Color(0xFFE2DDD2), width: 1.5),
          ),
          elevation: 8.0,
        ),
      ),
    );
  }
}
