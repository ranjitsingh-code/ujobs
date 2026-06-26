import re

with open("lib/core/models/company_profile.dart", "r") as f:
    content = f.read()

# Add profileStatus
content = content.replace("final String? industryCategoryId;\n", "final String? industryCategoryId;\n  final int profileStatus;\n")
content = content.replace("this.industryCategoryId,\n", "this.industryCategoryId,\n    this.profileStatus = 0,\n")
content = content.replace("id: json['id']?.toString() ?? '',\n", "id: json['id']?.toString() ?? '',\n      profileStatus: json['profile_status'] is int ? json['profile_status'] : int.tryParse(json['profile_status']?.toString() ?? '0') ?? 0,\n")

with open("lib/core/models/company_profile.dart", "w") as f:
    f.write(content)

with open("lib/features/employer/dashboard/employer_dashboard_provider.dart", "r") as f:
    content2 = f.read()

provider_old = """final companyProfileCompletenessProvider = Provider<double>((ref) {
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
});"""

provider_new = """final companyProfileCompletenessProvider = Provider<double>((ref) {
  final profile = ref.watch(companyProfileProvider);
  return profile.profileStatus / 100.0;
});"""

content2 = content2.replace(provider_old, provider_new)

with open("lib/features/employer/dashboard/employer_dashboard_provider.dart", "w") as f:
    f.write(content2)

