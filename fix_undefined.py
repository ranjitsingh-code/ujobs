import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# 1. Line 83: if (!_isSelectionMode) ... -> just remove the if statement check (or remove _isSelectionMode references in the build method)
# Let's just find and replace any remaining _isSelectionMode references
text = re.sub(r'          if \(!_isSelectionMode\) _buildTabs\(\),\n', '          _buildTabs(),\n', text)

# 2. Line 184 & 190: The select notifications option in the top app bar?
# Wait, let's see what is at 184 and 190.
