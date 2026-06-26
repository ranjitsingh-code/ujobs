import re

with open('lib/features/employer/jobs/post_job_wizard_provider.dart', 'r') as f:
    text = f.read()

# Add applicationEmail and applicationUrl to PostJobState
text = text.replace(
    "final String applyVia;",
    "final String applyVia;\n  final String applicationEmail;\n  final String applicationUrl;"
)

text = text.replace(
    "this.applyVia = 'Job Portal',",
    "this.applyVia = '',\n    this.applicationEmail = '',\n    this.applicationUrl = '',"
)

text = text.replace(
    "String? applyVia,",
    "String? applyVia,\n    String? applicationEmail,\n    String? applicationUrl,"
)

text = text.replace(
    "applyVia: applyVia ?? this.applyVia,",
    "applyVia: applyVia ?? this.applyVia,\n      applicationEmail: applicationEmail ?? this.applicationEmail,\n      applicationUrl: applicationUrl ?? this.applicationUrl,"
)

with open('lib/features/employer/jobs/post_job_wizard_provider.dart', 'w') as f:
    f.write(text)

