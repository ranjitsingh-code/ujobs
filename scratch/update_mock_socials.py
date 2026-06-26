import re

with open('lib/features/employer/jobs/employer_job_provider.dart', 'r') as f:
    content = f.read()

orig = """            isVerified: true,
            founded: '2026',"""
new = """            isVerified: true,
            founded: '2026',
            linkedinUrl: 'https://linkedin.com/company/softmaya',
            facebookUrl: 'https://facebook.com/softmaya',"""

content = content.replace(orig, new)

with open('lib/features/employer/jobs/employer_job_provider.dart', 'w') as f:
    f.write(content)

