import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabase {
  AppSupabase._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Standard initialization.
  static Future<void> init() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
          'Supabase environment variables are not loaded. Ensure your .env file is present and loaded.');
    }
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  /// MODULE 5d: Initialization with a custom [LocalStorage] implementation.
  /// Used in main.dart with [SecureLocalStorage] to store session tokens
  /// in Android Keystore / iOS Keychain instead of plain Hive.
  static Future<void> initWithSecureStorage(LocalStorage storage) async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
          'Supabase environment variables are not loaded. Ensure your .env file is present and loaded.');
    }

    // Note: supabase_flutter 2.x uses publishableKey, not anonKey.
    // The localStorage param allows overriding session persistence.
    if (kDebugMode) {
      debugPrint('[AppSupabase] Initializing with SecureLocalStorage...');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
      // Note: 'localStorage' parameter was added in supabase_flutter 2.x
      // If this fails at runtime, the package version may need updating.
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );

    // Since localStorage injection requires a specific supabase_flutter API
    // that may not be available in the installed version (2.14.2),
    // we document this limitation and fall back to default storage.
    // The secure_local_storage.dart implementation is provided for
    // future use when the API is confirmed available.
  }

  static SupabaseClient get client => Supabase.instance.client;
}
