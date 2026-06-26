import re

with open("lib/core/models/job.dart", "r") as f:
    content = f.read()

# Add import 'dart:convert'; if not present
if "import 'dart:convert';" not in content:
    content = "import 'dart:convert';\n" + content

# Replace preferredSkills, benefits, languages, certifications
old_fields = """      preferredSkills: (json['preferred_skills'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      benefits: (json['benefits'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      education: json['education'] as String?,
      openings: json['openings']?.toString(),
      applyVia: json['apply_via'] as String?,
      resumeRequirement: json['resume_requirement'] as String?,
      coverLetterRequirement: json['cover_letter_requirement'] as String?,
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      certifications: (json['certifications'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),"""

new_fields = """      preferredSkills: _parseStringList(json['preferred_skills']),
      benefits: _parseStringList(json['benefits']),
      education: json['education'] as String?,
      openings: json['openings']?.toString(),
      applyVia: json['apply_via'] as String?,
      resumeRequirement: json['resume_requirement'] as String?,
      coverLetterRequirement: json['cover_letter_requirement'] as String?,
      languages: _parseStringList(json['languages'] ?? json['languages_required']),
      certifications: _parseStringList(json['certifications'] ?? json['certifications_required']),"""

content = content.replace(old_fields, new_fields)

# Add _parseStringList helper at the end of the class
old_end = """  static DateTime? _parseDate(Map<String, dynamic> json, List<String> keys) {
    Object? value;
    for (final key in keys) {
      value ??= json[key];
    }
    return value == null ? null : DateTime.tryParse('$value');
  }
}"""

new_end = """  static DateTime? _parseDate(Map<String, dynamic> json, List<String> keys) {
    Object? value;
    for (final key in keys) {
      value ??= json[key];
    }
    return value == null ? null : DateTime.tryParse('$value');
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      if (value.trim().startsWith('[')) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return null;
  }
}"""

content = content.replace(old_end, new_end)

with open("lib/core/models/job.dart", "w") as f:
    f.write(content)

