import re

with open('lib/core/widgets/ujob_notification_button.dart', 'r') as f:
    text = f.read()

# Replace the old provider import with the new one
text = text.replace(
    "import '../../features/shared/notifications/notifications_screen.dart';",
    "import '../../features/shared/notifications/notifications_provider.dart';"
)

# Update unreadCount usage
text = text.replace(
    "final unreadCount = ref.watch(notifsProvider).where((n) => !n.isRead).length;",
    "final unreadCount = ref.watch(notificationsProvider).valueOrNull?.unreadCount ?? 0;"
)

with open('lib/core/widgets/ujob_notification_button.dart', 'w') as f:
    f.write(text)

