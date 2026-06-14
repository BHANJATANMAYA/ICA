import 'package:get/get.dart';
import '../modules/auth/login_screen.dart';
import '../modules/dashboard/dashboard_binding.dart';
import '../modules/dashboard/dashboard_screen.dart';
import '../modules/notifications/notifications_binding.dart';
import '../modules/notifications/notifications_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: NotificationsBinding(),
    ),
  ];
}
