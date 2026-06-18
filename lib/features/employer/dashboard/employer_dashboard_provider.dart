import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/job.dart';

class EmployerDashboardData {
  final String companyName;
  final String? companyLogo;
  final int totalJobs;
  final int activeJobs;
  final int totalApplicants; // Note: Since no global applicants endpoint, we might have to default to 0 or derive from jobs if included
  final List<Job> recentJobs;

  EmployerDashboardData({
    required this.companyName,
    this.companyLogo,
    required this.totalJobs,
    required this.activeJobs,
    required this.totalApplicants,
    required this.recentJobs,
  });
}

final employerDashboardProvider = FutureProvider.autoDispose<EmployerDashboardData>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;

  final results = await Future.wait([
    dio.get(Ep.employerMe),
    dio.get('${Ep.employerJobs}?limit=100'), // Fetch enough to calculate stats
  ]);

  final meData = results[0].data['data'] as Map<String, dynamic>;
  final jobsData = results[1].data['data'] as List? ?? [];

  final List<Job> allJobs = jobsData.map((j) => Job.fromJson(j as Map<String, dynamic>)).toList();
  
  // Calculate stats locally since there's no stats endpoint
  final activeJobsCount = allJobs.where((j) => j.status == JobStatus.active).length;
  
  // Sort by date to get recent jobs (assuming API doesn't do it or just taking first 3)
  final recentJobs = allJobs.take(3).toList();

  return EmployerDashboardData(
    companyName: meData['company']?['name'] as String? ?? 'Your Company',
    companyLogo: meData['company']?['logo'] as String?,
    totalJobs: allJobs.length,
    activeJobs: activeJobsCount,
    totalApplicants: 0, // TODO: derive from jobs if API includes applicant_count
    recentJobs: recentJobs,
  );
});
