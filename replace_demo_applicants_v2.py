import re

with open('lib/features/employer/applicants/employer_applicant_provider.dart', 'r') as f:
    content = f.read()

applicants_data = """[
  Applicant(
    id: 'a1',
    name: 'Alice Johnson',
    initials: 'AJ',
    role: 'Software Engineer',
    targetJobTitle: 'Software Engineer',
    status: 'hired',
    appliedAt: DateTime.now().subtract(const Duration(days: 2)),
    email: 'alice@example.com',
    phone: '+1 (555) 123-4567',
  ),
  Applicant(
    id: 'a2',
    name: 'Bob Smith',
    initials: 'BS',
    role: 'Software Engineer',
    targetJobTitle: 'Software Engineer',
    status: 'shortlisted',
    appliedAt: DateTime.now().subtract(const Duration(days: 3)),
    email: 'bob@example.com',
    phone: '+1 (555) 987-6543',
  ),
  Applicant(
    id: 'a3',
    name: 'Charlie Brown',
    initials: 'CB',
    role: 'Website Developer',
    targetJobTitle: 'Website Developer',
    status: 'interviewing',
    appliedAt: DateTime.now().subtract(const Duration(days: 1)),
    email: 'charlie@example.com',
    phone: '+1 (555) 456-7890',
  ),
  Applicant(
    id: 'a4',
    name: 'Diana Prince',
    initials: 'DP',
    role: 'Mobile Application Developer',
    targetJobTitle: 'Mobile Application Developer',
    status: 'applied',
    appliedAt: DateTime.now().subtract(const Duration(hours: 5)),
    email: 'diana@example.com',
    phone: '+1 (555) 321-0987',
  ),
  Applicant(
    id: 'a5',
    name: 'Evan Wright',
    initials: 'EW',
    role: 'Digital Marketer',
    targetJobTitle: 'Digital Marketer',
    status: 'rejected',
    appliedAt: DateTime.now().subtract(const Duration(days: 4)),
    email: 'evan@example.com',
    phone: '+1 (555) 654-3210',
  ),
]"""

new_content = re.sub(r'final _demoApplicants = \[.*?\];', 'final _demoApplicants = ' + applicants_data + ';', content, flags=re.DOTALL)

with open('lib/features/employer/applicants/employer_applicant_provider.dart', 'w') as f:
    f.write(new_content)

