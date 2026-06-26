import re

with open('lib/features/employer/jobs/post_job_wizard_provider.dart', 'r') as f:
    text = f.read()

# Add requirements string to PostJobState
text = text.replace(
    "final String responsibilities;",
    "final String responsibilities;\n  final String requirements;"
)

text = text.replace(
    "this.responsibilities = '',",
    "this.responsibilities = '',\n    this.requirements = '',"
)

text = text.replace(
    "String? responsibilities,",
    "String? responsibilities,\n    String? requirements,"
)

text = text.replace(
    "responsibilities: responsibilities ?? this.responsibilities,",
    "responsibilities: responsibilities ?? this.responsibilities,\n      requirements: requirements ?? this.requirements,"
)

with open('lib/features/employer/jobs/post_job_wizard_provider.dart', 'w') as f:
    f.write(text)

