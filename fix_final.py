import re

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    text = f.read()

text = text.replace(
    "import '../../../core/widgets/ujob_employer_job_card.dart';",
    "import '../../../core/widgets/ujob_alert_dialog.dart';\nimport '../../../core/widgets/ujob_employer_job_card.dart';"
)

text = text.replace("static const _applicantCounts = [12, 5, 0, 8, 3];", "")

text = text.replace("const _EmptyJobs({super.key, required this.isProfileComplete, required this.onPostJob});", "const _EmptyJobs({required this.isProfileComplete, required this.onPostJob});")

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(text)
