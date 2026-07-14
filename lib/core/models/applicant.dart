import 'dart:ui';
import '../theme/app_colors.dart';

class Applicant {
  final String id;
  final String jobId;
  final String name;
  final String initials;
  final String role;
  final String? targetJobTitle; // The specific job they applied for
  final String
  status; // 'Applied', 'Shortlisted', 'Interview', 'Offered', 'Hired', 'Rejected'
  final DateTime appliedAt;
  final String email;
  final String phone;
  final String location;
  final String? coverLetter;
  final String? coverLetterUrl;
  final String? coverLetterFileName;
  final Map<String, String>? screeningAnswers;
  final String? about;
  final String experienceYears;
  final String expectedSalary;
  final String availability;
  final List<Map<String, String>> workExperience;
  final List<Map<String, String>> education;
  final List<String> skills;
  final bool hasMessaged;
  final String? avatarUrl;
  final String? resumeUrl;
  final String? seekerProfileId;
  final String? seekerUserId;
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
  final String? relocationType;

  const Applicant({
    required this.id,
    this.jobId = '',
    required this.name,
    required this.initials,
    required this.role,
    this.targetJobTitle,
    required this.status,
    required this.appliedAt,
    this.email = '',
    this.phone = '',
    this.location = '',
    this.coverLetter,
    this.coverLetterUrl,
    this.coverLetterFileName,
    this.screeningAnswers,
    this.about,
    this.experienceYears = '',
    this.expectedSalary = '',
    this.availability = '',
    this.workExperience = const [],
    this.education = const [],
    this.skills = const [],
    this.hasMessaged = false,
    this.avatarUrl,
    this.resumeUrl,
    this.seekerProfileId,
    this.seekerUserId,
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
  });

  Applicant.empty({
    required this.id,
    this.jobId = '',
    this.name = '',
    this.initials = '',
    this.role = '',
    this.targetJobTitle,
    this.status = 'Applied',
    DateTime? appliedAt,
    this.email = '',
    this.phone = '',
    this.location = '',
    this.coverLetter,
    this.coverLetterUrl,
    this.coverLetterFileName,
    this.screeningAnswers,
    this.about,
    this.experienceYears = '',
    this.expectedSalary = '',
    this.availability = '',
    this.workExperience = const [],
    this.education = const [],
    this.skills = const [],
    this.hasMessaged = false,
    this.avatarUrl,
    this.resumeUrl,
    this.seekerProfileId,
    this.seekerUserId,
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
  }) : appliedAt = appliedAt ?? DateTime.fromMillisecondsSinceEpoch(0);


  factory Applicant.fromJson(Map<String, dynamic> json) {
    // Some fields the API documents as a plain string come back as a nested
    // object instead for certain applicants (e.g. `conversation` is an
    // object once a chat exists for that applicant) — a raw `json['x']`
    // assignment to a String? field then throws and aborts the whole
    // parse. Guard so an unexpected shape yields null instead of a crash.
    String? asString(dynamic v) => v is String ? v : null;

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
      targetJobTitle: asString(json['target_job_title']),
      status: json['status'] ?? 'applied',
      appliedAt: json['applied_at'] != null ? DateTime.tryParse(json['applied_at']) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      showPhone: json['show_phone'] ?? true,
      location: json['location'] ?? '',
      coverLetter: asString(json['cover_letter']),
      // Attached document is the resolved join at json['cover_letters']
      // (singular, keyed by cover_letter_id) — falls back to a flat field
      // in case this endpoint ever returns it that way instead.
      coverLetterUrl: (json['cover_letters'] as Map<String, dynamic>?)?['file_url'] ??
          json['cover_letter_url'],
      coverLetterFileName: (json['cover_letters'] as Map<String, dynamic>?)?['file_name'] ??
          json['cover_letter_file_name'],
      screeningAnswers: json['screening_answers'] != null ? Map<String, String>.from(json['screening_answers']) : null,
      about: asString(json['about']),
      experienceYears: json['experience_years'] ?? '',
      expectedSalary: json['expected_salary'] ?? '',
      availability: json['availability'] ?? '',
      workExperience: (json['work_experience'] as List?)?.map((e) => Map<String, String>.from(e.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')))).toList() ?? [],
      education: (json['education'] as List?)?.map((e) => Map<String, String>.from(e.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')))).toList() ?? [],
      skills: (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      hasMessaged: json['has_messaged'] ?? false,
      avatarUrl: asString(json['avatar_url']),
      resumeUrl: (json['resumes'] as Map<String, dynamic>?)?['file_url'] ??
          json['resume_url'],
      seekerProfileId: json['seeker_profile_id']?.toString(),
      seekerUserId: json['seeker_user_id']?.toString() ?? json['user_id']?.toString(),
      resumeId: json['resume_id']?.toString(),
      employerRating: json['employer_rating'] != null ? int.tryParse(json['employer_rating'].toString()) : null,
      notes: asString(json['notes']),
      conversation: asString(json['conversation']),
      linkedinUrl: asString(json['linkedin_url']),
      githubUrl: asString(json['github_url']),
      portfolioUrl: asString(json['portfolio_url']),
      twitterUrl: asString(json['twitter_url']),
      websiteUrl: asString(json['website_url']),
      openToRelocation: json['open_to_relocation'] ?? false,
      relocationType: asString(json['relocation_type']),
    );
  }

  String get appliedAgo {
    final diff = DateTime.now().difference(appliedAt);
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'applied':
        return AppColors.stageApplied;
      case 'shortlisted':
        return AppColors.stageShortlisted;
      case 'interview':
        return AppColors.stageInterviewed;
      case 'offered':
        return AppColors.stageOffered;
      case 'hired':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.muted;
    }
  }

  Applicant copyWith({
    String? id,
    String? jobId,
    String? name,
    String? initials,
    String? role,
    String? targetJobTitle,
    String? status,
    DateTime? appliedAt,
    String? email,
    String? phone,
    String? location,
    String? coverLetter,
    Map<String, String>? screeningAnswers,
    String? about,
    String? experienceYears,
    String? expectedSalary,
    String? availability,
    List<Map<String, String>>? workExperience,
    List<Map<String, String>>? education,
    List<String>? skills,
    bool? hasMessaged,
    String? avatarUrl,
    String? resumeUrl,
  }) {
    return Applicant(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      role: role ?? this.role,
      targetJobTitle: targetJobTitle ?? this.targetJobTitle,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      coverLetter: coverLetter ?? this.coverLetter,
      screeningAnswers: screeningAnswers ?? this.screeningAnswers,
      about: about ?? this.about,
      experienceYears: experienceYears ?? this.experienceYears,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      availability: availability ?? this.availability,
      workExperience: workExperience ?? this.workExperience,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      hasMessaged: hasMessaged ?? this.hasMessaged,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      coverLetterUrl: coverLetterUrl,
      coverLetterFileName: coverLetterFileName,
      seekerProfileId: seekerProfileId,
      seekerUserId: seekerUserId,
      resumeId: resumeId,
      updatedAt: updatedAt,
      employerRating: employerRating,
      notes: notes,
      conversation: conversation,
      showPhone: showPhone,
      linkedinUrl: linkedinUrl,
      githubUrl: githubUrl,
      portfolioUrl: portfolioUrl,
      twitterUrl: twitterUrl,
      websiteUrl: websiteUrl,
      openToRelocation: openToRelocation,
      relocationType: relocationType,
    );
  }
}
