import re

with open("lib/features/employer/company/company_profile_screen.dart", "r") as f:
    content = f.read()

content = content.replace("firstWhere((c) => c.name == _selectedCountry)", "firstWhereOrNull((c) => c.name == _selectedCountry)")

with open("lib/features/employer/company/company_profile_screen.dart", "w") as f:
    f.write(content)

