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
    appliedAt: DateTime.now().subtract(const Duration(days: 20)),
    email: 'alice@example.com',
    phone: '+1 (555) 123-4567',
    hasMessaged: true,
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
    hasMessaged: true,
  ),
  Applicant(
    id: 'a3',
    name: 'Charlie Brown',
    initials: 'CB',
    role: 'Website Developer',
    targetJobTitle: 'Website Developer',
    status: 'interviewing',
    appliedAt: DateTime.now().subtract(const Duration(days: 10)),
    email: 'charlie@example.com',
    phone: '+1 (555) 456-7890',
    hasMessaged: true,
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
    hasMessaged: false,
  ),
  Applicant(
    id: 'a5',
    name: 'Evan Wright',
    initials: 'EW',
    role: 'SEO Expert',
    targetJobTitle: 'SEO Expert',
    status: 'offered',
    appliedAt: DateTime.now().subtract(const Duration(days: 14)),
    email: 'evan@example.com',
    phone: '+1 (555) 654-3210',
    hasMessaged: true,
  ),
  Applicant(
    id: 'a6',
    name: 'Fiona Gallagher',
    initials: 'FG',
    role: 'Data Analyst',
    targetJobTitle: 'Data Analyst',
    status: 'rejected',
    appliedAt: DateTime.now().subtract(const Duration(days: 30)),
    email: 'fiona@example.com',
    phone: '+1 (555) 111-2222',
    hasMessaged: false,
  ),
  Applicant(
    id: 'a7',
    name: 'George Mason',
    initials: 'GM',
    role: 'Cybersecurity Expert',
    targetJobTitle: 'Cybersecurity Expert',
    status: 'shortlisted',
    appliedAt: DateTime.now().subtract(const Duration(days: 1)),
    email: 'george@example.com',
    phone: '+1 (555) 333-4444',
    hasMessaged: false,
  ),
  Applicant(
    id: 'a8',
    name: 'Hannah Abbott',
    initials: 'HA',
    role: 'Digital Marketer',
    targetJobTitle: 'Digital Marketer',
    status: 'applied',
    appliedAt: DateTime.now().subtract(const Duration(hours: 2)),
    email: 'hannah@example.com',
    phone: '+1 (555) 555-6666',
    hasMessaged: false,
  ),
];"""

start_idx = content.find('final _demoApplicants = [')
if start_idx != -1:
    new_content = content[:start_idx] + 'final _demoApplicants = ' + applicants_data
    with open('lib/features/employer/applicants/employer_applicant_provider.dart', 'w') as f:
        f.write(new_content)
    print("Applicants replaced successfully")
else:
    print("Could not find applicants block")

