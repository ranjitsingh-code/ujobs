import re

with open('lib/features/employer/applicants/employer_applicant_service.dart', 'r') as f:
    text = f.read()

target = """      return applicantsList.map((json) => _parseApplicant(json)).toList();"""
replacement = """      return applicantsList.map((json) => _parseFlattenedApplicant(json)).toList();"""
text = text.replace(target, replacement)

new_method = """  Applicant _parseFlattenedApplicant(Map<String, dynamic> json) {
    // Generate initials
    final name = json['name']?.toString() ?? 'Unknown Applicant';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    String initials = '';
    if (parts.isNotEmpty) initials += parts[0][0].toUpperCase();
    if (parts.length > 1) initials += parts[1][0].toUpperCase();
    if (initials.isEmpty) initials = 'U';

    final exp = (json['work_experience'] as List?)?.map((e) => {
      'title': e['title']?.toString() ?? '',
      'company': e['company']?.toString() ?? '',
      'location': e['location']?.toString() ?? '',
      'period': e['period']?.toString() ?? '',
      'description': e['description']?.toString() ?? '',
    }).toList() ?? [];

    final edu = (json['education'] as List?)?.map((e) => {
      'school': e['school']?.toString() ?? '',
      'degree': e['degree']?.toString() ?? '',
      'field': e['field']?.toString() ?? '',
      'grade': e['grade']?.toString() ?? '',
      'period': e['period']?.toString() ?? '',
    }).toList() ?? [];

    final answersMap = <String, String>{};
    final answers = json['screening_answers'];
    if (answers is Map) {
      answers.forEach((k, v) {
        answersMap[k.toString()] = v.toString();
      });
    }

    final skillsList = (json['skills'] as List?)?.map((s) => s.toString()).toList() ?? [];

    return Applicant(
      id: json['id']?.toString() ?? '',
      jobId: json['job_id']?.toString() ?? '',
      name: name,
      initials: initials,
      role: json['role']?.toString() ?? 'Applicant',
      targetJobTitle: json['target_job_title']?.toString() ?? '',
      status: (json['status']?.toString().toLowerCase() == 'pending') ? 'Applied' : (json['status']?.toString() ?? 'Applied'),
      appliedAt: DateTime.tryParse(json['applied_at']?.toString() ?? '') ?? DateTime.now(),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      coverLetter: _stripHtml(json['cover_letter']?.toString()),
      about: _stripHtml(json['about']?.toString()),
      experienceYears: json['experience_years']?.toString() ?? '',
      expectedSalary: json['expected_salary']?.toString() ?? '',
      availability: json['availability']?.toString() ?? '',
      skills: skillsList,
      workExperience: exp,
      education: edu,
      screeningAnswers: answersMap,
      hasMessaged: json['has_messaged'] == true,
      avatarUrl: json['avatar_url']?.toString(),
      resumeUrl: json['resume_url']?.toString(),
    );
  }
"""

text = text.replace("String _formatDate(String? isoDate) {", new_method + "\n  String _formatDate(String? isoDate) {")

with open('lib/features/employer/applicants/employer_applicant_service.dart', 'w') as f:
    f.write(text)
