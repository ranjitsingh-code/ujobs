import re

with open('lib/features/employer/applicants/employer_applicant_service.dart', 'r') as f:
    code = f.read()

if "import 'package:intl/intl.dart';" not in code:
    code = code.replace("import '../../../core/models/applicant.dart';", "import '../../../core/models/applicant.dart';\nimport 'package:intl/intl.dart';")

helper_method = """  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  Applicant _parseApplicant(Map<String, dynamic> json) {"""
code = code.replace("  Applicant _parseApplicant(Map<String, dynamic> json) {", helper_method)

work_exp_old = """    final workExp = (profile['seeker_experiences'] as List?)?.map((exp) {
      return {
        'title': exp['job_title']?.toString() ?? '',
        'company': exp['company_name']?.toString() ?? '',
        'location': exp['location']?.toString() ?? '',
        'period': '${exp['start_date'] ?? ''} - ${exp['is_current'] == true ? 'Present' : (exp['end_date'] ?? '')}',
        'description': exp['description']?.toString() ?? '',
      };
    }).toList() ?? [];"""

work_exp_new = """    final workExp = (profile['seeker_experiences'] as List?)?.map((exp) {
      final start = _formatDate(exp['start_date']?.toString());
      final end = exp['is_current'] == true ? 'Present' : _formatDate(exp['end_date']?.toString());
      return {
        'title': exp['job_title']?.toString() ?? '',
        'company': exp['company_name']?.toString() ?? '',
        'location': exp['location']?.toString() ?? '',
        'period': start.isNotEmpty ? '$start - $end' : '',
        'description': exp['description']?.toString() ?? '',
      };
    }).toList() ?? [];"""
code = code.replace(work_exp_old, work_exp_new)

edu_old = """    final edu = (profile['seeker_educations'] as List?)?.map((e) {
      return {
        'school': e['institution']?.toString() ?? '',
        'degree': e['degree']?.toString() ?? '',
        'field': e['field_of_study']?.toString() ?? '',
        'grade': e['grade']?.toString() ?? '',
      };
    }).toList() ?? [];"""

edu_new = """    final edu = (profile['seeker_educations'] as List?)?.map((e) {
      final start = _formatDate(e['start_date']?.toString());
      final end = _formatDate(e['end_date']?.toString());
      return {
        'school': e['institution']?.toString() ?? '',
        'degree': e['degree']?.toString() ?? '',
        'field': e['field_of_study']?.toString() ?? '',
        'grade': e['grade']?.toString() ?? '',
        'period': start.isNotEmpty ? '$start - $end' : '',
      };
    }).toList() ?? [];"""
code = code.replace(edu_old, edu_new)

code = code.replace("experienceYears: profile['experience_years']?.toString() ?? '',", "experienceYears: (profile['experience_years']?.toString().isNotEmpty == true) ? '${profile['experience_years']} Years' : '',")

with open('lib/features/employer/applicants/employer_applicant_service.dart', 'w') as f:
    f.write(code)
