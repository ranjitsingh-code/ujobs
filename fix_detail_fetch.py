import re

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'r') as f:
    text = f.read()

target = "final jobAsync = jobData != null ? AsyncValue.data(jobData!) : ref.watch(employerJobDetailProvider(jobId));"
replacement = "final jobAsync = ref.watch(employerJobDetailProvider(jobId));"

text = text.replace(target, replacement)

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'w') as f:
    f.write(text)

