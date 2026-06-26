import 'dart:convert';
import 'lib/core/models/job.dart';

void main() {
  final jsonString = """
  {
                 "id": "30",
                 "company_id": "15",
                 "posted_by_user_id": "30",
                 "category_id": "1",
                 "category_other": null,
                 "title": "Software Engineer",
                 "slug": "software-engineer-1782319403421",
                 "description": "<p>We are looking for experienced developers</p>",
                 "responsibilities": "<ul><li><p>Develop and enhance</p></li></ul>",
                 "requirements": "<ul><li><p>2+ years of experience in the backend.</p></li></ul>",
                 "employment_type": "contract",
                 "workplace_type": "hybrid",
                 "city": "London",
                 "country": "GB",
                 "salary_min": 3600,
                 "salary_max": 4500,
                 "salary_currency": "GBP",
                 "salary_period": "monthly",
                 "experience_min_years": 5,
                 "min_education": "masters",
                 "preferred_skills": "React, Node.js, AWS, OpenAI API, REST API",
                 "languages_required": "English",
                 "certifications_required": "N/A",
                 "age_min": null,
                 "age_max": null,
                 "benefits": "[\\"Flexible Schedule\\",\\"Work From Home\\"]",
                 "application_method": "internal",
                 "application_email": null,
                 "application_url": null,
                 "resume_required": "required",
                 "cover_letter_policy": "optional",
                 "auto_reject_after_deadline": false,
                 "vacancies": 1,
                 "status": "active",
                 "is_featured": false,
                 "featured_until": null,
                 "application_deadline": "2026-07-03T00:00:00.000Z",
                 "views_count": 0,
                 "rejection_reason": null,
                 "flagged_words": null,
                 "approved_by_user_id": "1",
                 "approved_at": "2026-06-24T17:31:08.000Z",
                 "published_at": "2026-06-24T17:31:08.000Z",
                 "created_at": "2026-06-24T16:43:23.000Z",
                 "updated_at": "2026-06-24T17:31:08.000Z",
                 "deleted_at": null,
                 "categories": {"id": 1, "name": "Technology"},
                 "_count": {"applications": 0},
                 "job_screening_questions": [
                    {
                         "id": "26",
                         "job_id": "30",
                         "question_text": "do you know react?",
                         "order_index": 0,
                         "is_required": true,
                         "created_at": "2026-06-24T16:43:23.000Z"
                    },
                    {
                         "id": "27",
                         "job_id": "30",
                         "question_text": "do you know node js?",
                         "order_index": 1,
                         "is_required": true,
                         "created_at": "2026-06-24T16:43:23.000Z"
                    }
                 ]
  }
  """;

  final json = jsonDecode(jsonString);
  final job = Job.fromJson(json);

  print('ID: ${job.id}');
  print('Title: ${job.title}');
  print('Category: ${job.category}');
  print('Employment Type: ${job.employmentType}');
  print('Workplace: ${job.workplaceType}');
  print('Salary: ${job.salaryMin} - ${job.salaryMax} ${job.salaryCurrency} / ${job.salaryPeriod}');
  print('Experience: ${job.experienceLevel}');
  print('Education: ${job.education}');
  print('Required Skills: ${job.requiredSkills}');
  print('Preferred Skills: ${job.preferredSkills}');
  print('Languages: ${job.languages}');
  print('Certifications: ${job.certifications}');
  print('Benefits: ${job.benefits}');
  print('Apply Via: ${job.applyVia}');
  print('Resume Requirement: ${job.resumeRequirement}');
  print('Cover Letter Requirement: ${job.coverLetterRequirement}');
  print('Openings: ${job.openings}');
  print('Screening Questions Count: ${job.screeningQuestions?.length}');
  print('Q1: ${job.screeningQuestions?[0]['question_text']}');
}
