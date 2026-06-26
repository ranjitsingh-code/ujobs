import re

with open("lib/features/employer/jobs/employer_job_detail_screen.dart", "r") as f:
    emp = f.read()
emp = emp.replace("'${idx + 1}. ${q['text']}',", "'${idx + 1}. ${q['question_text'] ?? q['text'] ?? q['question'] ?? 'Unknown'}',")
with open("lib/features/employer/jobs/employer_job_detail_screen.dart", "w") as f:
    f.write(emp)

with open("lib/features/seeker/jobs/seeker_job_detail_screen.dart", "r") as f:
    seek = f.read()
seek = seek.replace("q['question'] ?? '',", "q['question_text'] ?? q['text'] ?? q['question'] ?? '',")
with open("lib/features/seeker/jobs/seeker_job_detail_screen.dart", "w") as f:
    f.write(seek)

