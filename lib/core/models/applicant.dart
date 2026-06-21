import 'dart:ui';
import '../theme/app_colors.dart';

class Applicant {
  final String id;
  final String name;
  final String initials;
  final String role;
  final String? targetJobTitle; // The specific job they applied for
  final String status; // 'Applied', 'Shortlisted', 'Interview', 'Offered', 'Hired', 'Rejected'
  final DateTime appliedAt;
  final String email;
  final String phone;
  final String location;
  final String? coverLetter;
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

  const Applicant({
    required this.id,
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
  });

  String get appliedAgo {
    final diff = DateTime.now().difference(appliedAt);
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'applied': return AppColors.stageApplied;
      case 'shortlisted': return AppColors.stageShortlisted;
      case 'interview': return AppColors.stageInterviewed;
      case 'offered': return AppColors.stageOffered;
      case 'hired': return AppColors.success;
      case 'rejected': return AppColors.error;
      default: return AppColors.muted;
    }
  }

  Applicant copyWith({
    String? id,
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
  }) {
    return Applicant(
      id: id ?? this.id,
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
    );
  }
}
