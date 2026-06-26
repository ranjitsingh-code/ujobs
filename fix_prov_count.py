import re

with open('lib/features/shared/notifications/notifications_provider.dart', 'r') as f:
    text = f.read()

unread_prov_code = """
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return await service.getUnreadCount();
});
"""

text = text + '\n' + unread_prov_code

with open('lib/features/shared/notifications/notifications_provider.dart', 'w') as f:
    f.write(text)

