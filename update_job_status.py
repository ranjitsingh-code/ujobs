import re

with open('lib/features/employer/jobs/employer_job_provider.dart', 'r') as f:
    content = f.read()

# Replace status for job 2 (Website Developer)
content = re.sub(r"(title: 'Website Developer',\s+description:.*?salaryMax: '\$130,000',\s+)status: JobStatus\.active,", r"\g<1>status: JobStatus.draft,", content, flags=re.DOTALL)

# Replace status for job 3 (Mobile Application Developer)
content = re.sub(r"(title: 'Mobile Application Developer',\s+description:.*?salaryMax: '£85,000',\s+)status: JobStatus\.active,", r"\g<1>status: JobStatus.paused,", content, flags=re.DOTALL)

# Replace status for job 4 (SEO Expert)
content = re.sub(r"(title: 'SEO Expert',\s+description:.*?salaryMax: '\$100,000',\s+)status: JobStatus\.active,", r"\g<1>status: JobStatus.pending,", content, flags=re.DOTALL)

# Replace status for job 5 (Data Analyst)
content = re.sub(r"(title: 'Data Analyst',\s+description:.*?salaryMax: '€90,000',\s+)status: JobStatus\.active,", r"\g<1>status: JobStatus.closed,", content, flags=re.DOTALL)

with open('lib/features/employer/jobs/employer_job_provider.dart', 'w') as f:
    f.write(content)

print("Updated job statuses")
