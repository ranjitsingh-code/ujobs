import re

with open("lib/core/models/job.dart", "r") as f:
    content = f.read()

content = content.replace(
    """      screeningQuestions: (json['screening_questions'] ?? json['job_screening_questions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),""",
    """      screeningQuestions: ((json['screening_questions'] ?? json['job_screening_questions']) as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),"""
)

with open("lib/core/models/job.dart", "w") as f:
    f.write(content)

