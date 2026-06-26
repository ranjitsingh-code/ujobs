import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

target = """                var filtered = notifsAsync.valueOrNull?.notifications ?? [];
                if (filter == 'unread') {
                  filtered = filtered.where((n) => !n.isRead).toList();
                } else if (filter != 'all') {
                  filtered = filtered.where((n) => n.type == filter).toList();
                }"""

replacement = """                var filtered = notifsAsync.valueOrNull?.notifications ?? [];
                if (filter == 'unread') {
                  filtered = filtered.where((n) => !n.isRead).toList();
                } else if (filter == 'application') {
                  filtered = filtered.where((n) => n.type == 'new_application' || n.type == 'application').toList();
                } else if (filter == 'message') {
                  filtered = filtered.where((n) => n.type == 'message').toList();
                } else if (filter == 'system') {
                  filtered = filtered.where((n) => n.type != 'new_application' && n.type != 'application' && n.type != 'message').toList();
                }"""

text = text.replace(target, replacement)

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

