with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'r') as f:
    text = f.read()

# Replace BOTH occurrences
text = text.replace('UJobAvatar(initials: applicant.initials, size: 56.r)', 'UJobAvatar(initials: applicant.initials, imageUrl: applicant.avatarUrl, size: 56.r)')
text = text.replace('UJobAvatar(initials: applicant.initials, size: 80.r)', 'UJobAvatar(initials: applicant.initials, imageUrl: applicant.avatarUrl, size: 80.r)')

with open('lib/features/employer/applicants/applicant_detail_screen.dart', 'w') as f:
    f.write(text)
