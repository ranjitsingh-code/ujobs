import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/job.dart';


class SeekerDashboardData {
  final int applicationsCount;
  final int savedCount;
  final int matchesCount;
  final List<Job> recommendedJobs;
  final bool isVerified;
  final String verificationStatus;
  final String accountStatus;

  SeekerDashboardData({
    required this.applicationsCount,
    required this.savedCount,
    required this.matchesCount,
    required this.recommendedJobs,
    required this.isVerified,
    required this.verificationStatus,
    required this.accountStatus,
  });

  bool get canApply => isVerified;
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

    final verificationStatus = profileData['verification_status']?.toString() ?? 'unverified';
    final accountStatus = profileData['account_status']?.toString() ?? 'pending';

    return SeekerDashboardData(
      applicationsCount: statsData['stats']['applied_count'] ?? 0,
      savedCount: statsData['stats']['saved_count'] ?? 0,
      matchesCount: statsData['stats']['matches_count'] ?? 0,
      recommendedJobs: jobsData,
      isVerified: verificationStatus == 'verified' && accountStatus == 'verified',
      verificationStatus: verificationStatus,
      accountStatus: accountStatus,
    );
  },
);
