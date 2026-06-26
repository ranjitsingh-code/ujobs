class FormOptionItem {
  final String value;
  final String label;
  final String? symbol;

  const FormOptionItem({
    required this.value,
    required this.label,
    this.symbol,
  });

  factory FormOptionItem.fromJson(Map<String, dynamic> json) {
    return FormOptionItem(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      symbol: json['symbol']?.toString(),
    );
  }
}

class SkillOptionItem {
  final String id;
  final String name;

  const SkillOptionItem({
    required this.id,
    required this.name,
  });

  factory SkillOptionItem.fromJson(Map<String, dynamic> json) {
    return SkillOptionItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class JobFormOptions {
  final List<FormOptionItem> employmentTypes;
  final List<FormOptionItem> workplaceTypes;
  final List<FormOptionItem> applicationMethods;
  final List<FormOptionItem> currencies;
  final List<FormOptionItem> salaryPeriods;
  final List<FormOptionItem> minimumEducationLevels;
  final List<FormOptionItem> resumeRequirements;
  final List<FormOptionItem> coverLetterPolicies;
  final List<String> benefitsList;
  final List<SkillOptionItem> preferredSkillsList;

  const JobFormOptions({
    required this.employmentTypes,
    required this.workplaceTypes,
    required this.applicationMethods,
    required this.currencies,
    required this.salaryPeriods,
    required this.minimumEducationLevels,
    required this.resumeRequirements,
    required this.coverLetterPolicies,
    required this.benefitsList,
    required this.preferredSkillsList,
  });

  factory JobFormOptions.fromJson(Map<String, dynamic> json) {
    List<FormOptionItem> parseOptions(String key) {
      final list = json[key] as List?;
      if (list == null) return [];
      return list.map((e) => FormOptionItem.fromJson(e as Map<String, dynamic>)).toList();
    }

    return JobFormOptions(
      employmentTypes: parseOptions('employment_types'),
      workplaceTypes: parseOptions('workplace_types'),
      applicationMethods: parseOptions('application_methods'),
      currencies: parseOptions('currencies'),
      salaryPeriods: parseOptions('salary_periods'),
      minimumEducationLevels: parseOptions('minimum_education_levels'),
      resumeRequirements: parseOptions('resume_requirements'),
      coverLetterPolicies: parseOptions('cover_letter_policies'),
      benefitsList: (json['benefits_list'] as List?)?.map((e) => e.toString()).toList() ?? [],
      preferredSkillsList: (json['preferred_skills_list'] as List?)
              ?.map((e) => SkillOptionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
