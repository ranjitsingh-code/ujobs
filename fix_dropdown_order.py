import re

with open('lib/features/employer/jobs/post_job_steps/step1_job_details.dart', 'r') as f:
    text = f.read()

target = """            options: [
              ...categories.map((c) => (c.id, c.name)),
              ('Other', 'Other'),
            ],"""

replacement = """            options: [
              ...categories.map((c) => (c.name, c.id)),
              ('Other', 'Other'),
            ],"""

if target in text:
    text = text.replace(target, replacement)
    with open('lib/features/employer/jobs/post_job_steps/step1_job_details.dart', 'w') as f:
        f.write(text)
    print("Fixed!")
else:
    print("Not found!")

