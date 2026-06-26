import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# Replace imports and mock data
text = re.sub(
    r"class Notif \{.*?\}\s+final _empMock = \[.*?\];\s+final _seekerMock = \[.*?\];\s+class NotifsNotifier.*?final notifsProvider =.*?;\s+",
    "import '../../../core/models/notification.dart';\nimport 'notifications_provider.dart';\nimport '../../../core/widgets/ujob_loading.dart';\n\n",
    text,
    flags=re.DOTALL
)

# Update build method to handle AsyncValue
text = re.sub(
    r"final notifs = ref.watch\(notifsProvider\);",
    """final notifsAsync = ref.watch(notificationsProvider);""",
    text
)

text = re.sub(
    r"var filtered = notifs;",
    r"var filtered = notifsAsync.valueOrNull?.notifications ?? [];",
    text
)

# Update Notif to AppNotification
text = text.replace("Notif notif", "AppNotification notif")
text = text.replace("Notif n", "AppNotification n")
text = text.replace("<Notif>", "<AppNotification>")

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

