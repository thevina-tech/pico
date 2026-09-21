import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pico/features/matches/data/match_repository.dart';
import 'package:pico/features/matches/domain/pico_match.dart';

part 'matches_feed_provider.g.dart';

/// AsyncNotifier provider fetching and caching lists of matches from Supabase.
@riverpod
class MatchesFeed extends _$MatchesFeed {
  @override
  FutureOr<List<PicoMatch>> build() async {
    final repository = ref.watch(matchRepositoryProvider);
    return await repository.getAllMatches();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(matchRepositoryProvider);
      return await repository.getAllMatches();
    });
  }
}
