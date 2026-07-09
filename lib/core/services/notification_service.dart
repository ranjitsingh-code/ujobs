import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../storage/secure_storage.dart';
import 'notification_navigation.dart';

const _channelId = 'ujob_high';
const _channelName = 'UJob Notifications';

// Firebase brand amber (#FFA000) via ANSI truecolor — makes FCM log lines
// jump out from the rest of console noise.
const _fcmColor = '\x1B[38;2;255;160;0m';
const _ansiReset = '\x1B[0m';

void _fcmLog(String tag, Map<String, dynamic> data) {
  debugPrint('$_fcmColor[FCM]$tag data: $data$_ansiReset');
}

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
  _fcmLog('[background]', message.data);
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

  // iOS/macOS only: FCM's getToken() throws apns-token-not-set if called
  // before the OS has handed back the APNs token (async native callback
  // after permission is granted). Poll briefly; give up after ~5s so this
  // never hangs forever (e.g. simulators without push capability).
  static Future<void> _waitForApnsTokenIfNeeded() async {
    if (!Platform.isIOS && !Platform.isMacOS) return;
    for (var i = 0; i < 10; i++) {
      try {
        if (await _fcm.getAPNSToken() != null) return;
      } catch (_) {
        // Not ready yet — same as null, keep waiting.
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // Best-effort token fetch — never throws (safe to call from anywhere,
  // including app startup, without risking a crash).
  static Future<String?> _safeGetToken() async {
    try {
      await _waitForApnsTokenIfNeeded();
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('[FCM] Could not get device token: $e');
      return null;
    }
  }

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
      // Tap on the local notification we show below, while app is in the
      // foreground — payload carries the same `data` map FCM sent us.
      onDidReceiveNotificationResponse: (response) {
        debugPrint('[FCM][local-tap] id=${response.id} actionId=${response.actionId}');
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          handleNotificationTap(jsonDecode(payload) as Map<String, dynamic>);
        } catch (_) {}
      },
    );

    // Request permission (iOS prompt + Android 13+ POST_NOTIFICATIONS)
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Foreground: FCM suppresses notification UI by default — show locally
    FirebaseMessaging.onMessage.listen((msg) {
      _fcmLog('[foreground]', msg.data);
      final n = msg.notification;
      if (n == null) return;
      _localNotifs.show(
        id: msg.hashCode,
        title: n.title,
        body: n.body,
        notificationDetails: _notifDetails,
        payload: jsonEncode(msg.data),
      );
    });

    // Tap while app is backgrounded (not terminated) — OS showed FCM's own
    // notification, tapping it resumes the app straight into this listener.
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      _fcmLog('[opened]', msg.data);
      handleNotificationTap(msg.data);
    });

    // Tap that cold-started the app from fully terminated.
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _fcmLog('[initial]', initialMessage.data);
      await handleNotificationTap(initialMessage.data);
    }

    // Cache every token FCM hands us (initial + any later rotation) so a
    // future "update device token" endpoint can tell if this device's
    // token has changed since it last told the backend, without needing
    // to hit FCM again. Backend doesn't yet expose that endpoint for an
    // already-authenticated session — until it does, a rotated token only
    // reaches the server on the user's next login/register.
    final token = await _safeGetToken();
    if (token != null) await SecureStorage().saveFcmToken(token);
    if (kDebugMode) debugPrint('[FCM] Device token: $token');

    _fcm.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM] Token refreshed: $newToken');
      await SecureStorage().saveFcmToken(newToken);
    });
  }

  static Future<String?> getToken() => _safeGetToken();

  // Spread into any auth request body (login/register) — backend registers
  // the device for FCM push directly on those endpoints rather than a
  // separate call. Empty map if no token available yet (e.g. simulator
  // without push capability, or permission denied) so the request still
  // goes through without these optional fields.
  static Future<Map<String, dynamic>> deviceRegistrationFields() async {
    final token = await _safeGetToken();
    if (token == null || token.isEmpty) return {};
    await SecureStorage().saveFcmToken(token);
    return {
      'device_type': Platform.isIOS ? 'ios' : 'android',
      'device_token': token,
    };
  }

  static void onTokenRefresh(void Function(String token) callback) =>
      _fcm.onTokenRefresh.listen(callback);

  // Call after login — registers this device's FCM token with your backend
  static Future<void> registerDeviceToken(
    Future<void> Function(String token) sendToServer,
  ) async {
    final token = await _safeGetToken();
    if (token != null) await sendToServer(token);
    _fcm.onTokenRefresh.listen(sendToServer);
  }
}
