import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreeningQuestion {
  final String text;
  final bool isRequired;

  const ScreeningQuestion({required this.text, this.isRequired = true});

  ScreeningQuestion copyWith({String? text, bool? isRequired}) {
    return ScreeningQuestion(
      text: text ?? this.text,
      isRequired: isRequired ?? this.isRequired,
    );
  }
}

class PostJobState {
  // Step 1: Job Details
  final String title;
  final String category;
  final String customCategory;
  final String openings;
  final String employmentType;
  final String workplaceType;
  final String city;
  final String country;
  final String currency;
  final String salaryPeriod;
  final String salaryMin;
  final String salaryMax;
  final String description;
  final String responsibilities;

  // Step 2: Requirements
  final String education;
  final String experience;
  final String requiredSkills;
  final List<String> preferredSkills;
  final List<String> languages;
  final List<String> certifications;
  final String ageMin;
  final String ageMax;

  // Step 3: Benefits
  final List<String> benefits;

  // Step 4: Application
  final String applyVia;
  final String resumeRequirement;
  final String coverLetterRequirement;
  final String deadline;

  // Step 5: Screening
  final List<ScreeningQuestion> screeningQuestions;

  const PostJobState({
    this.title = '',
    this.category = '',
    this.customCategory = '',
    this.openings = '1',
    this.employmentType = 'Full-Time',
    this.workplaceType = 'Remote',
    this.city = '',
    this.country = '',
    this.currency = 'USD',
    this.salaryPeriod = 'Yearly',
    this.salaryMin = '',
    this.salaryMax = '',
    this.description = '',
    this.responsibilities = '',
    this.education = 'No requirement',
    this.experience = '',
    this.requiredSkills = '',
    this.preferredSkills = const [],
    this.languages = const [],
    this.certifications = const [],
    this.ageMin = '',
    this.ageMax = '',
    this.benefits = const [],
    this.applyVia = 'Job Portal',
    this.resumeRequirement = 'Required',
    this.coverLetterRequirement = 'Optional',
    this.deadline = '',
    this.screeningQuestions = const [],
  });

  PostJobState copyWith({
    String? title,
    String? category,
    String? customCategory,
    String? openings,
    String? employmentType,
    String? workplaceType,
    String? city,
    String? country,
    String? currency,
    String? salaryPeriod,
    String? salaryMin,
    String? salaryMax,
    String? description,
    String? responsibilities,
    String? education,
    String? experience,
    String? requiredSkills,
    List<String>? preferredSkills,
    List<String>? languages,
    List<String>? certifications,
    String? ageMin,
    String? ageMax,
    List<String>? benefits,
    String? applyVia,
    String? resumeRequirement,
    String? coverLetterRequirement,
    String? deadline,
    List<ScreeningQuestion>? screeningQuestions,
  }) {
    return PostJobState(
      title: title ?? this.title,
      category: category ?? this.category,
      customCategory: customCategory ?? this.customCategory,
      openings: openings ?? this.openings,
      employmentType: employmentType ?? this.employmentType,
      workplaceType: workplaceType ?? this.workplaceType,
      city: city ?? this.city,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      salaryPeriod: salaryPeriod ?? this.salaryPeriod,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      description: description ?? this.description,
      responsibilities: responsibilities ?? this.responsibilities,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      preferredSkills: preferredSkills ?? this.preferredSkills,
      languages: languages ?? this.languages,
      certifications: certifications ?? this.certifications,
      ageMin: ageMin ?? this.ageMin,
      ageMax: ageMax ?? this.ageMax,
      benefits: benefits ?? this.benefits,
      applyVia: applyVia ?? this.applyVia,
      resumeRequirement: resumeRequirement ?? this.resumeRequirement,
      coverLetterRequirement: coverLetterRequirement ?? this.coverLetterRequirement,
      deadline: deadline ?? this.deadline,
      screeningQuestions: screeningQuestions ?? this.screeningQuestions,
    );
  }
}

class PostJobWizardNotifier extends StateNotifier<PostJobState> {
  PostJobWizardNotifier() : super(const PostJobState());

  void updateField(PostJobState newState) {
    state = newState;
  }
}

final postJobWizardProvider =
    StateNotifierProvider.autoDispose<PostJobWizardNotifier, PostJobState>((ref) {
  return PostJobWizardNotifier();
});
