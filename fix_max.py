import re

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'r') as f:
    text = f.read()

target = "    profileCompleted: int.tryParse(profileData['profile_completed']?.toString() ?? '') ?? int.tryParse(companyData['profile_completed']?.toString() ?? '') ?? int.tryParse(dashData['profile_completed']?.toString() ?? '') ?? 0,"
replacement = """    profileCompleted: [
      int.tryParse(profileData['profile_completed']?.toString() ?? ''),
      int.tryParse(companyData['profile_completed']?.toString() ?? ''),
      int.tryParse(dashData['profile_completed']?.toString() ?? ''),
    ].where((e) => e != null).fold(0, (max, e) => e! > max ? e : max),"""

text = text.replace(target, replacement)

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'w') as f:
    f.write(text)

