import re

with open('lib/features/employer/jobs/post_job_screen.dart', 'r') as f:
    text = f.read()

target = """        'application_method': state.applyVia,
        if (state.applyVia == 'email' && state.applicationEmail.isNotEmpty) 'application_email': state.applicationEmail,
        if (state.applyVia == 'external' && state.applicationUrl.isNotEmpty) 'application_url': state.applicationUrl,
        'resume_required': state.resumeRequirement,
        'cover_letter_policy': state.coverLetterRequirement,"""

replacement = """        'application_method': state.applyVia.isNotEmpty ? state.applyVia : 'internal',
        if (state.applyVia == 'email' && state.applicationEmail.isNotEmpty) 'application_email': state.applicationEmail,
        if (state.applyVia == 'external' && state.applicationUrl.isNotEmpty) 'application_url': state.applicationUrl,
        'resume_required': state.resumeRequirement.isNotEmpty ? state.resumeRequirement : 'required',
        'cover_letter_policy': state.coverLetterRequirement.isNotEmpty ? state.coverLetterRequirement : 'optional',"""

text = text.replace(target, replacement)

with open('lib/features/employer/jobs/post_job_screen.dart', 'w') as f:
    f.write(text)

