import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/applicant.dart';
import 'package:intl/intl.dart';

final employerApplicantServiceProvider = Provider<EmployerApplicantService>((ref) {
  return EmployerApplicantService(ref.watch(dioClientProvider));
});

class EmployerApplicantService {
  final DioClient _client;

  EmployerApplicantService(this._client);

  Future<List<Applicant>> getJobApplicants(int jobId) async {
    try {
      final response = await _client.dio.get('/employer/jobs/$jobId/applicants');
      final data = response.data['data'] as List?;
      if (data == null) return [];

      return data.map((json) => _parseApplicant(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Applicant> getApplicantDetails(String applicantId) async {
    try {
      final response = await _client.dio.get('/employer/applicants/$applicantId');
      final data = response.data['data'];
      return Applicant.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateApplicantStage(String appId, String stage) async {
    try {
      await _client.dio.patch(
        '/employer/applications/$appId/stage',
        data: {'stage': stage.toLowerCase()},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Applicant>> getAllApplicants() async {
    try {
      final response = await _client.dio.get('/employer/applicants');
      final data = response.data['data'];
      if (data == null) return [];
      
      final applicantsList = data['applicants'] as List?;
      if (applicantsList == null) return [];

      return applicantsList.map((json) => _parseFlattenedApplicant(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

    Applicant _parseFlattenedApplicant(Map<String, dynamic> json) {
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
      targetJobTitle: json['target_job_title']?.toString(),
      status: (json['status']?.toString().toLowerCase() == 'pending') ? 'applied' : (json['status']?.toString() ?? 'applied'),
      appliedAt: DateTime.tryParse(json['applied_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      showPhone: json['show_phone'] ?? true,
      location: json['location']?.toString() ?? '',
      coverLetter: _stripHtml(json['cover_letter']?.toString()),
      // Flattened endpoint doesn't send a nested cover_letters join today —
      // check it anyway (same shape as the per-job endpoint) so this keeps
      // working if/when backend adds it, falling back to flat fields.
      coverLetterUrl: (json['cover_letters'] as Map<String, dynamic>?)?['file_url']?.toString() ??
          json['cover_letter_url']?.toString(),
      coverLetterFileName: (json['cover_letters'] as Map<String, dynamic>?)?['file_name']?.toString() ??
          json['cover_letter_file_name']?.toString(),
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
      seekerProfileId: json['seeker_profile_id']?.toString(),
      seekerUserId: json['seeker_user_id']?.toString() ?? json['user_id']?.toString(),
      resumeId: json['resume_id']?.toString(),
      employerRating: json['employer_rating'] != null ? int.tryParse(json['employer_rating'].toString()) : null,
      notes: json['notes']?.toString(),
      conversation: json['conversation']?.toString(),
      linkedinUrl: json['linkedin_url']?.toString(),
      githubUrl: json['github_url']?.toString(),
      portfolioUrl: json['portfolio_url']?.toString(),
      twitterUrl: json['twitter_url']?.toString(),
      websiteUrl: json['website_url']?.toString(),
      openToRelocation: json['open_to_relocation'] ?? false,
      relocationType: json['relocation_type']?.toString(),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  String _stripHtml(String? text) {
    if (text == null || text.isEmpty) return '';
    // Replace <br> and <p> tags with newlines before stripping to preserve paragraph formatting
    String parsed = text.replaceAll(RegExp(r'(<br\s*/?>|</p>|<p>)', caseSensitive: false), '\n');
    // Strip remaining HTML tags
    parsed = parsed.replaceAll(RegExp(r'<[^>]*>'), '');
    // Decode basic HTML entities
    parsed = parsed.replaceAll('&nbsp;', ' ');
    parsed = parsed.replaceAll('&amp;', '&');
    parsed = parsed.replaceAll('&lt;', '<');
    parsed = parsed.replaceAll('&gt;', '>');
    parsed = parsed.replaceAll('&quot;', '"');
    parsed = parsed.replaceAll('&#39;', "'");
    // Clean up multiple newlines
    parsed = parsed.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return parsed.trim();
  }

  Applicant _parseApplicant(Map<String, dynamic> json) {
    final application = json;
    final profile = json['seeker_profiles'] ?? {};
    final jobIdStr = application['job_id']?.toString() ?? '';
    final users = profile['users'] ?? {};
    
    final firstName = users['first_name'] ?? '';
    final lastName = users['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    
    // Initials logic if avatar is missing
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0].toUpperCase();
    if (lastName.isNotEmpty) initials += lastName[0].toUpperCase();
    if (initials.isEmpty) initials = 'U';

    final locationStr = [
      if (profile['city'] != null) profile['city'],
      if (profile['country'] != null) profile['country'],
    ].join(', ');

    // Extract expected salary
    final salary = profile['expected_salary']?.toString() ?? '';
    final currency = profile['salary_currency']?.toString() ?? '';
    final expectedSalary = '$salary $currency'.trim();

    // Extract skills
    final skillsList = (profile['seeker_skills'] as List?)?.map((s) {
      return s['skills']?['name']?.toString() ?? '';
    }).where((s) => s.isNotEmpty).toList() ?? [];

    // Extract work experience
    final workExp = (profile['seeker_experiences'] as List?)?.map((exp) {
      final start = _formatDate(exp['start_date']?.toString());
      final end = exp['is_current'] == true ? 'Present' : _formatDate(exp['end_date']?.toString());
      return {
        'title': exp['job_title']?.toString() ?? '',
        'company': exp['company_name']?.toString() ?? '',
        'location': exp['location']?.toString() ?? '',
        'period': start.isNotEmpty ? '$start - $end' : '',
        'description': exp['description']?.toString() ?? '',
      };
    }).toList() ?? [];

    // Extract education
    final edu = (profile['seeker_educations'] as List?)?.map((e) {
      final start = _formatDate(e['start_date']?.toString());
      final end = _formatDate(e['end_date']?.toString());
      return {
        'school': e['institution']?.toString() ?? '',
        'degree': e['degree']?.toString() ?? '',
        'field': e['field_of_study']?.toString() ?? '',
        'grade': e['grade']?.toString() ?? '',
        'period': start.isNotEmpty ? '$start - $end' : '',
      };
    }).toList() ?? [];

    // Extract screening answers
    final Map<String, String> answersMap = {};
    final answers = application['application_answers'] as List?;
    if (answers != null) {
      for (var ans in answers) {
        final q = ans['job_screening_questions']?['question_text']?.toString() ?? '';
        final a = ans['answer_text']?.toString() ?? '';
        if (q.isNotEmpty) {
          answersMap[q] = a;
        }
      }
    }

    // Resume attached to THIS application — resolved join keyed by resume_id,
    // sits at application['resumes'] (singular). NOT profile['resumes'], which
    // is the seeker's whole resume library and may not match what they
    // attached here if they have more than one on file.
    final attachedResume = application['resumes'] as Map<String, dynamic>?;
    final resumeUrl = attachedResume?['file_url']?.toString();

    // Same pattern for the cover letter document attached to THIS
    // application — resolved join keyed by cover_letter_id, at
    // application['cover_letters'] (singular), not profile['cover_letters'].
    final attachedCoverLetter =
        application['cover_letters'] as Map<String, dynamic>?;
    final coverLetterUrl = attachedCoverLetter?['file_url']?.toString() ??
        application['cover_letter_url']?.toString();
    final coverLetterFileName = attachedCoverLetter?['file_name']?.toString() ??
        application['cover_letter_file_name']?.toString();

    // Profile image logic
    final profileImage = users['profile_image']?.toString();

    return Applicant(
      id: application['id']?.toString() ?? '',
      jobId: jobIdStr,
      name: fullName.isEmpty ? 'Unknown Applicant' : fullName,
      initials: initials,
      role: profile['headline']?.toString() ?? 'Applicant',
      targetJobTitle: 'Target Job', // Will be overridden in the provider with actual job title
      status: ((application['stage'] ?? application['status'])?.toString().toLowerCase() == 'pending') ? 'Applied' : ((application['stage'] ?? application['status'])?.toString() ?? 'Applied'),
      appliedAt: DateTime.tryParse(application['applied_at']?.toString() ?? '') ?? DateTime.now(),
      email: users['email']?.toString() ?? '',
      phone: '${users['phone_code'] ?? ''}${users['phone'] ?? ''}',
      location: locationStr,
      coverLetter: _stripHtml(application['cover_letter']?.toString()),
      coverLetterUrl: coverLetterUrl,
      coverLetterFileName: coverLetterFileName,
      about: _stripHtml(profile['summary']?.toString()),
      experienceYears: (profile['experience_years']?.toString().isNotEmpty == true) ? '${profile['experience_years']} Years' : '',
      expectedSalary: expectedSalary,
      availability: profile['availability']?.toString() ?? '',
      skills: skillsList,
      workExperience: workExp,
      education: edu,
      screeningAnswers: answersMap,
      hasMessaged: application['conversation'] != null,
      avatarUrl: profileImage,
      resumeUrl: resumeUrl,
      seekerProfileId: profile['id']?.toString(),
      seekerUserId: profile['user_id']?.toString(),
    );
  }
}
