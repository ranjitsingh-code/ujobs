import re

with open('lib/features/employer/jobs/post_job_screen.dart', 'r') as f:
    text = f.read()

text = text.replace("category: job.category ?? '',", "category: job.categoryId ?? job.category ?? '',")

with open('lib/features/employer/jobs/post_job_screen.dart', 'w') as f:
    f.write(text)

