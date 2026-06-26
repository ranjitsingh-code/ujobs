import re

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

# Replace `final isProfileComplete = ref.watch(isCompanyProfileCompleteProvider);`
text = re.sub(
    r"final isProfileComplete = ref\.watch\(isCompanyProfileCompleteProvider\);\n",
    "",
    text
)

text = re.sub(
    r"required this\.isProfileComplete",
    "required this.isVerified",
    text
)

text = re.sub(
    r"opacity: isProfileComplete",
    "opacity: isVerified",
    text
)

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)

