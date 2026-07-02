import 'package:drift/drift.dart' as drift;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import '../../routes/app_routes.dart';

// ─────────────────────────────────────────────
// Background message handler (top-level function required by FCM)
// ─────────────────────────────────────────────

/// FCM requires the background message handler to be a top-level function
/// (not a class method). It runs in a separate Isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note: Firebase is already initialized in the background isolate.
  if (kDebugMode) {
    debugPrint('[FCM Background] Message: ${message.notification?.title}');
  }
  // We can't easily access drift in the background isolate.
  // The foreground handler will sync on resume.
}

// ─────────────────────────────────────────────
// Notification Channel IDs
// ─────────────────────────────────────────────

class NotificationChannels {
  static const String classUpdates = 'class_updates';
  static const String paymentsAlerts = 'payments_alerts';

  static const AndroidNotificationChannel classUpdatesChannel =
      AndroidNotificationChannel(
    classUpdates,
    'Class Updates',
    description: 'Notifications about class schedule changes and updates',
    importance: Importance.high,
    playSound: true,
  );

  static const AndroidNotificationChannel paymentsAlertsChannel =
      AndroidNotificationChannel(
    paymentsAlerts,
    'Payments & Alerts',
    description: 'Billing, payment confirmation, and critical alerts',
    importance: Importance.high,
    playSound: true,
  );
}

// ─────────────────────────────────────────────
// FCM Service
// ─────────────────────────────────────────────

class FcmService {
  FcmService._();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Call once from main() after Firebase.initializeApp()
  static Future<void> initialize() async {
    // Register background handler (must be before any other FCM setup)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request notification permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Create notification channels (Android 8+)
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin
        ?.createNotificationChannel(NotificationChannels.classUpdatesChannel);
    await androidPlugin?.createNotificationChannel(
        NotificationChannels.paymentsAlertsChannel);

    // Initialize flutter_local_notifications
    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings =
        InitializationSettings(android: initSettingsAndroid);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap from background (app was in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Register FCM token for the logged-in parent.
  /// Call after successful login.
  static Future<void> registerToken(String parentId) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      if (kDebugMode) debugPrint('[FCM] Token: $token');

      await _upsertTokenToSupabase(parentId, token);

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        await _upsertTokenToSupabase(parentId, newToken);
      });
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] Token registration error: $e');
    }
  }

  static Future<void> _upsertTokenToSupabase(
      String parentId, String token) async {
    try {
      final client = Supabase.instance.client;
      await client.from('fcm_tokens').upsert({
        'parent_id': parentId,
        'token': token,
        'platform': 'android',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'parent_id');
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] Supabase token upsert error: $e');
    }
  }

  /// Handle foreground message — show as local notification.
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('[FCM Foreground] ${message.notification?.title}');
    }

    final notification = message.notification;
    if (notification == null) return;

    final channelId = _resolveChannel(message.data);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == NotificationChannels.classUpdates
              ? 'Class Updates'
              : 'Payments & Alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      payload: message.data['deep_link'] as String?,
    );

    // Persist to drift cache
    await _persistNotificationToDrift(message);
  }

  /// Handle notification tap — route via deep_link field.
  static void _handleNotificationTap(RemoteMessage message) {
    final deepLink = message.data['deep_link'] as String?;
    if (deepLink != null && deepLink.isNotEmpty) {
      _navigateDeepLink(deepLink);
    }
    _persistNotificationToDrift(message);
  }

  /// Handle local notification tap (flutter_local_notifications callback).
  static void _onNotificationTap(NotificationResponse response) {
    final deepLink = response.payload;
    if (deepLink != null && deepLink.isNotEmpty) {
      _navigateDeepLink(deepLink);
    }
  }

  /// Route to screen based on deep_link value.
  static void _navigateDeepLink(String deepLink) {
    final client = Supabase.instance.client;
    if (client.auth.currentSession == null) {
      if (kDebugMode) {
        debugPrint('[FCM Deep Link] Ignored — no authenticated session for: $deepLink');
      }
      return;
    }

    final allowedRoutes = {
      '/attendance': AppRoutes.attendance,
      '/billing': AppRoutes.billing,
      '/schedule': AppRoutes.schedule,
      '/chat': AppRoutes.chat,
      '/assignments': AppRoutes.assignments,
    };

    final route = allowedRoutes[deepLink];
    if (route != null) {
      Get.toNamed(route);
    } else {
      if (kDebugMode) {
        debugPrint('[FCM Deep Link] Unknown route: $deepLink');
      }
    }
  }

  static String _resolveChannel(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    if (type == 'billing' || type == 'payment') {
      return NotificationChannels.paymentsAlerts;
    }
    return NotificationChannels.classUpdates;
  }

  /// Persist a received FCM message to the drift CachedNotifications table.
  static Future<void> _persistNotificationToDrift(
      RemoteMessage message) async {
    try {
      final db = Get.find<AppDatabase>();
      final id = message.messageId ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final parentId = message.data['target_parent_id'] as String? ?? '';

      await db.upsertNotification(
        CachedNotificationsCompanion.insert(
          id: id,
          targetParentId: parentId,
          title: drift.Value(message.notification?.title ?? ''),
          body: drift.Value(message.notification?.body ?? ''),
          type: drift.Value(message.data['type'] as String? ?? 'general'),
          deepLink: drift.Value(message.data['deep_link'] as String?),
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] Drift persist error: $e');
    }
  }
}
