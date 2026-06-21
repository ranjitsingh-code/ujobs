with open('lib/core/models/company_profile.dart', 'r') as f:
    text = f.read()

new_model = """class CompanyProfile {
  final String id;
  final String name;
  final String? logo;
  final String? industry;
  final String? size;
  final String? workType;
  final String? website;
  final String? description;
  final String? contactPersonName;
  final String? contactEmail;
  final String? contactPhone;
  final bool showContactInfo;
  final String? address;
  final String? city;
  final String? postcode;
  final String? country;
  final String? linkedInUrl;
  final String? facebookUrl;
  
  final int activeJobs;
  final int applicants;

  const CompanyProfile({
    required this.id,
    required this.name,
    this.logo,
    this.industry,
    this.size,
    this.workType,
    this.website,
    this.description,
    this.contactPersonName,
    this.contactEmail,
    this.contactPhone,
    this.showContactInfo = false,
    this.address,
    this.city,
    this.postcode,
    this.country,
    this.linkedInUrl,
    this.facebookUrl,
    this.activeJobs = 0,
    this.applicants = 0,
  });

  CompanyProfile copyWith({
    String? name,
    String? logo,
    String? industry,
    String? size,
    String? workType,
    String? website,
    String? description,
    String? contactPersonName,
    String? contactEmail,
    String? contactPhone,
    bool? showContactInfo,
    String? address,
    String? city,
    String? postcode,
    String? country,
    String? linkedInUrl,
    String? facebookUrl,
  }) {
    return CompanyProfile(
      id: id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      industry: industry ?? this.industry,
      size: size ?? this.size,
      workType: workType ?? this.workType,
      website: website ?? this.website,
      description: description ?? this.description,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      showContactInfo: showContactInfo ?? this.showContactInfo,
      address: address ?? this.address,
      city: city ?? this.city,
      postcode: postcode ?? this.postcode,
      country: country ?? this.country,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      activeJobs: activeJobs,
      applicants: applicants,
    );
  }
}
"""

text = new_model
with open('lib/core/models/company_profile.dart', 'w') as f:
    f.write(text)
