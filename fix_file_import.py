import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

# Add import 'dart:io';
if "import 'dart:io';" not in content:
    content = "import 'dart:io';\n" + content

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

