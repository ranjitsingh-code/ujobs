import 'dart:convert';
import 'lib/core/models/job.dart';

void main() {
  final jsonString = """
  {
                 "id": "29",
                 "company_id": "15",
                 "posted_by_user_id": "30",
                 "category_id": "1",
                 "category_other": null,
                 "title": "Flutter Developer",
                 "slug": "flutter-developer-1782318986865",
                 "description": "<p>We are looking for a motivated and passionate <strong>Flutter Developer</strong> with 2 to 3 years of hands-on experience to join our growing development team.</p>",
                 "responsibilities": "<ul><li><p><strong>Feature Development:</strong> Build and test new features for our iOS and Android applications.</p></li></ul>",
                 "requirements": "<ul><li><p>2 to 3 year(s)</p></li></ul>",
                 "employment_type": "full_time",
                 "workplace_type": "hybrid",
                 "city": "London",
                 "country": "GB",
                 "salary_min": 2500,
                 "salary_max": 3000,
                 "salary_currency": "GBP",
                 "salary_period": "monthly",
                 "experience_min_years": 4,
                 "min_education": "bachelors",
                 "preferred_skills": "Flutter, dart, IOS APP, Android App",
                 "languages_required": "English",
                 "certifications_required": "N/A",
                 "age_min": null,
                 "age_max": null,
                 "benefits": "[\\"Flexible Schedule\\",\\"Work From Home\\",\\"Health Insurance\\"]",
                 "application_method": "internal",
                 "resume_required": "required",
                 "cover_letter_policy": "optional",
                 "vacancies": 1,
                 "status": "active",
                 "application_deadline": "2026-06-30T00:00:00.000Z",
                 "categories": {"id": 1, "name": "Technology"},
                 "job_screening_questions": [
                    {
                         "id": "24",
                         "question_text": "do you know flutter?",
                         "is_required": true
                    },
                    {
                         "id": "25",
                         "question_text": "do you know dart?",
                         "is_required": true
                    }
                 ]
  }
  """;

  final json = jsonDecode(jsonString);
  final job = Job.fromJson(json);

  print('ID: ' + job.id.toString());
  print('Title: ' + job.title);
  print('Category: ' + job.category.toString());
  print('Employment Type: ' + job.employmentType);
  print('Workplace: ' + job.workplaceType);
  print('Salary: ' + job.salaryMin.toString() + ' - ' + job.salaryMax.toString() + ' ' + job.salaryCurrency.toString() + ' / ' + job.salaryPeriod.toString());
  print('Experience: ' + job.experienceLevel.toString());
  print('Education: ' + job.education.toString());
  print('Required Skills: ' + job.requiredSkills.toString());
  print('Preferred Skills: ' + job.preferredSkills.toString());
  print('Languages: ' + job.languages.toString());
  print('Certifications: ' + job.certifications.toString());
  print('Benefits: ' + job.benefits.toString());
  print('Apply Via: ' + job.applyVia.toString());
  print('Resume Requirement: ' + job.resumeRequirement.toString());
  print('Cover Letter Requirement: ' + job.coverLetterRequirement.toString());
  print('Openings: ' + job.openings.toString());
  print('Screening Questions Count: ' + job.screeningQuestions?.length.toString());
}
