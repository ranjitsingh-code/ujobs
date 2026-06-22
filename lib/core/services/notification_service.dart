import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const _channelId = 'ujob_high';
const _channelName = 'UJob Notifications';

final _localNotifs = FlutterLocalNotificationsPlugin();

const _androidDetails = AndroidNotificationDetails(
  _channelId,
  _channelName,
  importance: Importance.high,
  priority: Priority.high,
);
const _notifDetails = NotificationDetails(
  android: _androidDetails,
  iOS: DarwinNotificationDetails(),
);

// Must be top-level — invoked when app is fully terminated
@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  final n = message.notification;
  if (n == null) return;
  await _localNotifs.show(
    id: message.hashCode,
    title: n.title,
    body: n.body,
    notificationDetails: _notifDetails,
  );
}

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    // Android: create high-priority channel (required for Android 8+)
    await _localNotifs
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.high,
          ),
        );

    // v22 API: named parameter `settings`
    await _localNotifs.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    // Request permission (iOS prompt + Android 13+ POST_NOTIFICATIONS)
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Foreground: FCM suppresses notification UI by default — show locally
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n == null) return;
      _localNotifs.show(
        id: msg.hashCode,
        title: n.title,
        body: n.body,
        notificationDetails: _notifDetails,
      );
    });

    if (kDebugMode) {
      final token = await _fcm.getToken();
      debugPrint('[FCM] Device token: $token');
    }
  }

  static Future<String?> getToken() => _fcm.getToken();

  static void onTokenRefresh(void Function(String token) callback) =>
      _fcm.onTokenRefresh.listen(callback);

  // Call after login — registers this device's FCM token with your backend
  static Future<void> registerDeviceToken(
    Future<void> Function(String token) sendToServer,
  ) async {
    final token = await _fcm.getToken();
    if (token != null) await sendToServer(token);
    _fcm.onTokenRefresh.listen(sendToServer);
  }
}
