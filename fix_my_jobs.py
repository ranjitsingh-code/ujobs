import re

with open('lib/features/employer/jobs/my_jobs_screen.dart', 'r') as f:
    text = f.read()

text = text.replace("if (!isVerified) {", "if (false) {")

with open('lib/features/employer/jobs/my_jobs_screen.dart', 'w') as f:
    f.write(text)

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

text = text.replace("if (!dashboard.isVerified) {", "if (false) {")

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)

