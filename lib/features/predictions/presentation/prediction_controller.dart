import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/network/supabase_client_provider.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_controller.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import '../data/prediction_repository.dart';
import '../domain/prediction.dart';

part 'prediction_controller.g.dart';

/// Riverpod controller managing user predictions across Home and Matches feeds.
@Riverpod(keepAlive: true)
class PredictionController extends _$PredictionController {
  @override
  FutureOr<Map<String, Prediction>> build() async {
    final authState = ref.watch(authProvider);
    final supabase = ref.watch(supabaseClientProvider);
    final userId = (authState is PicoAuthAuthenticated && authState.user != null)
        ? authState.user!.id
        : supabase?.auth.currentUser?.id;

    if (userId == null) {
      return const {};
    }

    final repository = ref.watch(predictionRepositoryProvider);
    final list = await repository.getUserPredictions(userId);

    return {for (final p in list) p.matchId: p};
  }

  /// Convenience lookup for a match prediction.
  Prediction? getPrediction(String matchId) {
    return state.value?[matchId];
  }

  /// Submits or updates a prediction for [match].
  ///
  /// Strictly checks zero-client lock: if [match.isLocked], returns `false`.
  Future<bool> submitPrediction({
    required PicoMatch match,
    required int homeScore,
    required int awayScore,
    required String predictedWinner,
  }) async {
    // 1. Client-side zero-trust pre-check
    if (match.isLocked) {
      AppLogger.warning('Attempted to submit prediction for locked match ${match.id}');
      return false;
    }

    final authState = ref.read(authProvider);
    final supabase = ref.read(supabaseClientProvider);
    final userId = (authState is PicoAuthAuthenticated && authState.user != null)
        ? authState.user!.id
        : (supabase?.auth.currentUser?.id ?? 'guest_user');

    try {
      final repository = ref.read(predictionRepositoryProvider);
      final saved = await repository.savePrediction(
        userId: userId,
        matchId: match.id,
        homeScore: homeScore,
        awayScore: awayScore,
        predictedWinner: predictedWinner,
      );

      // 2. Update local state map immediately
      final currentMap = Map<String, Prediction>.from(state.value ?? {});
      currentMap[match.id] = saved;
      state = AsyncData(currentMap);

      // 3. Keep matches controller and user profile synchronized
      ref.read(matchesControllerProvider.notifier).savePrediction(
            match.id,
            homeScore,
            awayScore,
          );
      ref.invalidate(currentUserProfileProvider);

      return true;
    } on PredictionLockedException catch (ple) {
      AppLogger.warning('Prediction rejected by database lock: $ple');
      return false;
    } catch (e, st) {
      AppLogger.error('Failed to submit prediction', e, st);
      return false;
    }
  }
}
