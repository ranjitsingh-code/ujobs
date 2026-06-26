import re

with open('lib/features/employer/jobs/post_job_screen.dart', 'r') as f:
    text = f.read()

# 1. Add categories_provider import
target_import = "import '../../../core/providers/job_form_options_provider.dart';"
replacement_import = "import '../../../core/providers/job_form_options_provider.dart';\nimport '../../../core/providers/categories_provider.dart';"
if target_import in text:
    text = text.replace(target_import, replacement_import)

# 2. Add fallback variables in _submitJob
target_vars = """    final options = ref.read(jobFormOptionsProvider).valueOrNull;
    final fallbackApplyVia = options?.applicationMethods.isNotEmpty == true ? options!.applicationMethods.first.value : 'internal';
    final fallbackResume = options?.resumeRequirements.isNotEmpty == true ? options!.resumeRequirements.first.value : 'required';
    final fallbackCover = options?.coverLetterPolicies.isNotEmpty == true ? options!.coverLetterPolicies.first.value : 'optional';"""

replacement_vars = """    final options = ref.read(jobFormOptionsProvider).valueOrNull;
    final categories = ref.read(categoriesProvider).valueOrNull;
    
    final fallbackApplyVia = options?.applicationMethods.isNotEmpty == true ? options!.applicationMethods.first.value : 'internal';
    final fallbackResume = options?.resumeRequirements.isNotEmpty == true ? options!.resumeRequirements.first.value : 'required';
    final fallbackCover = options?.coverLetterPolicies.isNotEmpty == true ? options!.coverLetterPolicies.first.value : 'optional';
    final fallbackCategory = categories?.isNotEmpty == true ? categories!.first.id : '1';
    final fallbackEmpType = options?.employmentTypes.isNotEmpty == true ? options!.employmentTypes.first.value : 'full_time';
    final fallbackWorkplace = options?.workplaceTypes.isNotEmpty == true ? options!.workplaceTypes.first.value : 'on_site';
    final fallbackCurrency = options?.currencies.isNotEmpty == true ? options!.currencies.first.value : 'GBP';
    final fallbackSalaryPeriod = options?.salaryPeriods.isNotEmpty == true ? options!.salaryPeriods.first.value : 'monthly';
    final fallbackEducation = options?.minimumEducationLevels.isNotEmpty == true ? options!.minimumEducationLevels.first.value : 'High School';"""

if target_vars in text:
    text = text.replace(target_vars, replacement_vars)

# 3. Update payload with all fallbacks
target_payload = """        'employment_type': state.employmentType,
        'workplace_type': state.workplaceType,
        'category_id': state.category,
        'city': state.city,
        'country': state.country,
        'vacancies': int.tryParse(state.openings) ?? 1,
        if (state.deadline.isNotEmpty) 'application_deadline': state.deadline,
        if (state.salaryMin.isNotEmpty) 'salary_min': int.tryParse(state.salaryMin),
        if (state.salaryMax.isNotEmpty) 'salary_max': int.tryParse(state.salaryMax),
        'salary_currency': state.currency,
        'salary_period': state.salaryPeriod,
        'responsibilities': state.responsibilities,
        'requirements': state.requirements,
        if (state.experience.isNotEmpty) 'experience_min_years': int.tryParse(state.experience),
        'min_education': state.education,"""

replacement_payload = """        'employment_type': state.employmentType.isNotEmpty ? state.employmentType : fallbackEmpType,
        'workplace_type': state.workplaceType.isNotEmpty ? state.workplaceType : fallbackWorkplace,
        'category_id': state.category.isNotEmpty ? state.category : fallbackCategory,
        'city': state.city,
        'country': state.country,
        'vacancies': int.tryParse(state.openings) ?? 1,
        if (state.deadline.isNotEmpty) 'application_deadline': state.deadline,
        if (state.salaryMin.isNotEmpty) 'salary_min': int.tryParse(state.salaryMin),
        if (state.salaryMax.isNotEmpty) 'salary_max': int.tryParse(state.salaryMax),
        'salary_currency': state.currency.isNotEmpty ? state.currency : fallbackCurrency,
        'salary_period': state.salaryPeriod.isNotEmpty ? state.salaryPeriod : fallbackSalaryPeriod,
        'responsibilities': state.responsibilities,
        'requirements': state.requirements,
        if (state.experience.isNotEmpty) 'experience_min_years': int.tryParse(state.experience),
        'min_education': state.education.isNotEmpty ? state.education : fallbackEducation,"""

if target_payload in text:
    text = text.replace(target_payload, replacement_payload)

with open('lib/features/employer/jobs/post_job_screen.dart', 'w') as f:
    f.write(text)

