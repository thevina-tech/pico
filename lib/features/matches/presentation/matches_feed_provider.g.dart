// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matches_feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier provider fetching and caching lists of matches from Supabase.

@ProviderFor(MatchesFeed)
final matchesFeedProvider = MatchesFeedProvider._();

/// AsyncNotifier provider fetching and caching lists of matches from Supabase.
final class MatchesFeedProvider
    extends $AsyncNotifierProvider<MatchesFeed, List<PicoMatch>> {
  /// AsyncNotifier provider fetching and caching lists of matches from Supabase.
  MatchesFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchesFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchesFeedHash();

  @$internal
  @override
  MatchesFeed create() => MatchesFeed();
}

String _$matchesFeedHash() => r'd5ef2dafcb6f472adf64578289255bfea960ea7f';

/// AsyncNotifier provider fetching and caching lists of matches from Supabase.

abstract class _$MatchesFeed extends $AsyncNotifier<List<PicoMatch>> {
  FutureOr<List<PicoMatch>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<PicoMatch>>, List<PicoMatch>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PicoMatch>>, List<PicoMatch>>,
              AsyncValue<List<PicoMatch>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
