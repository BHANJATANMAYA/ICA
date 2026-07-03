import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'checkin_screen.dart';

/// Privacy disclosure shown ONCE before any location permission is requested.
///
/// Guards the OS permission dialog to comply with app store guidelines.
/// Dismissed state is stored in SharedPreferences.
class GeofenceDisclosureScreen extends StatelessWidget {
  const GeofenceDisclosureScreen({super.key});

  static const String _shownKey = 'geofence_disclosure_shown';

  /// Returns true if the disclosure has already been shown and dismissed.
  static Future<bool> hasBeenShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shownKey) ?? false;
  }

  static Future<void> markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shownKey, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        title: const Text(
          'Location Privacy',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Illustration
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 52,
                    color: AppColors.chessGold,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Location Access',
                style: AppTypography.sectionHeader,
              ),
              const SizedBox(height: 8),
              Text(
                'Indian Chess Academy uses your location only when you tap "Check In" to verify your physical presence at the academy.',
                style: AppTypography.body.copyWith(color: AppColors.darkGray),
              ),
              const SizedBox(height: 20),

              _BulletPoint(
                icon: Icons.verified_outlined,
                color: AppColors.successGreen,
                title: 'What we collect',
                body:
                    'Your GPS coordinates at the moment you tap Check In — only once per check-in.',
              ),
              const SizedBox(height: 12),

              _BulletPoint(
                icon: Icons.timer_outlined,
                color: AppColors.chessGold,
                title: 'How long we keep it',
                body:
                    'Location logs are automatically purged after 90 days. You can request deletion at any time.',
              ),
              const SizedBox(height: 12),

              _BulletPoint(
                icon: Icons.lock_outlined,
                color: AppColors.deepNavy,
                title: 'What we do NOT do',
                body:
                    'We do not track your location in the background, share it with third parties, or use it for advertising.',
              ),
              const SizedBox(height: 12),

              _BulletPoint(
                icon: Icons.place_outlined,
                color: AppColors.deepNavy,
                title: 'Academy location',
                body:
                    'Parul University, Vadodara — within 200 metres is required for verified attendance.',
              ),

              const SizedBox(height: 24),

              // Action buttons
              ElevatedButton.icon(
                onPressed: () async {
                  await markShown();
                  // Navigate to check-in screen where actual permission request happens
                  Get.off(() => const CheckinScreen());
                },
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text(
                  'Allow Location',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.chessGold,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () async {
                  await markShown();
                  // Go to check-in screen in manual mode
                  Get.off(
                    () => const CheckinScreen(forceManual: true),
                  );
                },
                icon: Icon(Icons.edit_note, color: AppColors.darkGray),
                label: Text(
                  'Skip (Manual Check-in)',
                  style: AppTypography.body.copyWith(color: AppColors.darkGray),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(color: AppColors.darkGray.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You can change your choice at any time in Settings.',
                style: AppTypography.caption.copyWith(color: AppColors.darkGray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _BulletPoint({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: AppTypography.caption.copyWith(color: AppColors.darkGray),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
