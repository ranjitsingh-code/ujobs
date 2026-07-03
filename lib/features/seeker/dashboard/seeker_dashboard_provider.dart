import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/job.dart';


class SeekerDashboardData {
  final int applicationsCount;
  final int matchesCount;
  final List<Job> recommendedJobs;
  final String status;

  SeekerDashboardData({
    required this.applicationsCount,
    required this.matchesCount,
    required this.recommendedJobs,
    required this.status,
  });
}

final seekerDashboardProvider = FutureProvider.autoDispose<SeekerDashboardData>(
  (ref) async {
    final dio = ref.watch(dioClientProvider).dio;

    final profileRes = await dio.get(Ep.seekerMe);
    final profileData = profileRes.data['data'] ?? {};

    final statsRes = await dio.get(Ep.seekerDashboard);
    final statsData = statsRes.data['data'];

    final jobsRes = await dio.get(Ep.seekerMatching);
    final jobsData = (jobsRes.data['data'] as List).map((j) => Job.fromJson(j)).toList();

    return SeekerDashboardData(
      applicationsCount: statsData['stats']['applied_count'] ?? 0,
      matchesCount: statsData['stats']['matches_count'] ?? 0,
      recommendedJobs: jobsData,
      status: profileData['status']?.toString() ?? 'pending',
    );
  },
);
