import re

with open('lib/core/api/api_endpoints.dart', 'r') as f:
    text = f.read()
if "employerJobs =" not in text:
    text = text.replace(
        "  static const employerFeatureFlags = '/employer/features';",
        "  static const employerFeatureFlags = '/employer/features';\n  static const employerJobs = '/employer/jobs';"
    )
    with open('lib/core/api/api_endpoints.dart', 'w') as f:
        f.write(text)

with open('lib/features/employer/jobs/post_job_screen.dart', 'r') as f:
    text = f.read()

# Replace _submitJob method
submit_target = r'  void _submitJob\(JobStatus targetStatus\) \{.*?    context\.pop\(\);\n  \}'
submit_replacement = """  Future<void> _submitJob(String targetStatus) async {
    final state = ref.read(postJobWizardProvider);
    final dio = ref.read(dioClientProvider).dio;
    
    // Minimal validation
    if (state.title.isEmpty || state.description.isEmpty) {
      UJobToast.error(context, 'Title and Description are required.');
      return;
    }
    
    EasyLoading.show(status: 'Saving...');
    
    try {
      final payload = {
        'title': state.title,
        'description': state.description,
        'employment_type': state.employmentType,
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
        'min_education': state.education,
        'preferred_skills': state.preferredSkills.join(', '),
        'languages_required': state.languages.join(', '),
        'certifications_required': state.certifications.join(', '),
        if (state.ageMin.isNotEmpty) 'age_min': int.tryParse(state.ageMin),
        if (state.ageMax.isNotEmpty) 'age_max': int.tryParse(state.ageMax),
        'benefits': '[${state.benefits.map((b) => '"$b"').join(',')}]',
        'application_method': state.applyVia,
        if (state.applyVia == 'email' && state.applicationEmail.isNotEmpty) 'application_email': state.applicationEmail,
        if (state.applyVia == 'external' && state.applicationUrl.isNotEmpty) 'application_url': state.applicationUrl,
        'resume_required': state.resumeRequirement,
        'cover_letter_policy': state.coverLetterRequirement,
        'screening_questions': state.screeningQuestions
            .asMap()
            .entries
            .map((e) => {
                  'question_text': e.value.text,
                  'is_required': e.value.isRequired,
                  'order_index': e.key,
                })
            .toList(),
        'status': targetStatus,
      };

      if (_isEditing) {
        // Assume PUT /employer/jobs/:id
        await dio.put('${Ep.employerJobs}/${widget.job!.id}', data: payload);
      } else {
        await dio.post(Ep.employerJobs, data: payload);
      }
      
      EasyLoading.dismiss();
      UJobToast.success(context, targetStatus == 'draft' ? 'Job saved to drafts' : 'Job posted successfully');
      
      // Optionally refresh provider list here
      // ref.invalidate(employerJobsProvider);
      
      context.pop();
    } catch (e) {
      EasyLoading.dismiss();
      UJobToast.error(context, 'Failed to save job. Please try again.');
    }
  }"""
text = re.sub(submit_target, submit_replacement, text, flags=re.DOTALL)

# Add dioClientProvider import to post_job_screen.dart if missing
if "import '../../../../core/providers/auth_provider.dart';" not in text:
    text = text.replace("import 'post_job_wizard_provider.dart';", "import 'post_job_wizard_provider.dart';\nimport '../../../core/providers/auth_provider.dart';")
    text = text.replace("import '../../../core/api/api_endpoints.dart';", "import '../../../core/api/api_endpoints.dart';\nimport '../../../core/api/dio_client.dart';")

# Update onTap handlers for submit buttons
btn_draft = r"onTap: \(\) => _submitJob\(JobStatus\.draft\),"
text = re.sub(btn_draft, r"onTap: () => _submitJob('draft'),", text)

btn_publish = r"onTap: \(\) => _submitJob\(JobStatus\.pending\),"
text = re.sub(btn_publish, r"onTap: () => _submitJob('pending'),", text)

with open('lib/features/employer/jobs/post_job_screen.dart', 'w') as f:
    f.write(text)

