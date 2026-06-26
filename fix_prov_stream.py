import re

with open('lib/features/shared/notifications/notifications_provider.dart', 'r') as f:
    text = f.read()

# Replace FutureProvider with StreamProvider
old_code = """final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return await service.getUnreadCount();
});"""

new_code = """final unreadNotificationCountProvider = StreamProvider<int>((ref) async* {
  final service = ref.watch(notificationServiceProvider);
  
  // Initial fetch
  yield await service.getUnreadCount();
  
  // Poll every 30 seconds
  await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
    yield await service.getUnreadCount();
  }
});"""

text = text.replace(old_code, new_code)

with open('lib/features/shared/notifications/notifications_provider.dart', 'w') as f:
    f.write(text)

