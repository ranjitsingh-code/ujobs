import re

# Fix my_jobs_screen.dart
with open('lib/features/employer/jobs/my_jobs_screen.dart', 'r') as f:
    text = f.read()

text = text.replace("if (false) {", "if (!isVerified) {")

with open('lib/features/employer/jobs/my_jobs_screen.dart', 'w') as f:
    f.write(text)


# Fix employer_dashboard_screen.dart
with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

text = text.replace("if (false) {", "if (!dashboard.isVerified) {")

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)

