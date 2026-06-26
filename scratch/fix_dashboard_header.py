import os

file_path = 'lib/features/employer/dashboard/employer_dashboard_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

bad_fields = """  final VoidCallback onShortlistedTap;
  final bool isProfileComplete;
  final VoidCallback onPostJob;

  const _DashboardHeader({
    required this.greeting,
    required this.name,
    required this.dashboard,
    required this.onNotificationsTap,
    required this.onJobsTap,
    required this.onActiveJobsTap,
    required this.onApplicantsTap,
    required this.onShortlistedTap,
    required this.isProfileComplete,
    required this.onPostJob,
  });"""

good_fields = """  final VoidCallback onShortlistedTap;

  const _DashboardHeader({
    required this.greeting,
    required this.name,
    required this.dashboard,
    required this.onNotificationsTap,
    required this.onJobsTap,
    required this.onActiveJobsTap,
    required this.onApplicantsTap,
    required this.onShortlistedTap,
  });"""

content = content.replace(bad_fields, good_fields)

with open(file_path, 'w') as f:
    f.write(content)
