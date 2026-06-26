import re

with open("lib/features/employer/jobs/employer_job_detail_screen.dart", "r") as f:
    content = f.read()

# Fix screening question key
old_q = "'${idx + 1}. ${q['question_text'] ?? q['text'] ?? 'Unknown question'}',"
new_q = "'${idx + 1}. ${q['text']}',"
content = content.replace(old_q, new_q)

with open("lib/features/employer/jobs/employer_job_detail_screen.dart", "w") as f:
    f.write(content)

