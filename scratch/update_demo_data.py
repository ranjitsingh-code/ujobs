import os
import re

file_path = 'lib/features/employer/jobs/employer_job_provider.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Make applicant count high
content = re.sub(r'applicantCount:\s*\d+', 'applicantCount: 524', content)

# Change hardcoded dates to recent real dates
content = re.sub(
    r"DateTime\.parse\('2026-\d{2}-\d{2}T.*?'\)", 
    "DateTime.now().subtract(const Duration(days: 2))", 
    content
)

with open(file_path, 'w') as f:
    f.write(content)
print("Updated demo data!")
