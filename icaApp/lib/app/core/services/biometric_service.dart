import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for biometric authentication and opt-in preference management.
class BiometricService {
  BiometricService._();

  static final LocalAuthentication _auth = LocalAuthentication();

  static const String _prefKey = 'biometric_enabled';
  static const String _firstLoginKey = 'first_login_ever_done';

  // ─── Availability ───

  /// Returns true if the device supports biometrics and has enrolled biometrics.
  static Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      if (!canCheck || !isDeviceSupported) return false;

      final biometrics = await _auth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('[Biometric] Availability check error: $e');
      return false;
    }
  }

  // ─── Authentication ───

  /// Prompt the user for biometric authentication.
  ///
  /// Returns true if authentication succeeds.
  /// Returns false if biometrics are unavailable or the user cancels.
  /// [reason] is shown in the native biometric prompt.
  static Future<bool> authenticate(String reason) async {
    final available = await isBiometricAvailable();
    if (!available) {
      if (kDebugMode) debugPrint('[Biometric] Not available on this device.');
      return false;
    }

    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/pattern fallback
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('[Biometric] Authentication error: $e');
      return false;
    }
  }

  // ─── Opt-in Preference ───

  /// Returns true if the user has opted in to biometric login.
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// Enable or disable biometric login opt-in.
  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
  }

  // ─── First Login Tracking ───

  /// Returns true if this is the very first login on this device.
  static Future<bool> isFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_firstLoginKey) ?? false);
  }

  /// Mark that the first login has been completed.
  static Future<void> markFirstLoginDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLoginKey, true);
  }
}
