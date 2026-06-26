import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# 1. Remove _showSingleNotifOptions method completely
text = re.sub(r'  void _showSingleNotifOptions\(.*?\}\n\n', '\n', text, flags=re.DOTALL)

# 2. Remove onLongPress from _NotificationCard instantiation
target_instantiation = """                                  onLongPress: () {
                                    if (_isSelectionMode) return;
                                    _showSingleNotifOptions(context, ref, n);
                                  },"""
text = text.replace(target_instantiation, "")

# 3. Remove onLongPress from _NotificationCard definition
text = text.replace("    required this.onLongPress,\n", "")
text = text.replace("  final VoidCallback onLongPress;\n", "")
text = text.replace("          onLongPress: onLongPress,\n", "")

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

