import re

with open('lib/features/employer/applicants/employer_applicant_service.dart', 'r') as f:
    text = f.read()

target = """    return Applicant(
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
    );"""

replacement = """    return Applicant(
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
    );"""

text = text.replace(target, replacement)

with open('lib/features/employer/applicants/employer_applicant_service.dart', 'w') as f:
    f.write(text)

