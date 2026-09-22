// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matches_feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier provider fetching matches and filtering them strictly
/// to ONLY those linked to the competition_id of tournaments the user has joined.

@ProviderFor(MatchesFeed)
final matchesFeedProvider = MatchesFeedProvider._();

/// AsyncNotifier provider fetching matches and filtering them strictly
/// to ONLY those linked to the competition_id of tournaments the user has joined.
final class MatchesFeedProvider
    extends $AsyncNotifierProvider<MatchesFeed, List<PicoMatch>> {
  /// AsyncNotifier provider fetching matches and filtering them strictly
  /// to ONLY those linked to the competition_id of tournaments the user has joined.
  MatchesFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchesFeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchesFeedHash();

  @$internal
  @override
  MatchesFeed create() => MatchesFeed();
}

String _$matchesFeedHash() => r'2dd397c6a234d85f7aa9f5dd7e0b7f3e800841b5';

/// AsyncNotifier provider fetching matches and filtering them strictly
/// to ONLY those linked to the competition_id of tournaments the user has joined.

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
