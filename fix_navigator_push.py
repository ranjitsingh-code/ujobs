import re

files = [
    'lib/features/employer/applicants/applicants_screen.dart',
    'lib/features/employer/applicants/job_applicants_screen.dart',
    'lib/features/shared/notifications/notifications_screen.dart',
    'lib/features/shared/chat/chat_screen.dart',
]

for fpath in files:
    with open(fpath, 'r') as f:
        text = f.read()

    # Replacements
    text = re.sub(
        r'Navigator\.push\(\s*context,\s*MaterialPageRoute\(\s*builder:\s*\(\w+\)\s*=>\s*ApplicantDetailScreen\(\s*applicantId:\s*([^,]+?)\s*\)\s*\)\s*\)',
        r"context.push('/employer/applicants/${1}')",
        text
    )
    
    text = re.sub(
        r'Navigator\.push\(\s*context,\s*MaterialPageRoute\(\s*builder:\s*\(\w+\)\s*=>\s*ApplicantDetailScreen\(\s*applicant:\s*([^,]+?)\s*\)\s*\)\s*\)',
        r"context.push('/employer/applicants/${1.id}')",
        text
    )

    with open(fpath, 'w') as f:
        f.write(text)

