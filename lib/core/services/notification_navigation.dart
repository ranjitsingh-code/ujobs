// rootNavigatorKey's context is the app's own root Navigator — it persists
// for the whole app lifetime, not the disposable per-screen context this
// lint guards against, so it's safe to use after the await above.
// ignore_for_file: use_build_context_synchronously
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/role_provider.dart';
import '../router/app_router.dart';
import '../storage/secure_storage.dart';
import '../../features/shared/chat/conversation_provider.dart';
import '../../features/shared/notifications/notifications_provider.dart';

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

// Lets a mounted ChatScreen register a manual-refresh callback keyed by its
// own conversationId — chat no longer polls, so a "message" push tapped
// while already viewing that exact conversation needs some way to pull the
// new message in instead of silently doing nothing (the early-return below
// used to be a no-op).
final Map<String, VoidCallback> _activeChatRefreshCallbacks = {};

// Which conversation (if any) is currently mounted on screen — set/cleared
// directly from ChatScreen's initState/dispose, the same synchronous
// register/unregister calls that already exist for the refresh callback
// above. Deciding push-vs-replace by parsing GoRouter's own derived
// `currentConfiguration.uri` proved racy: two notifications landing close
// together can get their deferred navigation batched into the same frame,
// and GoRouter's location isn't guaranteed to reflect the first one's push
// by the time the second reads it — causing a duplicate chat screen. This
// plain variable is tied to real widget lifecycle instead, so it can't lag.
String? _currentOpenChatId;

void registerChatRefreshCallback(String conversationId, VoidCallback cb) {
  _activeChatRefreshCallbacks[conversationId] = cb;
  _currentOpenChatId = conversationId;
}

void unregisterChatRefreshCallback(String conversationId) {
  _activeChatRefreshCallbacks.remove(conversationId);
  // Only clear if we're still "current" — a pushReplacement mounts the new
  // ChatScreen (which re-registers) before the old one's dispose fires, so
  // by the time the old one unregisters, _currentOpenChatId already holds
  // the new id and must not be wiped out from under it.
  if (_currentOpenChatId == conversationId) _currentOpenChatId = null;
}

// Chat no longer polls, so without this a new message only shows up once
// the user manually pulls to refresh or taps the notification itself.
// Foreground FCM delivery of a "message" push means fresh data exists
// right now — refresh both this viewer's own conversation list (so the
// Messages tab's unread badge/last-message preview update live) and, if
// the exact conversation the push is about is already open on screen,
// that chat's messages too — all without polling at all, only exactly
// when new data actually exists.
//
// The bell icon's unread count (unreadNotificationCountProvider) no longer
// polls either — every notification type bumps that count on the backend
// (not just "message"), so it's refreshed here for any type, not gated to
// the message-specific branch above.
void handleForegroundMessage(Map<String, dynamic> data) {
  final context = rootNavigatorKey.currentContext;
  if (context == null) return;
  final container = ProviderScope.containerOf(context, listen: false);
  container.invalidate(unreadNotificationCountProvider);

  if (data['type']?.toString() != 'message') return;
  final isEmployer = container.read(activeRoleProvider.notifier).isEmployer;
  if (isEmployer) {
    container.read(conversationsProvider.notifier).refresh();
  } else {
    container.read(seekerConversationsProvider.notifier).refresh();
  }
  final chatId = data['chat_id']?.toString();
  if (chatId != null) _activeChatRefreshCallbacks[chatId]?.call();
}

