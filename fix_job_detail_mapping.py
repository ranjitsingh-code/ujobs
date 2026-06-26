import re

with open("lib/core/models/job.dart", "r") as f:
    content = f.read()

# Fix experienceLevel
content = content.replace(
    "experienceLevel: json['experience_level'] as String?,",
    "experienceLevel: (json['experience_level'] ?? json['experience_min_years'])?.toString(),"
)

# Fix requiredSkills
content = content.replace(
    "requiredSkills: json['required_skills'] as String?,",
    "requiredSkills: (json['required_skills'] ?? json['requirements']) as String?,"
)

# Fix education
content = content.replace(
    "education: json['education'] as String?,",
    "education: (json['education'] ?? json['min_education']) as String?,"
)

# Fix openings
content = content.replace(
    "openings: json['openings']?.toString(),",
    "openings: (json['openings'] ?? json['vacancies'])?.toString(),"
)

# Fix applyVia
content = content.replace(
    "applyVia: json['apply_via'] as String?,",
    "applyVia: (json['apply_via'] ?? json['application_method']) as String?,"
)

# Fix resumeRequirement
content = content.replace(
    "resumeRequirement: json['resume_requirement'] as String?,",
    "resumeRequirement: (json['resume_requirement'] ?? json['resume_required']) as String?,"
)

# Fix coverLetterRequirement
content = content.replace(
    "coverLetterRequirement: json['cover_letter_requirement'] as String?,",
    "coverLetterRequirement: (json['cover_letter_requirement'] ?? json['cover_letter_policy']) as String?,"
)

# Fix screeningQuestions
content = content.replace(
    """      screeningQuestions: (json['screening_questions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),""",
    """      screeningQuestions: (json['screening_questions'] ?? json['job_screening_questions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),"""
)

with open("lib/core/models/job.dart", "w") as f:
    f.write(content)

