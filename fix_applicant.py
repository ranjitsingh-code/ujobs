import re

with open('lib/core/models/applicant.dart', 'r') as f:
    text = f.read()

# Add new fields
fields_target = "  final String? resumeUrl;"
fields_replacement = """  final String? resumeUrl;
  final String? seekerProfileId;
  final String? resumeId;
  final DateTime? updatedAt;
  final int? employerRating;
  final String? notes;
  final String? conversation;
  final bool showPhone;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final String? twitterUrl;
  final String? websiteUrl;
  final bool openToRelocation;
  final String? relocationType;"""
text = text.replace(fields_target, fields_replacement)

# Update constructor
constructor_target = "    this.resumeUrl,\n  });"
constructor_replacement = """    this.resumeUrl,
    this.seekerProfileId,
    this.resumeId,
    this.updatedAt,
    this.employerRating,
    this.notes,
    this.conversation,
    this.showPhone = true,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.twitterUrl,
    this.websiteUrl,
    this.openToRelocation = false,
    this.relocationType,
  });"""
text = text.replace(constructor_target, constructor_replacement)

# Add fromJson factory
factory = """
  factory Applicant.fromJson(Map<String, dynamic> json) {
    String getInitials(String name) {
      if (name.isEmpty) return 'NA';
      final parts = name.trim().split(' ');
      if (parts.length > 1) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }

    return Applicant(
      id: json['id']?.toString() ?? '',
      jobId: json['job_id']?.toString() ?? '',
      name: json['name'] ?? '',
      initials: getInitials(json['name'] ?? ''),
      role: json['role'] ?? '',
      targetJobTitle: json['target_job_title'],
      status: json['status'] ?? 'applied',
      appliedAt: json['applied_at'] != null ? DateTime.tryParse(json['applied_at']) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      showPhone: json['show_phone'] ?? true,
      location: json['location'] ?? '',
      coverLetter: json['cover_letter'],
      screeningAnswers: json['screening_answers'] != null ? Map<String, String>.from(json['screening_answers']) : null,
      about: json['about'],
      experienceYears: json['experience_years'] ?? '',
      expectedSalary: json['expected_salary'] ?? '',
      availability: json['availability'] ?? '',
      workExperience: (json['work_experience'] as List?)?.map((e) => Map<String, String>.from(e.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')))).toList() ?? [],
      education: (json['education'] as List?)?.map((e) => Map<String, String>.from(e.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')))).toList() ?? [],
      skills: (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      hasMessaged: json['has_messaged'] ?? false,
      avatarUrl: json['avatar_url'],
      resumeUrl: json['resume_url'],
      seekerProfileId: json['seeker_profile_id']?.toString(),
      resumeId: json['resume_id']?.toString(),
      employerRating: json['employer_rating'] != null ? int.tryParse(json['employer_rating'].toString()) : null,
      notes: json['notes'],
      conversation: json['conversation'],
      linkedinUrl: json['linkedin_url'],
      githubUrl: json['github_url'],
      portfolioUrl: json['portfolio_url'],
      twitterUrl: json['twitter_url'],
      websiteUrl: json['website_url'],
      openToRelocation: json['open_to_relocation'] ?? false,
      relocationType: json['relocation_type'],
    );
  }
"""

text = text.replace("  String get appliedAgo {", factory + "\n  String get appliedAgo {")

with open('lib/core/models/applicant.dart', 'w') as f:
    f.write(text)

