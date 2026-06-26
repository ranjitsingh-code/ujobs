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

    # Pattern for applicantId: applicant.id or applicantId: appId
    text = re.sub(
        r'Navigator\.push\(\s*context,\s*MaterialPageRoute\(\s*builder:\s*\([^\)]*\)\s*=>\s*ApplicantDetailScreen\(applicantId:\s*([^,]+?)\),\s*\),\s*\);?',
        r"context.push('/employer/applicants/${\1}');",
        text,
        flags=re.MULTILINE
    )
    
    # Pattern for applicant: applicant
    text = re.sub(
        r'Navigator\.push\(\s*context,\s*MaterialPageRoute\(\s*builder:\s*\([^\)]*\)\s*=>\s*ApplicantDetailScreen\(applicant:\s*([^,]+?)\),\s*\),\s*\);?',
        r"context.push('/employer/applicants/${\1.id}');",
        text,
        flags=re.MULTILINE
    )

    with open(fpath, 'w') as f:
        f.write(text)

