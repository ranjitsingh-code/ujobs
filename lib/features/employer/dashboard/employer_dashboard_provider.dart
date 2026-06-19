import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/job.dart';
import '../jobs/employer_job_provider.dart';

class EmployerDashboardData {
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
}

final employerDashboardProvider = Provider.autoDispose<EmployerDashboardData>((
  ref,
) {
  final jobs = ref.watch(demoEmployerJobsProvider);
  return EmployerDashboardData(
    companyName: 'Nexovia Technologies',
    totalJobs: jobs.length,
    activeJobs: jobs.where((job) => job.status == JobStatus.active).length,
    totalApplicants: 124,
    shortlisted: 23,
    recentJobs: jobs.take(3).toList(),
  );
});
