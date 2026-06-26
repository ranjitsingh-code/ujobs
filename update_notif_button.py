import re

with open('lib/core/widgets/ujob_notification_button.dart', 'r') as f:
    text = f.read()

# I will replace the unreadCount logic to read from unreadNotificationCountProvider
text = text.replace(
    "final unreadCount = ref.watch(notificationsProvider).valueOrNull?.unreadCount ?? 0;",
    "final unreadCount = ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;"
)

with open('lib/core/widgets/ujob_notification_button.dart', 'w') as f:
    f.write(text)

