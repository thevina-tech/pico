import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

/// Represents the authentication state of the Pico application.
@immutable
sealed class PicoAuthState {
  const PicoAuthState();
}

/// Initializing or checking current session.
class PicoAuthInitial extends PicoAuthState {
  const PicoAuthInitial();
}

/// No active session; guest or logged out.
class PicoAuthUnauthenticated extends PicoAuthState {
  const PicoAuthUnauthenticated();
}

/// Actively signing in or processing credentials.
class PicoAuthAuthenticating extends PicoAuthState {
  const PicoAuthAuthenticating();
}

/// Successfully authenticated with Supabase.
class PicoAuthAuthenticated extends PicoAuthState {
  const PicoAuthAuthenticated({
    this.user,
    this.isPersonalized = false,
  });

  final User? user;
  final bool isPersonalized;

  PicoAuthAuthenticated copyWith({
    User? user,
    bool? isPersonalized,
  }) {
    return PicoAuthAuthenticated(
      user: user ?? this.user,
      isPersonalized: isPersonalized ?? this.isPersonalized,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PicoAuthAuthenticated &&
          other.user?.id == user?.id &&
          other.isPersonalized == isPersonalized;

  @override
  int get hashCode => Object.hash(user?.id, isPersonalized);
}

/// An error occurred during an auth operation.
class PicoAuthError extends PicoAuthState {
  const PicoAuthError(this.message);
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PicoAuthError && other.message == message;

  @override
  int get hashCode => message.hashCode;
}
