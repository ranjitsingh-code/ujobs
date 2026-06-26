import re

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

target = "if (!dashboard.isVerified) ...["
replacement = "if (dashboard.verificationStatus == 'unverified') ...["

text = text.replace(target, replacement)

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)

