import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/network/supabase_client_provider.dart';
import '../domain/prediction.dart';

part 'prediction_repository.g.dart';

/// Exception thrown when the prediction window has closed (10 minutes before kickoff).
class PredictionLockedException implements Exception {
  const PredictionLockedException([this.message = 'Predictions lock exactly 10 minutes before kickoff.']);
  final String message;

  @override
  String toString() => message;
}

/// Riverpod provider exposing the active [PredictionRepository].
@Riverpod(keepAlive: true)
PredictionRepository predictionRepository(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabasePredictionRepository(supabase);
}

/// Abstract contract for user prediction persistence and retrieval.
abstract class PredictionRepository {
  Future<List<Prediction>> getUserPredictions(String userId);
  Future<Map<String, int>> getUserSettlementPoints(String userId);
  Future<Prediction?> getPredictionForMatch({
    required String userId,
    required String matchId,
  });
  Future<Prediction> savePrediction({
    required String userId,
    required String matchId,
    required int homeScore,
    required int awayScore,
    required String predictedWinner,
  });
}

/// Production Supabase implementation of [PredictionRepository] with offline fallback.
class SupabasePredictionRepository implements PredictionRepository {
  SupabasePredictionRepository([this._supabase]);

  final SupabaseClient? _supabase;

  // In-memory mock storage: "$userId:$matchId" -> Prediction
  final Map<String, Prediction> _mockStorage = {};

  @override
  Future<List<Prediction>> getUserPredictions(String userId) async {
    if (_supabase == null) {
      return _mockStorage.values.where((p) => p.userId == userId).toList();
    }

    try {
      final response = await _supabase
          .from('predictions')
          .select()
          .eq('user_id', userId);

      final list = (response as List<dynamic>)
          .map((row) => Prediction.fromJson(row as Map<String, dynamic>))
          .toList();

      return list;
    } catch (e, st) {
      AppLogger.error('Failed to get predictions from Supabase; using mock cache', e, st);
      return _mockStorage.values.where((p) => p.userId == userId).toList();
    }
  }

  @override
  Future<Map<String, int>> getUserSettlementPoints(String userId) async {
    if (_supabase == null) {
      return {};
    }
    try {
      final response = await _supabase
          .from('pico_point_transactions')
          .select('match_id, points')
          .eq('user_id', userId);

      final map = <String, int>{};
      for (final row in (response as List<dynamic>)) {
        final r = row as Map<String, dynamic>;
        final mId = r['match_id']?.toString();
        final pts = r['points'] as int? ?? 0;
        if (mId != null && mId.isNotEmpty) {
          map[mId] = pts;
        }
      }
      return map;
    } catch (e, st) {
      AppLogger.error('Failed to get point transactions from Supabase', e, st);
      return {};
    }
  }

  @override
  Future<Prediction?> getPredictionForMatch({
    required String userId,
    required String matchId,
  }) async {
    final cacheKey = '$userId:$matchId';
    if (_supabase == null) {
      return _mockStorage[cacheKey];
    }

    try {
      final response = await _supabase
          .from('predictions')
          .select()
          .eq('user_id', userId)
          .eq('match_id', matchId)
          .maybeSingle();

      if (response != null) {
        final pred = Prediction.fromJson(response);
        _mockStorage[cacheKey] = pred;
        return pred;
      }
      return _mockStorage[cacheKey];
    } catch (e, st) {
      AppLogger.error('Failed to get match prediction from Supabase; fallback', e, st);
      return _mockStorage[cacheKey];
    }
  }

  @override
  Future<Prediction> savePrediction({
    required String userId,
    required String matchId,
    required int homeScore,
    required int awayScore,
    required String predictedWinner,
  }) async {
    final cacheKey = '$userId:$matchId';
    final now = DateTime.now();

    final prediction = Prediction(
      id: 'pred_${now.millisecondsSinceEpoch}',
      userId: userId,
      matchId: matchId,
      homeScore: homeScore,
      awayScore: awayScore,
      predictedWinner: predictedWinner,
      createdAt: now,
      updatedAt: now,
    );

    if (_supabase == null) {
      _mockStorage[cacheKey] = prediction;
      AppLogger.info('Mock prediction saved for user $userId on match $matchId: $homeScore-$awayScore ($predictedWinner)');
      return prediction;
    }

    try {
      final response = await _supabase
          .from('predictions')
          .upsert(
            {
              'user_id': userId,
              'match_id': matchId,
              'home_score': homeScore,
              'away_score': awayScore,
              'predicted_winner': predictedWinner,
              'updated_at': now.toIso8601String(),
            },
            onConflict: 'user_id,match_id',
          )
          .select()
          .single();

      final saved = Prediction.fromJson(response);
      _mockStorage[cacheKey] = saved;

      // Award +10 XP for prediction submitted via transaction ledger
      try {
        await _supabase.from('xp_transactions').insert({
          'user_id': userId,
          'match_id': matchId,
          'xp_amount': 10,
          'action': 'prediction_submitted',
        });
        await _supabase.rpc('increment_profile_xp', params: {
          'p_user_id': userId,
          'p_xp_delta': 10,
        });
      } catch (xpError) {
        // Fallback or silent catch if RPC is not present or already handled by trigger
        AppLogger.debug('XP transaction note on prediction save: $xpError');
      }

      AppLogger.info('Prediction saved in Supabase for user $userId on match $matchId: $homeScore-$awayScore');
      return saved;
    } on PostgrestException catch (pe, st) {
      AppLogger.error('PostgrestException saving prediction', pe, st);
      if (pe.message.contains('10 minutes') ||
          pe.message.contains('Predictions lock')) {
        throw PredictionLockedException(pe.message);
      }
      rethrow;
    } catch (e, st) {
      AppLogger.error('Unexpected error saving prediction in Supabase', e, st);
      // Cache locally so user doesn't lose input offline
      _mockStorage[cacheKey] = prediction;
      return prediction;
    }
  }
}
