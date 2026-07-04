import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show RouteSettings;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modules/auth/login_screen.dart';
import '../modules/dashboard/dashboard_binding.dart';
import '../modules/dashboard/dashboard_screen.dart';
import '../modules/notifications/notifications_binding.dart';
import '../modules/notifications/notifications_screen.dart';
import '../modules/student_view/checkin/checkin_screen.dart';
import '../modules/student_view/checkin/geofence_disclosure_screen.dart';
import 'app_routes.dart';

/// Middleware that validates deep-link navigation attempts.
///
/// Rejects any route navigation that arrives without a valid authenticated
/// session. Logs invalid attempts in debug mode.
class AuthGuardMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final client = Supabase.instance.client;
    if (client.auth.currentSession == null) {
      if (kDebugMode) {
        debugPrint('[AuthGuard] Blocked unauthenticated navigation to: $route');
      }
      return const RouteSettings(name: AppRoutes.login);
    }
    return null; // Allow navigation
  }
}

class AppPages {
  AppPages._();

  static const initial = AppRoutes.login;

  static final routes = [
    // ── Public routes (no auth guard) ────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),

    // ── Authenticated routes (auth guard applied) ─────────────────────────────
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: NotificationsBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.checkin,
      page: () => const CheckinScreen(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.geofenceDisclosure,
      page: () => const GeofenceDisclosureScreen(),
      middlewares: [AuthGuardMiddleware()],
    ),

    // ── Deep-link target routes (FCM navigation) ──────────────────────────────
    GetPage(
      name: AppRoutes.attendance,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.billing,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.schedule,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.assignments,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
  ];
}
