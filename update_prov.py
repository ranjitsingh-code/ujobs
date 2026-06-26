import re

with open('lib/features/shared/notifications/notifications_provider.dart', 'r') as f:
    text = f.read()

old_mark_all_read = """  Future<void> markAllRead() async {
    if (state.value == null) return;
    try {
      final unread = state.value!.notifications.where((n) => !n.isRead).toList();
      for (final n in unread) {
        await markAsRead(n.id);
      }
    } catch (e) {
      // Ignore
    }
  }"""

new_mark_all_read = """  Future<void> markAllRead() async {
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
  }"""

text = text.replace(old_mark_all_read, new_mark_all_read)

with open('lib/features/shared/notifications/notifications_provider.dart', 'w') as f:
    f.write(text)

