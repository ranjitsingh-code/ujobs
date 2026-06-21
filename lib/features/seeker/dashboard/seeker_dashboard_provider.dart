import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/job.dart';

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
    final jobsData = [];

    return SeekerDashboardData(
      profileCompletion: meData['profile_completed'] as int? ?? 0,
      applicationsCount: appsData.length,
      recommendedJobs: jobsData
          .map((j) => Job.fromJson(j as Map<String, dynamic>))
          .toList(),
    );
  },
);
