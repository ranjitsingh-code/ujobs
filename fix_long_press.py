import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# Remove onLongPress from instantiation
text = re.sub(r'                                  onLongPress: \(\) \{\n                                    if \(!_isSelectionMode\) \{\n                                      _showSingleNotifOptions\(context, ref, n\);\n                                    \}\n                                  \},', '', text)

# Remove _confirmDeleteSingle completely
text = re.sub(r'  void _confirmDeleteSingle\(WidgetRef ref, AppNotification n\) \{.*?\n  \}\n\n', '', text, flags=re.DOTALL)

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

