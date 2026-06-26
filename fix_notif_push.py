import re
with open('lib/features/shared/notifications/notifications_screen.dart', 'r') as f:
    text = f.read()

text = text.replace("Navigator.push(context, MaterialPageRoute(builder: (_) => ApplicantDetailScreen(applicantId: appId)));", "context.push('/employer/applicants/$appId');")

with open('lib/features/shared/notifications/notifications_screen.dart', 'w') as f:
    f.write(text)
