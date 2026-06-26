with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'r') as f:
    lines = f.readlines()

out = []
for i, line in enumerate(lines):
    # Remove exactly line 629
    if i == 628 and line.strip() == "],":
        continue
    out.append(line)

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'w') as f:
    f.writelines(out)
