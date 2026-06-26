import re

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'r') as f:
    text = f.read()

target = "  final companyData = profileData['company'] ?? {};"
replacement = """  final companiesList = profileData['companies'] as List? ?? [];
  final companyData = companiesList.isNotEmpty ? (companiesList.first as Map<String, dynamic>) : {};"""
text = text.replace(target, replacement)

target2 = "    isVerified: profileData['verification_status'] == 'verified',"
replacement2 = "    isVerified: companyData['verification_status'] == 'verified' || profileData['verification_status'] == 'verified',"
text = text.replace(target2, replacement2)

target3 = "    verificationStatus: profileData['verification_status']?.toString() ?? 'unverified',"
replacement3 = "    verificationStatus: companyData['verification_status']?.toString() ?? profileData['verification_status']?.toString() ?? 'unverified',"
text = text.replace(target3, replacement3)

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'w') as f:
    f.write(text)

