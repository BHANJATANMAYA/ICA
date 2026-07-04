class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const dashboard = '/dashboard';
  static const notifications = '/notifications';
  static const addProfile = '/add-profile';
  static const editProfile = '/edit-profile';

  // Round 2 routes (also used as FCM deep-link targets)
  static const attendance = '/attendance';
  static const billing = '/billing';
  static const schedule = '/schedule';
  static const chat = '/chat';
  static const assignments = '/assignments';
  static const checkin = '/checkin';
  static const geofenceDisclosure = '/geofence-disclosure';
}
