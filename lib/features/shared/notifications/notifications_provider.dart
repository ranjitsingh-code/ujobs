import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/notification.dart';
import 'notification_service.dart';

class NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final bool hasMore;
  final int page;
  final bool isLoadingMore;

  const NotificationState({
    required this.notifications,
    required this.unreadCount,
    required this.hasMore,
    required this.page,
    this.isLoadingMore = false,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? hasMore,
    int? page,
    bool? isLoadingMore,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final notificationsFilterProvider = StateProvider<String>((ref) => 'all');
final notificationsSearchProvider = StateProvider<String>((ref) => '');

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, NotificationState>(
        NotificationsNotifier.new);

class NotificationsNotifier extends AsyncNotifier<NotificationState> {
  @override
  Future<NotificationState> build() async {
    final service = ref.watch(notificationServiceProvider);
    final type = ref.watch(notificationsFilterProvider);
    final search = ref.watch(notificationsSearchProvider);

    final res = await service.getNotifications(
      page: 1,
      type: type,
      search: search,
    );

    return NotificationState(
      notifications: res.notifications,
      unreadCount: res.unreadCount,
      hasMore: res.totalPages > 1,
      page: 1,
    );
  }

  Future<void> loadMore() async {
    if (state.value == null ||
        !state.value!.hasMore ||
        state.value!.isLoadingMore) {
      return;
    }

    state = AsyncData(state.value!.copyWith(isLoadingMore: true));

    try {
      final service = ref.read(notificationServiceProvider);
      final type = ref.read(notificationsFilterProvider);
      final search = ref.read(notificationsSearchProvider);
      final nextPage = state.value!.page + 1;

      final res = await service.getNotifications(
        page: nextPage,
        type: type,
        search: search,
      );

      state = AsyncData(
        state.value!.copyWith(
          notifications: [...state.value!.notifications, ...res.notifications],
          unreadCount: res.unreadCount,
          hasMore: nextPage < res.totalPages,
          page: nextPage,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  
  Future<void> toggleReadStatus(String id) async {
    final notif = state.value?.notifications.firstWhere((n) => n.id == id);
    if (notif != null && !notif.isRead) {
      await markAsRead(id);
    }
  }

  Future<void> markAllRead() async {
    if (state.value == null) return;
    try {
      final service = ref.read(notificationServiceProvider);
      await service.markAllAsRead();
      
      final notifications = state.value!.notifications.map((n) {
        if (!n.isRead) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();
      
      state = AsyncData(state.value!.copyWith(notifications: notifications));
      ref.invalidate(unreadNotificationCountProvider);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.markAsRead(id);
      if (state.value != null) {
        final notifications = state.value!.notifications.map((n) {
          if (n.id == id && !n.isRead) {
            return n.copyWith(isRead: true, readAt: DateTime.now());
          }
          return n;
        }).toList();
        state = AsyncData(state.value!.copyWith(notifications: notifications));
        // Force unread count stream to refresh instantly
        ref.invalidate(unreadNotificationCountProvider);
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> deleteNotifications(List<String> ids) async {
    try {
      final service = ref.read(notificationServiceProvider);
      for (final id in ids) {
        await service.deleteNotification(id);
      }
      if (state.value != null) {
        final notifications = state.value!.notifications
            .where((n) => !ids.contains(n.id))
            .toList();
        state = AsyncData(state.value!.copyWith(notifications: notifications));
        // Force unread count stream to refresh instantly
        ref.invalidate(unreadNotificationCountProvider);
      }
    } catch (e) {
      // Ignore
    }
  }
}


// Single fetch, no polling — refreshed only by an actual trigger:
// app resume (see EmployerShell/SeekerShell), a foreground push notification
// arriving (see handleForegroundMessage in notification_navigation.dart), or
// an explicit mark-as-read/delete action (ref.invalidate calls above).
final unreadNotificationCountProvider = FutureProvider<int>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.getUnreadCount();
});
