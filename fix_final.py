import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# Remove unused imports
text = re.sub(r'import \'../../../core/widgets/ujob_checkbox\.dart\';\n', '', text)
text = re.sub(r'import \'../../../core/widgets/ujob_alert_dialog\.dart\';\n', '', text)

# Remove unused _selectedIds
text = re.sub(r'  final _selectedIds = <String>\[\];\n', '', text)

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

