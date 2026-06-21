import 'company.dart';

enum JobStatus { active, pending, paused, closed, draft, rejected }

class Job {
  final int id;
  final String title;
  final String description;
  final String? category;
  final String employmentType; // e.g., full_time, part_time
  final String workplaceType; // e.g., remote, onsite, hybrid
  final String? location;
  final String? salaryMin;
  final String? salaryMax;
  final String? experienceLevel;
  final JobStatus status;
  final Company? company;
  final DateTime? createdAt;
  final bool isSaved;
  final int applicantCount;
  final int viewCount;
  final DateTime? closesAt;

  final String? responsibilities;
  final String? requiredSkills;
  final List<String>? preferredSkills;
  final List<String>? benefits;
  final String? education;
  final String? openings;
  final String? applyVia;
  final String? resumeRequirement;
  final String? coverLetterRequirement;
  final List<String>? languages;
  final List<String>? certifications;
  final String? ageMin;
  final String? ageMax;
  final List<Map<String, dynamic>>? screeningQuestions;

  Job({
    required this.id,
    required this.title,
    required this.description,
    this.category,
    required this.employmentType,
    required this.workplaceType,
    this.location,
    this.salaryMin,
    this.salaryMax,
    this.experienceLevel,
    this.status = JobStatus.pending,
    this.company,
    this.createdAt,
    this.isSaved = false,
    this.applicantCount = 0,
    this.viewCount = 0,
    this.closesAt,
    this.responsibilities,
    this.requiredSkills,
    this.preferredSkills,
    this.benefits,
    this.education,
    this.openings,
    this.applyVia,
    this.resumeRequirement,
    this.coverLetterRequirement,
    this.languages,
    this.certifications,
    this.ageMin,
    this.ageMax,
    this.screeningQuestions,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String?,
      employmentType: json['employment_type'] as String,
      workplaceType: json['workplace_type'] as String,
      location: json['location'] as String?,
      salaryMin: json['salary_min']?.toString(),
      salaryMax: json['salary_max']?.toString(),
      experienceLevel: json['experience_level'] as String?,
      status: _parseStatus(json['status'] as String?),
      company: json['company'] != null
          ? Company.fromJson(json['company'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      isSaved: json['is_saved'] ?? false,
      applicantCount: _parseApplicantCount(json),
      viewCount: _parseCount(json, const [
        'views_count',
        'view_count',
        'views',
      ]),
      closesAt: _parseDate(json, const [
        'application_deadline',
        'closes_at',
        'closing_date',
        'expires_at',
        'deadline',
      ]),
      responsibilities: json['responsibilities'] as String?,
      requiredSkills: json['required_skills'] as String?,
      preferredSkills: (json['preferred_skills'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      benefits: (json['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      education: json['education'] as String?,
      openings: json['openings']?.toString(),
      applyVia: json['apply_via'] as String?,
      resumeRequirement: json['resume_requirement'] as String?,
      coverLetterRequirement: json['cover_letter_requirement'] as String?,
      languages: (json['languages'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      certifications: (json['certifications'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      ageMin: json['age_min']?.toString(),
      ageMax: json['age_max']?.toString(),
      screeningQuestions: (json['screening_questions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  static JobStatus _parseStatus(String? status) {
    switch (status) {
      case 'active':
        return JobStatus.active;
      case 'pending':
        return JobStatus.pending;
      case 'paused':
        return JobStatus.paused;
      case 'draft':
        return JobStatus.draft;
      case 'closed':
        return JobStatus.closed;
      case 'rejected':
        return JobStatus.rejected;
      default:
        return JobStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'employment_type': employmentType,
    'workplace_type': workplaceType,
    'location': location,
    'salary_min': salaryMin,
    'salary_max': salaryMax,
    'experience_level': experienceLevel,
    'status': status.name,
    'company': company?.toJson(),
    'created_at': createdAt?.toIso8601String(),
    'applicants_count': applicantCount,
    'views_count': viewCount,
    'application_deadline': closesAt?.toIso8601String(),
  };

  Job copyWith({
    String? title,
    String? description,
    String? category,
    String? employmentType,
    String? workplaceType,
    String? location,
    String? salaryMin,
    String? salaryMax,
    String? experienceLevel,
    JobStatus? status,
    Company? company,
    DateTime? createdAt,
    bool? isSaved,
    int? applicantCount,
    int? viewCount,
    DateTime? closesAt,
    String? responsibilities,
    String? requiredSkills,
    List<String>? preferredSkills,
    List<String>? benefits,
    String? education,
    String? openings,
    String? applyVia,
    String? resumeRequirement,
    String? coverLetterRequirement,
    List<String>? languages,
    List<String>? certifications,
    String? ageMin,
    String? ageMax,
    List<Map<String, dynamic>>? screeningQuestions,
  }) {
    return Job(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      employmentType: employmentType ?? this.employmentType,
      workplaceType: workplaceType ?? this.workplaceType,
      location: location ?? this.location,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      status: status ?? this.status,
      company: company ?? this.company,
      createdAt: createdAt ?? this.createdAt,
      isSaved: isSaved ?? this.isSaved,
      applicantCount: applicantCount ?? this.applicantCount,
      viewCount: viewCount ?? this.viewCount,
      closesAt: closesAt ?? this.closesAt,
      responsibilities: responsibilities ?? this.responsibilities,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      preferredSkills: preferredSkills ?? this.preferredSkills,
      benefits: benefits ?? this.benefits,
      education: education ?? this.education,
      openings: openings ?? this.openings,
      applyVia: applyVia ?? this.applyVia,
      resumeRequirement: resumeRequirement ?? this.resumeRequirement,
      coverLetterRequirement: coverLetterRequirement ?? this.coverLetterRequirement,
      languages: languages ?? this.languages,
      certifications: certifications ?? this.certifications,
      ageMin: ageMin ?? this.ageMin,
      ageMax: ageMax ?? this.ageMax,
      screeningQuestions: screeningQuestions ?? this.screeningQuestions,
    );
  }

  static int _parseApplicantCount(Map<String, dynamic> json) {
    return _parseCount(json, const [
      'applicants_count',
      'applicant_count',
      'applications_count',
    ]);
  }

  static int _parseCount(Map<String, dynamic> json, List<String> keys) {
    Object? value;
    for (final key in keys) {
      value ??= json[key];
    }
    return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  }

  static DateTime? _parseDate(Map<String, dynamic> json, List<String> keys) {
    Object? value;
    for (final key in keys) {
      value ??= json[key];
    }
    return value == null ? null : DateTime.tryParse('$value');
  }
}
