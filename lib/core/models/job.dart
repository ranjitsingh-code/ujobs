import 'dart:convert';
import 'company.dart';

enum JobStatus { active, pending, paused, closed, draft, rejected }

class Job {
  final int id;
  final String title;
  final String description;
  final String? category;
  final String? categoryId;
  final String employmentType; // e.g., full_time, part_time
  final String workplaceType; // e.g., remote, onsite, hybrid
  final String? location;
  final String? country;
  final String? salaryMin;
  final String? salaryMax;
  final String? salaryCurrency;
  final String? salaryPeriod;
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

  // Seeker-specific fields
  final bool isApplied;
  final String? applicationId;
  final String? applicationStatus;
  final bool chatEnabled;

  Job({
    required this.id,
    required this.title,
    required this.description,
    this.category,
    this.categoryId,
    required this.employmentType,
    required this.workplaceType,
    this.location,
    this.country,
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency,
    this.salaryPeriod,
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
    this.isApplied = false,
    this.applicationId,
    this.applicationStatus,
    this.chatEnabled = false,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['categories'] != null ? (json['categories']['name'] as String?) : json['category'] as String?,
      categoryId: json['category_id']?.toString() ?? json['categories']?['id']?.toString(),
      employmentType: json['employment_type'] as String? ?? '',
      workplaceType: json['workplace_type'] as String? ?? '',
      location: (json['location'] ?? json['city'])?.toString(),
      country: json['country']?.toString(),
      salaryMin: json['salary_min']?.toString(),
      salaryMax: json['salary_max']?.toString(),
      salaryCurrency: json['salary_currency'] as String?,
      salaryPeriod: json['salary_period'] as String?,
      experienceLevel: (json['experience_level'] ?? json['experience_min_years'])?.toString(),
      status: _parseStatus(json['status'] as String?),
      company: (json['companies'] ?? json['company']) != null
          ? Company.fromJson((json['companies'] ?? json['company']) is List
              ? ((json['companies'] ?? json['company']) as List).first
              : (json['companies'] ?? json['company']))
          : null,
      createdAt: _parseDate(json, const [
        'posted_at',
        'published_at',
        'created_at',
      ]),
      isSaved: json['is_saved'] ?? false,
      applicantCount: _parseApplicantCount(json),
      viewCount: _parseCount(json, const [
        'views_count',
        'view_count',
        'views',
      ]) > 0 ? _parseCount(json, const [
        'views_count',
        'view_count',
        'views',
      ]) : _parseApplicantCount(json),
      closesAt: _parseDate(json, const [
        'application_deadline',
        'closes_at',
        'closing_date',
        'expires_at',
        'deadline',
      ]),
      responsibilities: json['responsibilities'] as String?,
      requiredSkills: (json['required_skills'] ?? json['requirements']) as String?,
      preferredSkills: _parseStringList(json['preferred_skills']),
      benefits: _parseStringList(json['benefits']),
      education: (json['education'] ?? json['min_education']) as String?,
      openings: (json['openings'] ?? json['vacancies'])?.toString(),
      applyVia: (json['apply_via'] ?? json['application_method']) as String?,
      resumeRequirement: (json['resume_requirement'] ?? json['resume_required']) as String?,
      coverLetterRequirement: (json['cover_letter_requirement'] ?? json['cover_letter_policy']) as String?,
      languages: _parseStringList(json['languages'] ?? json['languages_required']),
      certifications: _parseStringList(json['certifications'] ?? json['certifications_required']),
      ageMin: json['age_min']?.toString(),
      ageMax: json['age_max']?.toString(),
      screeningQuestions: ((json['screening_questions'] ?? json['job_screening_questions']) as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      isApplied: json['is_applied'] ?? false,
      applicationId: json['application_id']?.toString(),
      applicationStatus: json['application_status']?.toString(),
      chatEnabled: json['chat_enabled'] ?? false,
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
    String? categoryId,
    String? employmentType,
    String? workplaceType,
    String? location,
    String? country,
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
    bool? isApplied,
    String? applicationId,
    String? applicationStatus,
    bool? chatEnabled,
  }) {
    return Job(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      employmentType: employmentType ?? this.employmentType,
      workplaceType: workplaceType ?? this.workplaceType,
      location: location ?? this.location,
      country: country ?? this.country,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryCurrency: salaryCurrency ?? salaryCurrency,
      salaryPeriod: salaryPeriod ?? salaryPeriod,
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
      coverLetterRequirement:
          coverLetterRequirement ?? this.coverLetterRequirement,
      languages: languages ?? this.languages,
      certifications: certifications ?? this.certifications,
      ageMin: ageMin ?? this.ageMin,
      ageMax: ageMax ?? this.ageMax,
      screeningQuestions: screeningQuestions ?? this.screeningQuestions,
      isApplied: isApplied ?? this.isApplied,
      applicationId: applicationId ?? this.applicationId,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      chatEnabled: chatEnabled ?? this.chatEnabled,
    );
  }

  static int _parseApplicantCount(Map<String, dynamic> json) {
    if (json['_count'] is Map && json['_count']['applications'] != null) {
      return int.tryParse(json['_count']['applications'].toString()) ?? 0;
    }
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

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      if (value.trim().startsWith('[')) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return null;
  }
}
