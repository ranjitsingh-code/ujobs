import re

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'r') as f:
    text = f.read()

target = """class EmployerDashboardData {
  final String companyName;
  final int totalJobs;
  final int activeJobs;
  final int totalApplicants;
  final int shortlisted;
  final List<Job> recentJobs;

  EmployerDashboardData({
    required this.companyName,
    required this.totalJobs,
    required this.activeJobs,
    required this.totalApplicants,
    required this.shortlisted,
    required this.recentJobs,
  });
}"""

replacement = """class EmployerDashboardData {
  final String companyName;
  final int totalJobs;
  final int activeJobs;
  final int totalApplicants;
  final int shortlisted;
  final List<Job> recentJobs;
  final bool isVerified;

  EmployerDashboardData({
    required this.companyName,
    required this.totalJobs,
    required this.activeJobs,
    required this.totalApplicants,
    required this.shortlisted,
    required this.recentJobs,
    required this.isVerified,
  });
}"""

text = text.replace(target, replacement)

target2 = """  return EmployerDashboardData(
    companyName: companyData['name'] ?? 'Your Company',
    totalJobs: dashData['total_jobs'] ?? 0,
    activeJobs: dashData['active_jobs'] ?? 0,
    totalApplicants: dashData['total_applicants'] ?? 0,
    shortlisted: dashData['shortlisted_count'] ?? 0,
    recentJobs: recentJobsList.map((j) => Job.fromJson(j)).toList(),
  );
});"""

replacement2 = """  return EmployerDashboardData(
    companyName: companyData['name'] ?? 'Your Company',
    totalJobs: dashData['total_jobs'] ?? 0,
    activeJobs: dashData['active_jobs'] ?? 0,
    totalApplicants: dashData['total_applicants'] ?? 0,
    shortlisted: dashData['shortlisted_count'] ?? 0,
    recentJobs: recentJobsList.map((j) => Job.fromJson(j)).toList(),
    isVerified: profileData['verified'] == true,
  );
});"""

text = text.replace(target2, replacement2)

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'w') as f:
    f.write(text)
