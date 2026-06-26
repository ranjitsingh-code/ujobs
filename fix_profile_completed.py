import re

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'r') as f:
    text = f.read()

target = "profileCompleted: (profileData['profile_completed'] as num?)?.toInt() ?? 0,"
replacement = "profileCompleted: (companyData['profile_completed'] as num?)?.toInt() ?? (profileData['profile_completed'] as num?)?.toInt() ?? 0,"

text = text.replace(target, replacement)

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'w') as f:
    f.write(text)
