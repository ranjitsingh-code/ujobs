import re

with open('lib/features/employer/jobs/employer_job_provider.dart', 'r') as f:
    content = f.read()

orig = """            industry: 'Technology',
            size: '11-50 employees',
            location: 'London, GB',"""

new = """            industry: 'Technology',
            size: '11-50 employees',
            location: 'London, GB',
            isVerified: true,
            founded: '2026',"""

content = content.replace(orig, new)

with open('lib/features/employer/jobs/employer_job_provider.dart', 'w') as f:
    f.write(content)

