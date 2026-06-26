with open('lib/features/employer/jobs/post_job_screen.dart', 'r') as f:
    text = f.read()

import_statement = "import 'employer_job_provider.dart';\n"
if import_statement not in text:
    text = text.replace("import '../dashboard/employer_dashboard_provider.dart';", "import '../dashboard/employer_dashboard_provider.dart';\n" + import_statement)

text = text.replace("ref.invalidate(employerJobsProvider);", "ref.invalidate(employerJobsProvider);\n      if (widget.job != null) ref.invalidate(employerJobDetailProvider(widget.job!.id));")

with open('lib/features/employer/jobs/post_job_screen.dart', 'w') as f:
    f.write(text)

