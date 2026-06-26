import re

# Fix notification_service.dart
with open('lib/features/shared/notifications/notification_service.dart', 'r') as f:
    text = f.read()

text = text.replace('_api.get', '_api.dio.get')
text = text.replace('_api.patch', '_api.dio.patch')
text = text.replace('_api.delete', '_api.dio.delete')

with open('lib/features/shared/notifications/notification_service.dart', 'w') as f:
    f.write(text)


# Fix notifications_provider.dart
with open('lib/features/shared/notifications/notifications_provider.dart', 'r') as f:
    text = f.read()

# I will add markAllRead and toggleReadStatus
# Since there's no actual API for toggleReadStatus, I will just call markAsRead
# For markAllRead, I will just loop and call markAsRead for unread ones (or just assume local change for now).

add_methods = """
  Future<void> toggleReadStatus(String id) async {
    final notif = state.value?.notifications.firstWhere((n) => n.id == id);
    if (notif != null && !notif.isRead) {
      await markAsRead(id);
    }
  }

  Future<void> markAllRead() async {
    if (state.value == null) return;
    try {
      final unread = state.value!.notifications.where((n) => !n.isRead).toList();
      for (final n in unread) {
        await markAsRead(n.id);
      }
    } catch (e) {
      // Ignore
    }
  }
"""

text = text.replace('Future<void> markAsRead(String id) async {', add_methods + '\n  Future<void> markAsRead(String id) async {')

with open('lib/features/shared/notifications/notifications_provider.dart', 'w') as f:
    f.write(text)

