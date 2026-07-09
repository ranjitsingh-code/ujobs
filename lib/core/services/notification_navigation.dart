// rootNavigatorKey's context is the app's own root Navigator — it persists
// for the whole app lifetime, not the disposable per-screen context this
// lint guards against, so it's safe to use after the await above.
// ignore_for_file: use_build_context_synchronously
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../storage/secure_storage.dart';

const _navColor = '\x1B[38;2;255;160;0m';
const _navReset = '\x1B[0m';
void _navLog(String msg) => debugPrint('$_navColor[NAV]$msg$_navReset');

/// Single source of truth for "given this notification's data, go to the
/// exact right screen" — called from three independent places (in-app
/// notification list tap, FCM tap while app is backgrounded, and FCM tap
/// that cold-started the app from terminated) so all three behave
/// identically instead of duplicating the same switch logic three times.
///
/// Matches docs/fcm_push_notification_spec.txt exactly: `type` is the
/// primary routing key, `screen` is only consulted as a fallback for a
/// `type` this app version doesn't recognize yet.

// A single physical notification tap can trigger this function twice —
// e.g. FCM firing both onMessageOpenedApp and getInitialMessage for the
// same cold-start tap. Both calls would await SecureStorage().getRole()
// concurrently, both read the pre-navigation route, and both push —
// hence a duplicate chat screen the "already on this screen" check below
// can't catch (it runs after the await, once per call, before either has
// navigated). This guard is set synchronously, before any await, so the
// second concurrent call for the same target bails immediately.
String? _lastHandledKey;
DateTime? _lastHandledAt;

Future<void> handleNotificationTap(Map<String, dynamic> data) async {
  final type = data['type']?.toString();
  final dedupeKey = '$type:${data['chat_id'] ?? data['application_id'] ?? data['job_id'] ?? ''}';
  final now = DateTime.now();
  _navLog('called key=$dedupeKey data=$data');
  if (_lastHandledKey == dedupeKey &&
      _lastHandledAt != null &&
      now.difference(_lastHandledAt!) < const Duration(seconds: 2)) {
    _navLog('BLOCKED by dedupe (same key within 2s)');
    return;
  }
  _lastHandledKey = dedupeKey;
  _lastHandledAt = now;

  final role = await SecureStorage().getRole();
  final isEmployer = role == 'employer';

  // Fetched after the only await in this function so every use below is
  // synchronous — no risk of the navigator having gone away mid-await.
  final context = rootNavigatorKey.currentContext;
  if (context == null) return;

  switch (type) {
    case 'message':
      final chatId = data['chat_id']?.toString();
      if (chatId == null || chatId.isEmpty) break;
      // Second message from the same conversation while its chat screen is
      // already open would otherwise push a duplicate copy onto the stack —
      // back button then has to pop through both to leave the chat.
      final currentLocation =
          GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
      _navLog('message tap: currentLocation=$currentLocation target=/conversations/$chatId');
      if (currentLocation == '/conversations/$chatId') {
        _navLog('BLOCKED — already on this chat screen');
        return;
      }
      _navLog('PUSHING /conversations/$chatId');
      context.push(
        '/conversations/$chatId',
        extra: {
          'otherId': data['sender_id']?.toString() ?? '',
          'name': data['sender_name']?.toString() ?? '',
          'avatar': data['sender_avatar']?.toString(),
        },
      );
      return;

    case 'new_application':
      final applicationId = data['application_id']?.toString();
      if (applicationId == null || applicationId.isEmpty) break;
      context.push('/employer/applicants/$applicationId');
      return;

    case 'job_approved':
      final jobId = data['job_id']?.toString();
      if (jobId == null || jobId.isEmpty) break;
      context.push(isEmployer ? '/employer/jobs/$jobId' : '/seeker/jobs/$jobId');
      return;

    case 'stage_change':
      final status = data['status']?.toString();
      var tabIndex = 0;
      if (status == 'shortlisted') tabIndex = 3;
      if (status == 'interview') tabIndex = 4;
      if (status == 'offered') tabIndex = 5;
      if (status == 'hired') tabIndex = 6;
      if (status == 'rejected') tabIndex = 7;
      context.push('/seeker/applied', extra: tabIndex);
      return;

    case 'application_submitted':
      final jobId = data['job_id']?.toString();
      if (jobId == null || jobId.isEmpty) {
        context.push('/seeker/applied');
        return;
      }
      context.push('/seeker/jobs/$jobId');
      return;
  }

  // Unrecognized (or missing-id) type — fall back to `screen`, then to the
  // relevant list screen, so an app version that doesn't know a brand-new
  // `type` yet still lands somewhere sensible instead of doing nothing.
  switch (data['screen']?.toString()) {
    case 'chat_screen':
      context.push(isEmployer ? '/employer/messages' : '/seeker/messages');
      return;
    case 'job_details':
      context.push(isEmployer ? '/employer/jobs' : '/seeker/jobs');
      return;
    case 'applicant_profile':
      context.push('/employer/applicants');
      return;
    case 'application_details':
      context.push(isEmployer ? '/employer/applicants' : '/seeker/applied');
      return;
  }
}
