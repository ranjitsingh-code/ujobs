import re

with open('lib/features/employer/jobs/my_jobs_screen.dart', 'r') as f:
    lines = f.readlines()

out = []
skip_next_onclose = False

for i in range(len(lines)):
    line = lines[i]
    if "onClose: (job.status != JobStatus.closed && job.status != JobStatus.rejected) ? () => _confirmClose(context, ref, job) : null," in line:
        if lines[i+1].strip() == "onClose: (job.status != JobStatus.closed && job.status != JobStatus.rejected) ? () => _confirmClose(context, ref, job) : null,":
            continue # skip the duplicated one
    if "deleteJob(int.parse(job.id))" in line:
        line = line.replace("int.parse(job.id)", "job.id")
    out.append(line)

with open('lib/features/employer/jobs/my_jobs_screen.dart', 'w') as f:
    f.writelines(out)

