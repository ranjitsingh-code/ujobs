import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

# Add imports for Ep and dioClientProvider
if "dioClientProvider" not in content[:1000]:
    content = content.replace("import '../../../core/providers/auth_provider.dart';", "import '../../../core/providers/auth_provider.dart';\nimport '../../../core/api/api_endpoints.dart';")

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

