import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_client_provider.g.dart';

/// Provides the singleton [SupabaseClient] instance across the app,
/// or null if Supabase has not yet been initialized (e.g. in hermetic unit tests).
@Riverpod(keepAlive: true)
SupabaseClient? supabaseClient(Ref ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}
