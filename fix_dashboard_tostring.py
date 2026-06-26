import re

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'r') as f:
    code = f.read()

code = code.replace("updateJobStatus(job.id.toString(), JobStatus.closed.name)", "updateJobStatus(job.id, JobStatus.closed.name)")

with open('lib/features/employer/dashboard/employer_dashboard_screen.dart', 'w') as f:
    f.write(code)

