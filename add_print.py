import re

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'r') as f:
    text = f.read()

target = "    profileCompleted: int.tryParse(dashData['profile_completed']?.toString() ?? '') ?? int.tryParse(companyData['profile_completed']?.toString() ?? '') ?? int.tryParse(profileData['profile_completed']?.toString() ?? '') ?? 0,\n  );"

replacement = """    profileCompleted: int.tryParse(dashData['profile_completed']?.toString() ?? '') ?? int.tryParse(companyData['profile_completed']?.toString() ?? '') ?? int.tryParse(profileData['profile_completed']?.toString() ?? '') ?? 0,
  );
  
  print('--- DASHBOARD PROVIDER PARSED PROFILE COMPLETED: ${dash.profileCompleted} ---');
  return dash;"""

text = text.replace("return EmployerDashboardData(", "final dash = EmployerDashboardData(")
text = text.replace(target, replacement)

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'w') as f:
    f.write(text)

