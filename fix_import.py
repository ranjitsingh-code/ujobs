import re

with open('lib/features/employer/company/company_profile_screen.dart', 'r') as f:
    text = f.read()

if "import 'package:go_router/go_router.dart';" not in text:
    text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:go_router/go_router.dart';")

with open('lib/features/employer/company/company_profile_screen.dart', 'w') as f:
    f.write(text)
