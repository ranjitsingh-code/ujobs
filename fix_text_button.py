import re

with open('lib/features/employer/settings/employer_settings_screen.dart', 'r') as f:
    text = f.read()

old_cancel = """          TextButton(
            onTap: () => Navigator.pop(ctx),"""
new_cancel = """          TextButton(
            onPressed: () => Navigator.pop(ctx),"""
text = text.replace(old_cancel, new_cancel)

old_delete = """          TextButton(
            onTap: () {"""
new_delete = """          TextButton(
            onPressed: () {"""
text = text.replace(old_delete, new_delete)

with open('lib/features/employer/settings/employer_settings_screen.dart', 'w') as f:
    f.write(text)
