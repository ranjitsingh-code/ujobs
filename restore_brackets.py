with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'r') as f:
    lines = f.readlines()

out = []
for line in lines:
    if "        )," in line and "      )," in lines[lines.index(line) + 1] and "    );" in lines[lines.index(line) + 2]:
        out.append("            ],\n")
        out.append(line)
    else:
        out.append(line)

with open('lib/features/employer/jobs/employer_job_detail_screen.dart', 'w') as f:
    f.writelines(out)
