with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'r') as f:
    text = f.read()

# Replace the companyProfileProvider definition
old_provider = """final companyProfileProvider = StateProvider<CompanyProfile>((ref) {
  return const CompanyProfile(
    id: 'demo-company',
    name: 'Nexovia Technologies',
    industry: '',
    size: '',
    website: '',
    location: '',
    description: '',
    activeJobs: 2,
    applicants: 124,
  );
});"""

new_provider = """final companyProfileProvider = StateProvider<CompanyProfile>((ref) {
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
});"""
text = text.replace(old_provider, new_provider)

# Replace the completeness provider
old_completeness = """final companyProfileCompletenessProvider = Provider<double>((ref) {
  final profile = ref.watch(companyProfileProvider);
  int filled = 0;
  int total = 5; // name, industry, size, website, location, description (let's say 6)
  
  if (profile.name.isNotEmpty) filled++;
  if (profile.industry != null && profile.industry!.isNotEmpty) filled++;
  if (profile.size != null && profile.size!.isNotEmpty) filled++;
  if (profile.website != null && profile.website!.isNotEmpty) filled++;
  if (profile.location != null && profile.location!.isNotEmpty) filled++;
  if (profile.description != null && profile.description!.isNotEmpty) filled++;
  
  return filled / 6.0;
});"""

new_completeness = """final companyProfileCompletenessProvider = Provider<double>((ref) {
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
});"""
text = text.replace(old_completeness, new_completeness)

with open('lib/features/employer/dashboard/employer_dashboard_provider.dart', 'w') as f:
    f.write(text)
