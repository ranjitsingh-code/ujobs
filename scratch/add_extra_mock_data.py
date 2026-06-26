import re

with open('lib/features/employer/jobs/employer_job_provider.dart', 'r') as f:
    content = f.read()

# Replace all simple Company() blocks
# pattern: company: Company(id: X, name: 'Y', location: 'Z'),
# we'll add size and founded
pattern = re.compile(r"company:\s*Company\(\s*id:\s*(\d+),\s*name:\s*('[^']+'),\s*location:\s*('[^']+')\s*\),")

def repl(m):
    id_val = m.group(1)
    name = m.group(2)
    location = m.group(3)
    return f"""company: Company(
            id: {id_val},
            name: {name},
            location: {location},
            industry: 'Technology',
            size: '50-200 employees',
            isVerified: true,
            founded: '2015',
          ),"""

new_content = pattern.sub(repl, content)

# There are also companies that span multiple lines but don't have size/founded
# e.g.:
#          company: Company(
#            id: 2,
#            name: 'Global Innovations',
#            location: 'New York, NY',
#          ),

pattern2 = re.compile(r"company:\s*Company\(\s*id:\s*(\d+),\s*name:\s*('[^']+'),\s*location:\s*('[^']+')\s*,\s*\),")

def repl2(m):
    id_val = m.group(1)
    name = m.group(2)
    location = m.group(3)
    return f"""company: Company(
            id: {id_val},
            name: {name},
            location: {location},
            industry: 'Technology',
            size: '50-200 employees',
            isVerified: true,
            founded: '2015',
          ),"""

new_content = pattern2.sub(repl2, new_content)

with open('lib/features/employer/jobs/employer_job_provider.dart', 'w') as f:
    f.write(new_content)
