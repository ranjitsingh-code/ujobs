import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# Remove the selection header block inside build
header_pattern = r'                    if \(_isSelectionMode\)\n                      Padding\(.*?child: Row\(.*?\]\,\n                        \),\n                      \),\n'
text = re.sub(header_pattern, '', text, flags=re.DOTALL)

# Remove the selection-mode related arguments from _NotifCard instantiation
text = re.sub(r'                                  isSelectionMode: _isSelectionMode,\n                                  isSelected: isSelected,\n', '', text)
text = re.sub(r'                                final isSelected = _selectedIds\.contains\(n\.id\);\n\n', '', text)

# Rewrite the onTap logic in _NotifCard
ontap_pattern = r'                                  onTap: \(\) \{\n                                    if \(_isSelectionMode\) \{.*?\} else \{\n(.*?)                                    \}\n                                  \},'
def ontap_repl(m):
    return '                                  onTap: () {\n' + m.group(1) + '                                  },'
text = re.sub(ontap_pattern, ontap_repl, text, flags=re.DOTALL)

# Remove _isSelectionMode and _selectedIds variables and _toggleSelectionMode function
text = re.sub(r'  bool _isSelectionMode = false;\n  final _selectedIds = <String>\[\];\n\n', '', text)

# Update _NotifCard constructor and properties
text = re.sub(r'    required this\.isSelectionMode,\n    required this\.isSelected,\n', '', text)
text = re.sub(r'  final bool isSelectionMode;\n  final bool isSelected;\n', '', text)

# Clean up _NotifCard build method (removing isSelected and isSelectionMode)
text = re.sub(r'        color: isSelected\n            \? primaryColor\.withValues\(alpha: 0\.05\)\n            : \(notif\.isRead', '        color: (notif.isRead', text)
text = re.sub(r'          color: isSelected\n              \? primaryColor\n              : \(notif\.isRead', '          color: (notif.isRead', text)

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

