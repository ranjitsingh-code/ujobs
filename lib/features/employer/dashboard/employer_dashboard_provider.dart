import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/job.dart';
import '../../../core/models/company_profile.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/providers/auth_provider.dart';

final companyProfileProvider = StateProvider<CompanyProfile>((ref) {
  return const CompanyProfile(
    id: '',
    name: '',
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
    activeJobs: 0,
    applicants: 0,
  );
});

final companyProfileCompletenessProvider = Provider<double>((ref) {
  final profile = ref.watch(companyProfileProvider);
  return profile.profileStatus / 100.0;
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
  final String userStatus;
  final int profileCompleted;
  final bool isCompanyProfileComplete;

  EmployerDashboardData({
    required this.companyName,
    required this.totalJobs,
    required this.activeJobs,
    required this.totalApplicants,
    required this.shortlisted,
    required this.recentJobs,
    required this.isVerified,
    required this.verificationStatus,
    required this.userStatus,
    required this.profileCompleted,
    required this.isCompanyProfileComplete,
  });

  bool get isAccountActive => userStatus.toLowerCase() == 'active';
  bool get canPostJob => isAccountActive && isVerified && isCompanyProfileComplete;
}

final employerDashboardProvider = FutureProvider.autoDispose<EmployerDashboardData>((ref) async {
  final client = ref.watch(dioClientProvider);
  
  // Fetch sequentially to avoid Future.wait generic inference issues
  final profileRes = await client.dio.get(Ep.employerMe);
  final dashRes = await client.dio.get(Ep.empDashboard);
  
  final profileData = profileRes.data['data'] ?? {};
  final companiesList = profileData['companies'] as List? ?? [];
  final companyData = companiesList.isNotEmpty ? (companiesList.first as Map<String, dynamic>) : <String, dynamic>{};
  
  CompanyProfile? company;
  if (companyData.isNotEmpty) {
    final companyJson = {
      ...companyData,
      if (profileData['verified'] != null) 'verified': profileData['verified'],
      if (profileData['active_jobs_count'] != null)
        'active_jobs_count': profileData['active_jobs_count'],
      if (profileData['total_applicants_count'] != null)
        'total_applicants_count': profileData['total_applicants_count'],
    };
    company = CompanyProfile.fromJson(companyJson);
    final resolvedCompany = company;
    Future.microtask(() {
      ref.read(companyProfileProvider.notifier).state = resolvedCompany;
    });
  }

  final dashData = dashRes.data['data'] ?? {};
  final recentJobsList = (dashData['recent_jobs'] as List?) ?? [];

  final dash = EmployerDashboardData(
    companyName: companyData['name'] ?? 'Your Company',
    totalJobs: dashData['total_jobs'] ?? 0,
    activeJobs: dashData['active_jobs'] ?? 0,
    totalApplicants: dashData['total_applicants'] ?? 0,
    shortlisted: dashData['shortlisted_count'] ?? 0,
    recentJobs: recentJobsList.map((j) => Job.fromJson(j)).toList(),
    isVerified: profileData['verified'] as bool? ?? (companyData['verification_status'] == 'verified'),
    verificationStatus: companyData['verification_status']?.toString() ?? 'unverified',
    userStatus: profileData['status']?.toString() ?? 'pending',
    profileCompleted: [
      int.tryParse(profileData['profile_completed']?.toString() ?? ''),
      int.tryParse(companyData['profile_completed']?.toString() ?? ''),
      int.tryParse(dashData['profile_completed']?.toString() ?? ''),
    ].where((e) => e != null).fold(0, (max, e) => e! > max ? e : max),
    isCompanyProfileComplete: company?.isProfileComplete ?? false,
  );
  
  debugPrint(
    '--- DASHBOARD PROVIDER PARSED PROFILE COMPLETED: ${dash.profileCompleted} ---',
  );
  return dash;
});
