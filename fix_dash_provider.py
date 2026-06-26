import re

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'r') as f:
    text = f.read()

# Update EmployerDashboardData
text = re.sub(
    r"final bool isVerified;",
    "final bool isVerified;\n  final String verificationStatus;\n  final int profileCompleted;",
    text
)

text = re.sub(
    r"required this.isVerified,",
    "required this.isVerified,\n    required this.verificationStatus,\n    required this.profileCompleted,",
    text
)

text = re.sub(
    r"isVerified: profileData\['verified'\] == true,",
    "isVerified: profileData['verification_status'] == 'verified',\n    verificationStatus: profileData['verification_status']?.toString() ?? 'unverified',\n    profileCompleted: (profileData['profile_completed'] as num?)?.toInt() ?? 0,",
    text
)

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'w') as f:
    f.write(text)

