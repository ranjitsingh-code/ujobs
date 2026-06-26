import re

with open("lib/features/employer/jobs/employer_job_detail_screen.dart", "r") as f:
    content = f.read()

# Fix salary display
old_salary = """                  if (job.salaryMin != null)
                    _buildSummaryRow(
                      'Salary',
                      job.salaryMax != null
                          ? '${job.salaryMin} - ${job.salaryMax}'
                          : job.salaryMin!,
                    ),"""

new_salary = """                  if (job.salaryMin != null)
                    _buildSummaryRow(
                      'Salary',
                      (job.salaryMax != null
                          ? '${job.salaryMin} - ${job.salaryMax}'
                          : job.salaryMin!) +
                          (job.salaryCurrency != null ? ' ${job.salaryCurrency}' : '') +
                          (job.salaryPeriod != null ? ' / ${job.salaryPeriod}' : ''),
                    ),"""

content = content.replace(old_salary, new_salary)

# Fix screening question key
old_q = "'${idx + 1}. ${q['text']}',"
new_q = "'${idx + 1}. ${q['question_text'] ?? q['text'] ?? 'Unknown question'}',"
content = content.replace(old_q, new_q)

with open("lib/features/employer/jobs/employer_job_detail_screen.dart", "w") as f:
    f.write(content)

