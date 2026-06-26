import re

with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

# 1. Remove the "Select Notifications" ListTile
target_tile = """            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedTaskDone01,
                color: AppColors.text,
                size: 24.r,
              ),
              title: Text('Select Notifications', style: AppText.bodyBold),
              onTap: () {
                Navigator.pop(ctx);
                _toggleSelectionMode();
              },
            ),"""
text = text.replace(target_tile, "")

# 2. Remove _toggleSelectionMode function
text = re.sub(r'  void _toggleSelectionMode\(\) \{.*?\n  \}\n\n', '', text, flags=re.DOTALL)

# 3. Remove _isSelectionMode variable and _selectedIds
text = re.sub(r'  bool _isSelectionMode = false;\n', '', text)
text = re.sub(r'  final _selectedIds = <String>\[\];\n', '', text)

# 4. Remove the selection UI block (the header with checkbox)
text = re.sub(r'                    if \(_isSelectionMode\)\n                      Padding\(\n.*?                        child: Row\(\n.*?                          children: \[\n.*?                            UJobCheckbox\(\n.*?                            \),\n.*?                            SizedBox\(width: 12\.w\),\n.*?                            Text\(\n.*?                              style: AppText\.bodyBold,\n.*?                            \),\n.*?                            const Spacer\(\),\n.*?                            if \(_selectedIds\.isNotEmpty\)\n.*?                              TextButton\(\n.*?                                onPressed: \(\) \{\n.*?                                  _confirmDeleteMultiple\(ref, _selectedIds\);\n.*?                                \},\n.*?                                child: Text\(\n.*?                                  \'Delete\',\n.*?                                  style: AppText\.bodyBold\n.*?                                      \.copyWith\(color: AppColors\.error\),\n.*?                                \),\n.*?                              \),\n.*?                          \],\n.*?                        \),\n                      \),\n', '', text, flags=re.DOTALL)

# 5. Remove _confirmDeleteMultiple function
text = re.sub(r'  void _confirmDeleteMultiple\(WidgetRef ref, List<String> ids\) \{.*?\n  \}\n\n', '', text, flags=re.DOTALL)

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)

