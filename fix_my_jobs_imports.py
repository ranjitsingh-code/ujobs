import re

with open("lib/features/employer/jobs/my_jobs_screen.dart", "r") as f:
    content = f.read()

if "import 'employer_job_provider.dart';" not in content:
    content = content.replace("import 'employer_job_provider.dart';", "") # just to be safe
    content = content.replace("import '../../../core/widgets/ujob_toast.dart';", "import '../../../core/widgets/ujob_toast.dart';\nimport 'employer_job_provider.dart';")

with open("lib/features/employer/jobs/my_jobs_screen.dart", "w") as f:
    f.write(content)
