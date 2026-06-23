import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/job.dart';
import '../../employer/jobs/employer_job_provider.dart';

class SeekerDashboardData {
  final int profileCompletion;
  final int applicationsCount;
  final List<Job> recommendedJobs;

  SeekerDashboardData({
    required this.profileCompletion,
    required this.applicationsCount,
    required this.recommendedJobs,
  });
}

final seekerDashboardProvider = FutureProvider.autoDispose<SeekerDashboardData>(
  (ref) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get mock jobs
    final allJobs = ref.read(demoEmployerJobsProvider);

    return SeekerDashboardData(
      profileCompletion: 75,
      applicationsCount: 3,
      recommendedJobs: allJobs.take(5).toList(),
    );
  },
);
