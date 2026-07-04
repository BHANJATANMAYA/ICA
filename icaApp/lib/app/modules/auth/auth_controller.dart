import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/fcm_service.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final SupabaseClient _client = AppSupabase.client;

  RxBool isLoading = false.obs;
  Rxn<User> currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _client.auth.currentUser;

    // Listen to auth state changes
    _client.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      final current = Get.currentRoute;
      if (data.session == null) {
        // Only redirect to login if not already there
        if (current.isNotEmpty && current != '/' && current != AppRoutes.login) {
          Get.offAllNamed(AppRoutes.login);
        }
      } else {
        // Redirect to dashboard if on login or startup
        if (current == AppRoutes.login || current == '/' || current == '') {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      }
    });

    // Check if we should show biometric unlock on app open
    _checkBiometricAutoUnlock();
  }

  /// On app open, if a valid session exists and biometric is enabled,
  /// show biometric prompt. The session was persisted via SecureLocalStorage.
  Future<void> _checkBiometricAutoUnlock() async {
    final session = _client.auth.currentSession;
    if (session == null) return; // No session — normal login flow

    final biometricEnabled = await BiometricService.isBiometricEnabled();
    if (!biometricEnabled) return; // Opt-in not set

    final available = await BiometricService.isBiometricAvailable();
    if (!available) return; // Device doesn't support biometrics

    // Show biometric prompt to unlock the existing session
    final authenticated = await BiometricService.authenticate(
      'Unlock Indian Chess Academy with your fingerprint',
    );

    if (!authenticated) {
      // Biometric failed or cancelled — sign out and show login
      await _client.auth.signOut();
      Get.offAllNamed(AppRoutes.login);
    }
    // If authenticated, the auth state listener handles routing to dashboard
  }

  /// Login with email and password.
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Navigate first, then do async post-login tasks
        Get.offAllNamed(AppRoutes.dashboard);

        // Run post-login tasks asynchronously (non-blocking)
        _postLoginTasks(response.user!.id);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Tasks to run after successful login (non-blocking).
  Future<void> _postLoginTasks(String userId) async {
    try {
      // Fetch parent ID for FCM token registration
      final parentRow = await _client
          .from('parents')
          .select('id')
          .eq('auth_user_id', userId)
          .maybeSingle();

      if (parentRow != null) {
        final parentId = parentRow['id'] as String;

        // MODULE 2: Register FCM token
        await FcmService.registerToken(parentId);

        // MODULE 4: Biometric opt-in on first login
        final isFirst = await BiometricService.isFirstLogin();
        if (isFirst) {
          await BiometricService.markFirstLoginDone();
          _showBiometricOptIn();
        }
      }
    } catch (e) {
      // Non-critical — log only
      debugPrint('[AuthController] Post-login task error: $e');
    }
  }

  /// Show biometric opt-in bottom sheet on first login.
  void _showBiometricOptIn() async {
    final available = await BiometricService.isBiometricAvailable();
    if (!available) return;

    // Small delay so the dashboard has time to render first
    await Future.delayed(const Duration(milliseconds: 800));

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.fingerprint,
              size: 64,
              color: AppColors.chessGold,
            ),
            const SizedBox(height: 16),
            const Text(
              'Enable Fingerprint Login',
              style: AppTypography.sectionHeader,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Use your fingerprint to unlock the app on future visits — faster and more secure than your password.',
              style: AppTypography.body.copyWith(color: AppColors.darkGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () async {
                Get.back();
                await BiometricService.setBiometricEnabled(true);
                Get.snackbar(
                  'Fingerprint Enabled',
                  'You can now unlock the app with your fingerprint.',
                  backgroundColor: AppColors.successGreen.withValues(alpha: 0.1),
                  colorText: AppColors.successGreen,
                  icon: const Icon(Icons.check_circle,
                      color: AppColors.successGreen),
                );
              },
              icon: const Icon(Icons.fingerprint, color: Colors.white),
              label: const Text(
                'Enable Fingerprint Login',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.chessGold,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Maybe Later',
                style: AppTypography.body.copyWith(color: AppColors.darkGray),
              ),
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
