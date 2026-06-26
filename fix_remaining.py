import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# Remove _confirmDeleteMultiple
text = re.sub(r'  void _confirmDeleteMultiple\(.*?\}\n\n', '', text, flags=re.DOTALL)

# Remove select button in app bar
text = re.sub(r'          if \(!_isSelectionMode\)\n            IconButton\(\n              onPressed: _toggleSelectionMode,\n              icon: const HugeIcon\(\n                icon: HugeIcons.strokeRoundedTaskDone01,\n                color: AppColors.text,\n                size: 24,\n              \),\n            \),', '', text)

# Remove if (!_isSelectionMode) _buildTabs() -> _buildTabs()
text = re.sub(r'          if \(!_isSelectionMode\) _buildTabs\(\),\n', '          _buildTabs(),\n', text)

# Remove the checkbox logic inside _NotifCard if any still remains
# Wait, let's fix the undefined variables in _NotifCard.
# The errors were:
# error • Undefined name 'isSelectionMode'. Try correcting the name to one that is defined, or defining the name • lib/features/shared/notifications/notifications_screen.dart:490:21 • undefined_identifier
# error • Undefined name 'isSelected'. Try correcting the name to one that is defined, or defining the name • lib/features/shared/notifications/notifications_screen.dart:494:30 • undefined_identifier
# Let's replace those specific checks in the build method.

text = re.sub(r'        border: Border\.all\(\n          color: isSelectionMode && isSelected\n              \? primaryColor\n              : \(notif\.isRead\n                    \? AppColors\.borderLight\n                    : borderColor\.withValues\(alpha: 0\.5\)\),\n        \),', '        border: Border.all(\n          color: notif.isRead ? AppColors.borderLight : borderColor.withValues(alpha: 0.5),\n        ),', text)

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

