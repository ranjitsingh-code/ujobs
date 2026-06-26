import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

# Add collection import
if "import 'package:collection/collection.dart';" not in content:
    content = "import 'package:collection/collection.dart';\n" + content

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

