import re

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'r') as f:
    text = f.read()

text = text.replace("if (applicant.resumeUrl != null) SizedBox(height: 24.h);", "")
text = text.replace("if (applicant.resumeUrl != null) SizedBox(height: 24.h),\n        // Replaced by new logic above\n", "")

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'w') as f:
    f.write(text)