Future<void> handleNotificationTap(
  Map<String, dynamic> data, {
  bool isColdStart = false,
}) async {
  final type = data['type']?.toString();
  final dedupeKey = '$type:${data['chat_id'] ?? data['application_id'] ?? data['app_id'] ?? data['job_id'] ?? ''}';
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

  // Covers the role lookup below plus the frame-defer wait further down —
  // without it this whole gap renders as a frozen screen with no feedback
  // that the tap even registered.
  EasyLoading.show();

  final role = await SecureStorage().getRole();
  final isEmployer = role == 'employer';

  // Fetched after the only await in this function so every use below is
  // synchronous — no risk of the navigator having gone away mid-await.
  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    EasyLoading.dismiss();
    return;
  }

  // Navigator/GoRouter mutations (push, pushReplacement, pop) called while
  // the Navigator is already mid-transition from a previous one throw
  // "Failed assertion: '!_debugLocked'" and can leave the nav stack half
  // updated (seen as a broken back button afterward) — FCM's tap callback
  // can fire at any point in the frame, including mid-transition. Deferring
  // to the next frame guarantees it never runs re-entrantly.
  //
  // The currentLocation-based push-vs-replace decision below lives INSIDE
  // this same deferred callback (not computed earlier, then just the push
  // deferred) so the decision and the action happen atomically off the
  // same up-to-date snapshot — reading currentLocation early and acting on
  // it a frame later let reality drift in between, causing a duplicate
  // chat screen to get pushed instead of the existing one being replaced.
  SchedulerBinding.instance.addPostFrameCallback((_) {
    EasyLoading.dismiss();

    // Cold start (tap launched the app from terminated): the app is still
    // sitting on Splash ('/') when this fires, pushed there imperatively by
    // main.dart before the router's own splash-timer-gated redirect has had
    // a chance to run. context.push() below doesn't update GoRouter's own
    // tracked "current location" — it stays '/' underneath the pushed page.
    // A few seconds later the splash timer resolves, the router re-checks
    // its redirect rules, still sees loc == '/', and replaces the ENTIRE
    // stack with the dashboard — wiping out whatever we just pushed. Fix:
    // sync the router to the dashboard via go() FIRST (so its tracked
    // location is no longer '/'), then push the real target on top of that
    // now-stable route. Only needed on cold start — a backgrounded/foreground
    // tap is already sitting on a real (non-'/') tracked location.
    if (isColdStart) {
      context.go(isEmployer ? '/employer' : '/seeker');
    }

    switch (type) {
      case 'message':
        final chatId = data['chat_id']?.toString();
        if (chatId == null || chatId.isEmpty) break;
        final target = '/conversations/$chatId';
        _navLog('message tap: currentOpenChatId=$_currentOpenChatId target=$target');
        if (_currentOpenChatId == chatId) {
          _navLog('Already on this chat screen — refreshing instead of navigating');
          _activeChatRefreshCallbacks[chatId]?.call();
          return;
        }
        final extra = {
          'otherId': data['sender_id']?.toString() ?? '',
          'name': data['sender_name']?.toString() ?? '',
          'avatar': data['sender_avatar']?.toString(),
          'jobId': data['job_id']?.toString(),
          'applicantId': data['application_id']?.toString(),
        };
        // Already viewing *some other* chat screen — replace it instead of
        // pushing on top, so different-conversation notification taps don't
        // pile up a chain of chat screens the user has to back through.
        if (_currentOpenChatId != null) {
          _navLog('REPLACING chat screen with $target');
          context.pushReplacement(target, extra: extra);
          return;
        }
        _navLog('PUSHING $target');
        context.push(target, extra: extra);
        return;

      case 'new_application':
        // Spec (docs/fcm_push_notification_spec.txt) says `application_id`,
        // but the live payload has been observed sending `app_id` instead —
        // accept both so a tap still navigates while that gets fixed upstream.
        final applicationId =
            data['application_id']?.toString() ?? data['app_id']?.toString();
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

    // Unrecognized (or missing-id) type — fall back to `screen` (spec name)
    // or `redirect_to` (observed live payload uses this instead), then to
    // the relevant list screen, so an app version that doesn't know a
    // brand-new `type` yet still lands somewhere sensible instead of nothing.
    final screen = data['screen']?.toString() ?? data['redirect_to']?.toString();
    switch (screen) {
      case 'chat_screen':
        context.push(isEmployer ? '/employer/messages' : '/seeker/messages');
        return;
      case 'job_details':
        context.push(isEmployer ? '/employer/jobs' : '/seeker/jobs');
        return;
      case 'applicant_profile':
      case 'applicant_details':
        context.push('/employer/applicants');
        return;
      case 'application_details':
        context.push(isEmployer ? '/employer/applicants' : '/seeker/applied');
        return;
    }
  });
}
