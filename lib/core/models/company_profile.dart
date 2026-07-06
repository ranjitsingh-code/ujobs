class CompanyProfile {
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
  final String? industryCategoryId;
  final int profileStatus;

  final bool? verified;

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
    this.industryCategoryId,
    this.profileStatus = 0,
    this.verified,
    this.activeJobs = 0,
    this.applicants = 0,
  });

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      id: json['id']?.toString() ?? '',
      verified: json['verified'] as bool? ?? (json['verification_status'] == 'verified'),
      profileStatus: json['profile_completed'] is int
          ? json['profile_completed']
          : int.tryParse(json['profile_completed']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? '',
      logo: json['logo_url'] as String?,
      industry: json['categories']?['name'] as String?,
      size: json['company_size'] as String?,
      workType: json['work_type'] as String?,
      website: json['website'] as String?,
      description: json['about'] as String?,
      contactPersonName: json['contact_person'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      showContactInfo: json['show_contact_info'] as bool? ?? false,
      address: json['address'] as String?,
      city: json['city'] as String?,
      postcode: json['zip_code'] as String?,
      country: json['country'] as String?,
      linkedInUrl: json['linkedin_url'] as String?,
      facebookUrl: json['facebook_url'] as String?,
      industryCategoryId: json['industry_category_id']?.toString(),
      activeJobs: json['active_jobs_count'] as int? ?? 0,
      applicants: json['total_applicants_count'] as int? ??
          json['applicants_count'] as int? ??
          0,
    );
  }

  bool get isProfileComplete =>
      name.isNotEmpty &&
      (industryCategoryId != null && industryCategoryId!.isNotEmpty) &&
      (description != null && description!.isNotEmpty) &&
      (contactPersonName != null && contactPersonName!.isNotEmpty) &&
      (contactEmail != null && contactEmail!.isNotEmpty) &&
      (contactPhone != null && contactPhone!.isNotEmpty) &&
      (address != null && address!.isNotEmpty) &&
      (city != null && city!.isNotEmpty) &&
      (postcode != null && postcode!.isNotEmpty) &&
      (country != null && country!.isNotEmpty) &&
      (size != null && size!.isNotEmpty) &&
      (workType != null && workType!.isNotEmpty);

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
    String? industryCategoryId,
    int? profileStatus,
    bool? verified,
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
      industryCategoryId: industryCategoryId ?? this.industryCategoryId,
      profileStatus: profileStatus ?? this.profileStatus,
      verified: verified ?? this.verified,
      activeJobs: activeJobs,
      applicants: applicants,
    );
  }
}
