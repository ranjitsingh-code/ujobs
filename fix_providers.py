import re

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'r') as f:
    text = f.read()

old_completeness = """final companyProfileCompletenessProvider = Provider<double>((ref) {
  final profile = ref.watch(companyProfileProvider);
  int filled = 0;
  int total = 14; 
  
  if (profile.name.isNotEmpty) filled++;
  if (profile.logo != null && profile.logo!.isNotEmpty) filled++;
  if (profile.industry != null && profile.industry!.isNotEmpty) filled++;
  if (profile.description != null && profile.description!.isNotEmpty) filled++;
  if (profile.website != null && profile.website!.isNotEmpty) filled++;
  if (profile.contactPersonName != null && profile.contactPersonName!.isNotEmpty) filled++;
  if (profile.contactEmail != null && profile.contactEmail!.isNotEmpty) filled++;
  if (profile.contactPhone != null && profile.contactPhone!.isNotEmpty) filled++;
  if (profile.address != null && profile.address!.isNotEmpty) filled++;
  if (profile.city != null && profile.city!.isNotEmpty) filled++;
  if (profile.postcode != null && profile.postcode!.isNotEmpty) filled++;
  if (profile.country != null && profile.country!.isNotEmpty) filled++;
  if (profile.size != null && profile.size!.isNotEmpty) filled++;
  if (profile.workType != null && profile.workType!.isNotEmpty) filled++;
  
  return filled / total.toDouble();
});

final isCompanyProfileCompleteProvider = Provider<bool>((ref) {
  return ref.watch(companyProfileCompletenessProvider) == 1.0;
});"""

new_completeness = """final companyProfileCompletenessProvider = Provider<double>((ref) {
  final profile = ref.watch(companyProfileProvider);
  int filled = 0;
  int total = 16; 
  
  if (profile.name.isNotEmpty) filled++;
  if (profile.logo != null && profile.logo!.isNotEmpty) filled++;
  if (profile.industry != null && profile.industry!.isNotEmpty) filled++;
  if (profile.description != null && profile.description!.isNotEmpty) filled++;
  if (profile.website != null && profile.website!.isNotEmpty) filled++;
  if (profile.contactPersonName != null && profile.contactPersonName!.isNotEmpty) filled++;
  if (profile.contactEmail != null && profile.contactEmail!.isNotEmpty) filled++;
  if (profile.contactPhone != null && profile.contactPhone!.isNotEmpty) filled++;
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
         (profile.contactPersonName != null && profile.contactPersonName!.isNotEmpty) &&
         (profile.address != null && profile.address!.isNotEmpty) &&
         (profile.city != null && profile.city!.isNotEmpty) &&
         (profile.country != null && profile.country!.isNotEmpty);
});"""

text = text.replace(old_completeness, new_completeness)

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'w') as f:
    f.write(text)
