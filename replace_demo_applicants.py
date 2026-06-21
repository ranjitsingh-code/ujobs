import re

with open('lib/features/employer/applicants/employer_applicant_provider.dart', 'r') as f:
    content = f.read()

applicants_data = """[
  Applicant(
    id: 'a1',
    jobId: 1, // Software Engineer
    name: 'Alice Johnson',
    avatar: 'https://i.pravatar.cc/150?u=alice',
    status: ApplicantStatus.hired,
    appliedAt: DateTime.now().subtract(const Duration(days: 2)),
    matchScore: 95,
  ),
  Applicant(
    id: 'a2',
    jobId: 1, // Software Engineer
    name: 'Bob Smith',
    avatar: 'https://i.pravatar.cc/150?u=bob',
    status: ApplicantStatus.shortlisted,
    appliedAt: DateTime.now().subtract(const Duration(days: 3)),
    matchScore: 88,
  ),
  Applicant(
    id: 'a3',
    jobId: 2, // Website Developer
    name: 'Charlie Brown',
    avatar: 'https://i.pravatar.cc/150?u=charlie',
    status: ApplicantStatus.interviewing,
    appliedAt: DateTime.now().subtract(const Duration(days: 1)),
    matchScore: 92,
  ),
  Applicant(
    id: 'a4',
    jobId: 3, // Mobile Application Developer
    name: 'Diana Prince',
    avatar: 'https://i.pravatar.cc/150?u=diana',
    status: ApplicantStatus.pending,
    appliedAt: DateTime.now().subtract(const Duration(hours: 5)),
    matchScore: 78,
  ),
  Applicant(
    id: 'a5',
    jobId: 7, // Digital Marketer
    name: 'Evan Wright',
    avatar: 'https://i.pravatar.cc/150?u=evan',
    status: ApplicantStatus.rejected,
    appliedAt: DateTime.now().subtract(const Duration(days: 4)),
    matchScore: 45,
  ),
]"""

new_content = re.sub(r'final _demoApplicants = \[.*?\];', 'final _demoApplicants = ' + applicants_data + ';', content, flags=re.DOTALL)

with open('lib/features/employer/applicants/employer_applicant_provider.dart', 'w') as f:
    f.write(new_content)

