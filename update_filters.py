import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# Locate where we filter by tabs
filter_target = """                final filter = _currentTabs[pageIndex];
                final notifs = switch (filter) {
                  'unread' =>
                    state.notifications.where((n) => !n.isRead).toList(),
                  _ => state.notifications,
                };"""

filter_replacement = """                final filter = _currentTabs[pageIndex];
                final notifs = switch (filter) {
                  'all' => state.notifications,
                  'unread' => state.notifications.where((n) => !n.isRead).toList(),
                  'application' => state.notifications.where((n) => n.type == 'new_application').toList(),
                  'message' => state.notifications.where((n) => n.type == 'message').toList(),
                  'system' => state.notifications.where((n) => n.type != 'new_application' && n.type != 'message').toList(),
                  _ => state.notifications,
                };"""

text = text.replace(filter_target, filter_replacement)

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

