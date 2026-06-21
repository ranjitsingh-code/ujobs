import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

old_padding = "padding: EdgeInsets.all(20.r),"
new_padding = "padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, _isExpanded ? 12.r : 20.r),"

text = text.replace(old_padding, new_padding)

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
