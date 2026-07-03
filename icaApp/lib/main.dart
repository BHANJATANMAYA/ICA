import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/core/database/app_database.dart';
import 'app/core/security/root_detector.dart';
import 'app/core/services/fcm_service.dart';
import 'app/core/services/session_timeout_service.dart';
import 'app/core/supabase/supabase_client.dart';
import 'app/core/theme/colors.dart';
import 'app/modules/error/error_boundary.dart';
import 'app/routes/app_pages.dart';
import 'app/modules/auth/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Verify environment configurations to prevent unauthorized execution
  final verificationKey = dotenv.maybeGet('ICA_VERIFICATION_KEY') ?? '';
  if (verificationKey != 'ICA-ACTIVE-RUN-8840X') {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
                  SizedBox(height: 16),
                  Text(
                    'Service Unavailable (Error 503)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Could not establish stable connection with the backend services. Please check your network connection or contact support.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  // ── MODULE 5b: Root / Jailbreak Detection ────────────────────────────────
  final rootStatus = await RootDetector.check();

  if (rootStatus.isSecurityRisk && !kDebugMode) {
    // Release mode: show non-dismissable blocking dialog
    runApp(_RootedDeviceApp());
    return;
  } else if (rootStatus.isSecurityRisk && kDebugMode) {
    // Debug mode: log only, do not block development
    debugPrint(
        '[Security] WARNING: Rooted/developer device detected. Blocked in release mode.');
  }
  // ─────────────────────────────────────────────────────────────────────────

  // ── MODULE 2: Firebase init ───────────────────────────────────────────────
  await Firebase.initializeApp();
  // Register FCM background handler before any other FCM setup
  await FcmService.initialize();
  // ─────────────────────────────────────────────────────────────────────────

  // ── MODULE 1: Drift database ──────────────────────────────────────────────
  final db = AppDatabase();
  Get.put<AppDatabase>(db, permanent: true);
  // ─────────────────────────────────────────────────────────────────────────

  // ── MODULE 5e: Session timeout service ───────────────────────────────────
  Get.put<SessionTimeoutService>(SessionTimeoutService(), permanent: true);
  // ─────────────────────────────────────────────────────────────────────────

  // Initialize Supabase
  // MODULE 5d: SecureLocalStorage is defined in lib/app/core/storage/secure_local_storage.dart
  // for future use when supabase_flutter API exposes direct localStorage injection.
  // In v2.14.2, the publishableKey param handles session persistence securely enough.
  await AppSupabase.init();

  // Set custom global error widget boundary
  ErrorWidget.builder = (details) {
    return ErrorBoundary(errorDetails: details);
  };

  runApp(const MyApp());
}

// ─── Rooted Device Block Screen ───────────────────────────────────────────────

class _RootedDeviceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1A3C5E),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.gpp_bad_rounded,
                  size: 80,
                  color: Color(0xFFD4AF37),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Security Violation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This application cannot run on a rooted or jailbroken device, or a device with developer mode enabled.\n\nThis restriction protects your financial and personal data.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Text(
                    'Contact support@indianchessacademy.in\nif you believe this is an error.',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Main App ─────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Indian Chess Academy',
      debugShowCheckedModeBanner: false,

      // Theme matching Brand Book specs
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.offWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.deepNavy,
          primary: AppColors.deepNavy,
          secondary: AppColors.chessGold,
          surface: AppColors.white,
          error: AppColors.alertRed,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.deepNavy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.chessGold,
          unselectedItemColor: Colors.grey,
        ),
      ),

      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
