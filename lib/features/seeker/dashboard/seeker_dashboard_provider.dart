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
    await Future.delayed(const Duration(milliseconds: 500));
    final meData = {'profile_completed': 80};
    final appsData = [1, 2, 3];
    final allJobs = ref.watch(demoEmployerJobsProvider);
    final jobsData = allJobs.take(3).toList();

    return SeekerDashboardData(
      profileCompletion: meData['profile_completed'] as int? ?? 0,
      applicationsCount: appsData.length,
      recommendedJobs: jobsData,
    );
  },
);
