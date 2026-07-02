import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_routes.dart';

/// Monitors user inactivity and signs out after 15 minutes of no interaction.
///
/// Usage:
///   1. Call [SessionTimeoutService.resetInteraction()] on any user touch event
///      (wrap DashboardScreen body with GestureDetector).
///   2. Registered as a permanent GetX service via Get.put().
class SessionTimeoutService extends GetxService {
  static const Duration _timeout = Duration(minutes: 15);
  static const Duration _checkInterval = Duration(seconds: 60);

  DateTime _lastInteraction = DateTime.now();
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
    if (kDebugMode) {
      debugPrint('[SessionTimeout] Service started. Timeout: $_timeout');
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  /// Call this on any user interaction to reset the idle timer.
  void resetInteraction() {
    _lastInteraction = DateTime.now();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_checkInterval, (_) => _checkTimeout());
  }

  Future<void> _checkTimeout() async {
    final idleDuration = DateTime.now().difference(_lastInteraction);

    if (kDebugMode) {
      debugPrint('[SessionTimeout] Idle for: ${idleDuration.inSeconds}s');
    }

    if (idleDuration >= _timeout) {
      _timer?.cancel();

      if (kDebugMode) {
        debugPrint('[SessionTimeout] Session timed out — signing out.');
      }

      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {
        // signOut can fail if session is already expired — continue to login
      }

      // Navigate to login, clearing the navigation stack
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
