import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A [LocalStorage] implementation that persists Supabase session tokens
/// using [flutter_secure_storage] (backed by Android Keystore / iOS Keychain).
///
/// This replaces supabase_flutter's default Hive-based storage so that
/// session tokens are encrypted at rest.
class SecureLocalStorage extends LocalStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Namespace all keys to avoid collision with other secure storage users.
  static String _key(String key) => 'supabase_session_$key';

  @override
  Future<void> initialize() async {
    // flutter_secure_storage does not need explicit initialization.
  }

  @override
  Future<String?> accessToken() async {
    return _storage.read(key: _key('access_token'));
  }

  @override
  Future<bool> hasAccessToken() async {
    final token = await _storage.read(key: _key('access_token'));
    return token != null;
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _storage.write(
      key: _key('access_token'),
      value: persistSessionString,
    );
  }

  @override
  Future<void> removePersistedSession() async {
    await _storage.delete(key: _key('access_token'));
  }
}
