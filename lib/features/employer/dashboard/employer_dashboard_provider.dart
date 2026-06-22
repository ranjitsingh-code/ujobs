import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/job.dart';
import '../../../core/models/company_profile.dart';
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
  int filled = 0;
  int total = 16;

  if (profile.name.isNotEmpty) filled++;
  if (profile.logo != null && profile.logo!.isNotEmpty) filled++;
  if (profile.industry != null && profile.industry!.isNotEmpty) filled++;
  if (profile.description != null && profile.description!.isNotEmpty) filled++;
  if (profile.website != null && profile.website!.isNotEmpty) filled++;
  if (profile.contactPersonName != null &&
      profile.contactPersonName!.isNotEmpty)
    filled++;
  if (profile.contactEmail != null && profile.contactEmail!.isNotEmpty)
    filled++;
  if (profile.contactPhone != null && profile.contactPhone!.isNotEmpty)
    filled++;
  if (profile.address != null && profile.address!.isNotEmpty) filled++;
  if (profile.city != null && profile.city!.isNotEmpty) filled++;
  if (profile.postcode != null && profile.postcode!.isNotEmpty) filled++;
  if (profile.country != null && profile.country!.isNotEmpty) filled++;
  if (profile.size != null && profile.size!.isNotEmpty) filled++;
  if (profile.workType != null && profile.workType!.isNotEmpty) filled++;
  if (profile.linkedInUrl != null && profile.linkedInUrl!.isNotEmpty) filled++;
  if (profile.facebookUrl != null && profile.facebookUrl!.isNotEmpty) filled++;

  return filled / total.toDouble();
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

  EmployerDashboardData({
    required this.companyName,
    required this.totalJobs,
    required this.activeJobs,
    required this.totalApplicants,
    required this.shortlisted,
    required this.recentJobs,
  });
}

final employerDashboardProvider = Provider.autoDispose<EmployerDashboardData>((
  ref,
) {
  final jobs = ref.watch(demoEmployerJobsProvider);
  final company = ref.watch(companyProfileProvider);
  return EmployerDashboardData(
    companyName: company.name,
    totalJobs: jobs.length,
    activeJobs: jobs.where((job) => job.status == JobStatus.active).length,
    totalApplicants: 124,
    shortlisted: 23,
    recentJobs: jobs.take(3).toList(),
  );
});
