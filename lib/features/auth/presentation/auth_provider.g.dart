// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream provider listening to Supabase auth state changes.

@ProviderFor(authStateChanges)
final authStateChangesProvider = AuthStateChangesProvider._();

/// Stream provider listening to Supabase auth state changes.

final class AuthStateChangesProvider
    extends
        $FunctionalProvider<
          AsyncValue<supa.AuthState>,
          supa.AuthState,
          Stream<supa.AuthState>
        >
    with $FutureModifier<supa.AuthState>, $StreamProvider<supa.AuthState> {
  /// Stream provider listening to Supabase auth state changes.
  AuthStateChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateChangesHash();

  @$internal
  @override
  $StreamProviderElement<supa.AuthState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<supa.AuthState> create(Ref ref) {
    return authStateChanges(ref);
  }
}

String _$authStateChangesHash() => r'a785e5ddabbc47fbbd0bb8c84bc11263d77371a6';

/// Central Riverpod AuthNotifier managing authentication state,
/// anonymous login, and personalization tracking.

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

/// Central Riverpod AuthNotifier managing authentication state,
/// anonymous login, and personalization tracking.
final class AuthNotifierProvider
    extends $NotifierProvider<AuthNotifier, PicoAuthState> {
  /// Central Riverpod AuthNotifier managing authentication state,
  /// anonymous login, and personalization tracking.
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PicoAuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PicoAuthState>(value),
    );
  }
}

String _$authNotifierHash() => r'ea80e5442dd694105bf104d40420c0a815af958f';

/// Central Riverpod AuthNotifier managing authentication state,
/// anonymous login, and personalization tracking.

abstract class _$AuthNotifier extends $Notifier<PicoAuthState> {
  PicoAuthState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PicoAuthState, PicoAuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PicoAuthState, PicoAuthState>,
              PicoAuthState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
