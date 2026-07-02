import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

/// Result of a root/jailbreak detection check.
class RootStatus {
  final bool isRooted;
  final bool isDeveloperModeOn;

  const RootStatus({
    required this.isRooted,
    required this.isDeveloperModeOn,
  });

  /// True if the device poses a security risk.
  bool get isSecurityRisk => isRooted || isDeveloperModeOn;
}

/// Wrapper around [FlutterJailbreakDetection] that is:
/// - Platform-aware: no-op on web / desktop targets
/// - Fail-safe: returns clean status if detection throws
class RootDetector {
  RootDetector._();

  /// Check device security status before runApp().
  ///
  /// On non-mobile platforms always returns a clean [RootStatus] so that
  /// development on Windows/Linux/macOS/Web is unaffected.
  static Future<RootStatus> check() async {
    // flutter_jailbreak_detection only supports Android and iOS
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return const RootStatus(isRooted: false, isDeveloperModeOn: false);
    }

    try {
      final isJailbroken = await FlutterJailbreakDetection.jailbroken;
      final isDevMode = await FlutterJailbreakDetection.developerMode;

      if (kDebugMode) {
        debugPrint(
            '[RootDetector] isRooted=$isJailbroken, isDevMode=$isDevMode');
      }

      return RootStatus(
        isRooted: isJailbroken,
        isDeveloperModeOn: isDevMode,
      );
    } catch (e) {
      // Fail safe — if detection itself errors, assume the device is clean
      if (kDebugMode) {
        debugPrint(
            '[RootDetector] Detection error: $e. Assuming clean device.');
      }
      return const RootStatus(isRooted: false, isDeveloperModeOn: false);
    }
  }
}
