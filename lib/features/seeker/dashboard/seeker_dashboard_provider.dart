import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/job.dart';


class SeekerDashboardData {
  final int profileCompletion;
  final int applicationsCount;
  final int savedCount;
  final int matchesCount;
  final List<Job> recommendedJobs;

  SeekerDashboardData({
    required this.profileCompletion,
    required this.applicationsCount,
    required this.savedCount,
    required this.matchesCount,
    required this.recommendedJobs,
  });
}

final seekerDashboardProvider = FutureProvider.autoDispose<SeekerDashboardData>(
  (ref) async {
    final dio = ref.watch(dioClientProvider).dio;

    // Fetch dashboard stats
    final statsRes = await dio.get(Ep.seekerDashboard);
    final statsData = statsRes.data['data'];
    
    // Fetch matching jobs
    final jobsRes = await dio.get(Ep.seekerMatching);
    final jobsData = (jobsRes.data['data'] as List).map((j) => Job.fromJson(j)).toList();

    return SeekerDashboardData(
      profileCompletion: statsData['profile_completed'] ?? statsData['profile_completion_percentage'] ?? 0,
      applicationsCount: statsData['stats']['applied_count'] ?? 0,
      savedCount: statsData['stats']['saved_count'] ?? 0,
      matchesCount: statsData['stats']['matches_count'] ?? 0,
      recommendedJobs: jobsData,
    );
  },
);
