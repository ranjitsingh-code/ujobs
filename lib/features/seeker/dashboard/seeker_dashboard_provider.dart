import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/application.dart';
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

final seekerDashboardProvider = FutureProvider.autoDispose<SeekerDashboardData>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;

  final results = await Future.wait([
    dio.get(Ep.seekerMe),
    dio.get(Ep.seekerApplications),
    dio.get('${Ep.seekerMatching}?limit=5'),
  ]);

  final meData = results[0].data['data'] as Map<String, dynamic>;
  final appsData = results[1].data['data'] as List? ?? [];
  final jobsData = results[2].data['data'] as List? ?? [];

  return SeekerDashboardData(
    profileCompletion: meData['profile_completed'] as int? ?? 0,
    applicationsCount: appsData.length,
    recommendedJobs: jobsData.map((j) => Job.fromJson(j as Map<String, dynamic>)).toList(),
  );
});
