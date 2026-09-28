// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for the current user's profile.
/// Watches [authProvider] and queries [profileRepositoryProvider].

@ProviderFor(CurrentUserProfile)
final currentUserProfileProvider = CurrentUserProfileProvider._();

/// Riverpod provider for the current user's profile.
/// Watches [authProvider] and queries [profileRepositoryProvider].
final class CurrentUserProfileProvider
    extends $AsyncNotifierProvider<CurrentUserProfile, UserProfile> {
  /// Riverpod provider for the current user's profile.
  /// Watches [authProvider] and queries [profileRepositoryProvider].
  CurrentUserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserProfileHash();

  @$internal
  @override
  CurrentUserProfile create() => CurrentUserProfile();
}

String _$currentUserProfileHash() =>
    r'd7ce1601b622ead0c9e13eb911b69520d29848d1';

/// Riverpod provider for the current user's profile.
/// Watches [authProvider] and queries [profileRepositoryProvider].

abstract class _$CurrentUserProfile extends $AsyncNotifier<UserProfile> {
  FutureOr<UserProfile> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserProfile>, UserProfile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProfile>, UserProfile>,
              AsyncValue<UserProfile>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
