with open("lib/core/models/job.dart", "r") as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if line.strip() == "this.salaryCurrency," or line.strip() == "this.salaryPeriod,":
        continue
    new_lines.append(line)

with open("lib/core/models/job.dart", "w") as f:
    f.writelines(new_lines)
