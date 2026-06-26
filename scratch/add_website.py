import re

with open('lib/features/employer/jobs/employer_job_provider.dart', 'r') as f:
    content = f.read()

content = content.replace("founded: '2026',", "founded: '2026',\n            website: 'https://softmaya.com',")
content = content.replace("founded: '2015',", "founded: '2015',\n            website: 'https://example.com',")

with open('lib/features/employer/jobs/employer_job_provider.dart', 'w') as f:
    f.write(content)
