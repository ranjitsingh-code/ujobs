class SeekerProfile {
  final String id;
  final String userId;
  final String? headline;
  final String? summary;
  final String? city;
  final String? country;
  final double? experienceYears;
  final double? expectedSalary;
  final String? salaryCurrency;
  final String? salaryPeriod;
  final String? availability;
  final bool isFresher;
  final String? profileVisibility;
  final String? address;
  final String? zipCode;
  final bool showPhone;
  final bool openToRelocation;
  final String? relocationType;
  final String? relocationCities;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final String? twitterUrl;
  final String? websiteUrl;
  final String? about;
  final int? experienceYearsInt;
  final int? experienceMonths;
  final String? createdAt;
  final String? updatedAt;

  final List<SeekerSkill> skills;
  final List<SeekerExperience> experiences;
  final List<SeekerEducation> educations;
  final List<SeekerResume> resumes;
  final List<dynamic> certifications;

  const SeekerProfile({
    required this.id,
    required this.userId,
    this.headline,
    this.summary,
    this.city,
    this.country,
    this.experienceYears,
    this.expectedSalary,
    this.salaryCurrency,
    this.salaryPeriod,
    this.availability,
    this.isFresher = false,
    this.profileVisibility,
    this.address,
    this.zipCode,
    this.showPhone = true,
    this.openToRelocation = false,
    this.relocationType,
    this.relocationCities,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.twitterUrl,
    this.websiteUrl,
    this.about,
    this.experienceYearsInt,
    this.experienceMonths,
    this.createdAt,
    this.updatedAt,
    this.skills = const [],
    this.experiences = const [],
    this.educations = const [],
    this.resumes = const [],
    this.certifications = const [],
  });

  factory SeekerProfile.fromJson(Map<String, dynamic> json) {
    return SeekerProfile(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      headline: json['headline'] as String?,
      summary: json['summary'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      experienceYears: (json['experience_years'] as num?)?.toDouble(),
      expectedSalary: (json['expected_salary'] as num?)?.toDouble(),
      salaryCurrency: json['salary_currency'] as String?,
      salaryPeriod: json['salary_period'] as String?,
      availability: json['availability'] as String?,
      isFresher: json['is_fresher'] as bool? ?? false,
      profileVisibility: json['profile_visibility'] as String?,
      address: json['address'] as String?,
      zipCode: json['zip_code'] as String?,
      showPhone: json['show_phone'] as bool? ?? true,
      openToRelocation: json['open_to_relocation'] as bool? ?? false,
      relocationType: json['relocation_type'] as String?,
      relocationCities: json['relocation_cities'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      githubUrl: json['github_url'] as String?,
      portfolioUrl: json['portfolio_url'] as String?,
      twitterUrl: json['twitter_url'] as String?,
      websiteUrl: json['website_url'] as String?,
      about: json['about'] as String?,
      experienceYearsInt: json['experience_years_int'] as int?,
      experienceMonths: json['experience_months'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      certifications: (json['certifications'] as List?) ?? [],
      skills: (json['seeker_skills'] as List?)
              ?.map((e) => SeekerSkill.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      experiences: (json['seeker_experiences'] as List?)
              ?.map((e) => SeekerExperience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      educations: (json['seeker_educations'] as List?)
              ?.map((e) => SeekerEducation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      resumes: (json['resumes'] as List?)
              ?.map((e) => SeekerResume.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SeekerSkill {
  final String id;
  final String name;
  final String? proficiency;

  const SeekerSkill({
    required this.id,
    required this.name,
    this.proficiency,
  });

  factory SeekerSkill.fromJson(Map<String, dynamic> json) {
    final skillObj = json['skills'] as Map<String, dynamic>? ?? {};
    return SeekerSkill(
      id: json['skill_id']?.toString() ?? skillObj['id']?.toString() ?? '',
      name: skillObj['name'] as String? ?? '',
      proficiency: json['proficiency'] as String?,
    );
  }
}

class SeekerExperience {
  final String id;
  final String jobTitle;
  final String companyName;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String? description;

  const SeekerExperience({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    this.location,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
  });

  factory SeekerExperience.fromJson(Map<String, dynamic> json) {
    return SeekerExperience(
      id: json['id'].toString(),
      jobTitle: json['job_title'] as String? ?? '',
      companyName: json['company_name'] as String? ?? '',
      location: json['location'] as String?,
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      isCurrent: json['is_current'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }
}

class SeekerEducation {
  final String id;
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? grade;

  const SeekerEducation({
    required this.id,
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    this.startDate,
    this.endDate,
    this.grade,
  });

  factory SeekerEducation.fromJson(Map<String, dynamic> json) {
    return SeekerEducation(
      id: json['id'].toString(),
      institution: json['institution'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      fieldOfStudy: json['field_of_study'] as String? ?? '',
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      grade: json['grade']?.toString(),
    );
  }
}

class SeekerResume {
  final String id;
  final String fileUrl;
  final String fileName;
  final bool isPrimary;
  final DateTime? createdAt;

  const SeekerResume({
    required this.id,
    required this.fileUrl,
    required this.fileName,
    this.isPrimary = false,
    this.createdAt,
  });

  factory SeekerResume.fromJson(Map<String, dynamic> json) {
    return SeekerResume(
      id: json['id'].toString(),
      fileUrl: json['file_url'] as String? ?? '',
      fileName: json['file_name'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
