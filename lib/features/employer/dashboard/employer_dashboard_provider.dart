import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/job.dart';
import '../../../core/models/company_profile.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';
import '../jobs/employer_job_provider.dart';

final companyProfileProvider = StateProvider<CompanyProfile>((ref) {
  return const CompanyProfile(
    id: 'demo-company',
    name: 'Acme Ltd',
    industry: '',
    size: '',
    workType: '',
    website: '',
    description: '',
    contactPersonName: '',
    contactEmail: '',
    contactPhone: '',
    showContactInfo: false,
    address: '',
    city: '',
    postcode: '',
    country: '',
    linkedInUrl: '',
    facebookUrl: '',
    activeJobs: 2,
    applicants: 124,
  );
});

final companyProfileCompletenessProvider = Provider<double>((ref) {
  final profile = ref.watch(companyProfileProvider);
  return profile.profileStatus / 100.0;
});

final isCompanyProfileCompleteProvider = Provider<bool>((ref) {
  final profile = ref.watch(companyProfileProvider);
  return profile.name.isNotEmpty &&
      (profile.contactPersonName != null &&
          profile.contactPersonName!.isNotEmpty) &&
      (profile.address != null && profile.address!.isNotEmpty) &&
      (profile.city != null && profile.city!.isNotEmpty) &&
      (profile.country != null && profile.country!.isNotEmpty);
});

class EmployerDashboardData {
  final String companyName;
  final int totalJobs;
  final int activeJobs;
  final int totalApplicants;
  final int shortlisted;
  final List<Job> recentJobs;
  final bool isVerified;
  final String verificationStatus;
  final int profileCompleted;

  EmployerDashboardData({
    required this.companyName,
    required this.totalJobs,
    required this.activeJobs,
    required this.totalApplicants,
    required this.shortlisted,
    required this.recentJobs,
    required this.isVerified,
    required this.verificationStatus,
    required this.profileCompleted,
  });
}

final employerDashboardProvider = FutureProvider<EmployerDashboardData>((ref) async {
  final client = ref.watch(dioClientProvider);
  
  // Fetch sequentially to avoid Future.wait generic inference issues
  final profileRes = await client.dio.get(Ep.employerMe);
  final dashRes = await client.dio.get(Ep.empDashboard);
  
  final profileData = profileRes.data['data'] ?? {};
  final companiesList = profileData['companies'] as List? ?? [];
  final companyData = companiesList.isNotEmpty ? (companiesList.first as Map<String, dynamic>) : {};
  
  final dashData = dashRes.data['data'] ?? {};
  final recentJobsList = (dashData['recent_jobs'] as List?) ?? [];
  
  final dash = EmployerDashboardData(
    companyName: companyData['name'] ?? 'Your Company',
    totalJobs: dashData['total_jobs'] ?? 0,
    activeJobs: dashData['active_jobs'] ?? 0,
    totalApplicants: dashData['total_applicants'] ?? 0,
    shortlisted: dashData['shortlisted_count'] ?? 0,
    recentJobs: recentJobsList.map((j) => Job.fromJson(j)).toList(),
    isVerified: companyData['verification_status'] == 'verified' || profileData['verification_status'] == 'verified',
    verificationStatus: companyData['verification_status']?.toString() ?? profileData['verification_status']?.toString() ?? 'unverified',
    profileCompleted: [
      int.tryParse(profileData['profile_completed']?.toString() ?? ''),
      int.tryParse(companyData['profile_completed']?.toString() ?? ''),
      int.tryParse(dashData['profile_completed']?.toString() ?? ''),
    ].where((e) => e != null).fold(0, (max, e) => e! > max ? e : max),
  );
  
  print('--- DASHBOARD PROVIDER PARSED PROFILE COMPLETED: ${dash.profileCompleted} ---');
  return dash;
});
