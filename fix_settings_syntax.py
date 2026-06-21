import re

with open('lib/features/employer/settings/employer_settings_screen.dart', 'r') as f:
    text = f.read()

text = text.replace("AppText.bodySm", "AppText.caption")
text = text.replace("text: 'Update Password'", "label: 'Update Password'")
text = text.replace("onPressed: () => Navigator.pop(ctx)", "onTap: () => Navigator.pop(ctx)")
text = text.replace("text: 'Update $fieldName'", "label: 'Update $fieldName'")

with open('lib/features/employer/settings/employer_settings_screen.dart', 'w') as f:
    f.write(text)
