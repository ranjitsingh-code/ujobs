import re

with open('lib/features/employer/jobs/post_job_screen.dart', 'r') as f:
    text = f.read()

target1 = """    final state = ref.read(postJobWizardProvider);
    final dio = ref.read(dioClientProvider).dio;"""

replacement1 = """    final state = ref.read(postJobWizardProvider);
    final dio = ref.read(dioClientProvider).dio;
    
    final options = ref.read(jobFormOptionsProvider).valueOrNull;
    final fallbackApplyVia = options?.applicationMethods.isNotEmpty == true ? options!.applicationMethods.first.value : 'internal';
    final fallbackResume = options?.resumeRequirements.isNotEmpty == true ? options!.resumeRequirements.first.value : 'required';
    final fallbackCover = options?.coverLetterPolicies.isNotEmpty == true ? options!.coverLetterPolicies.first.value : 'optional';"""

text = text.replace(target1, replacement1)

target2 = """        'application_method': state.applyVia.isNotEmpty ? state.applyVia : 'internal',
        if (state.applyVia == 'email' && state.applicationEmail.isNotEmpty) 'application_email': state.applicationEmail,
        if (state.applyVia == 'external' && state.applicationUrl.isNotEmpty) 'application_url': state.applicationUrl,
        'resume_required': state.resumeRequirement.isNotEmpty ? state.resumeRequirement : 'required',
        'cover_letter_policy': state.coverLetterRequirement.isNotEmpty ? state.coverLetterRequirement : 'optional',"""

replacement2 = """        'application_method': state.applyVia.isNotEmpty ? state.applyVia : fallbackApplyVia,
        if (state.applyVia == 'email' && state.applicationEmail.isNotEmpty) 'application_email': state.applicationEmail,
        if (state.applyVia == 'external' && state.applicationUrl.isNotEmpty) 'application_url': state.applicationUrl,
        'resume_required': state.resumeRequirement.isNotEmpty ? state.resumeRequirement : fallbackResume,
        'cover_letter_policy': state.coverLetterRequirement.isNotEmpty ? state.coverLetterRequirement : fallbackCover,"""

text = text.replace(target2, replacement2)

with open('lib/features/employer/jobs/post_job_screen.dart', 'w') as f:
    f.write(text)

