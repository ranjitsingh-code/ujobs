import 'dart:convert';
import 'lib/core/models/job.dart';

void main() {
  const jsonString = '''
  {
    "id": "30",
    "company_id": "15",
    "posted_by_user_id": "30",
    "category_id": "1",
    "category_other": null,
    "title": "Software Engineer",
    "slug": "software-engineer-1782319403421",
    "description": "<p>We are looking for experienced developers...</p>",
    "responsibilities": "<ul><li>...</li></ul>",
    "requirements": "<ul><li>...</li></ul>",
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
    "benefits": "[\"Flexible Schedule\",\"Work From Home\",\"Flexible Working Hours\",\"Life Insurance\",\"Training & Certifications\",\"Health Insurance\"]",
    "application_method": "internal",
    "application_email": null,
    "application_url": null,
    "resume_required": "required",
    "cover_letter_policy": "optional",
    "auto_reject_after_deadline": false,
    "vacancies": 1,
    "status": "pending",
    "is_featured": false,
    "featured_until": null,
    "application_deadline": "2026-07-03T00:00:00.000Z",
    "views_count": 0,
    "rejection_reason": null,
    "flagged_words": null,
    "approved_by_user_id": null,
    "approved_at": null,
    "published_at": null,
    "created_at": "2026-06-24T16:43:23.000Z",
    "updated_at": "2026-06-24T16:43:23.000Z",
    "deleted_at": null,
    "categories": {"id": 1, "name": "Technology"},
    "_count": {"applications": 0},
    "job_screening_questions": [
      {
        "id": "24",
        "job_id": "29",
        "question_text": "do you know flutter?",
        "order_index": 0,
        "is_required": true,
        "created_at": "2026-06-24T16:36:26.000Z"
      }
    ]
  }
  ''';
  
  try {
    final map = jsonDecode(jsonString);
    final job = Job.fromJson(map);
    print('Successfully parsed job: ${job.title}');
    print('ID: ${job.id}');
    print('Applicants: ${job.applicantCount}');
    print('Benefits length: ${job.benefits?.length}');
    print('Screening questions: ${job.screeningQuestions?.length}');
  } catch (e, st) {
    print('Failed to parse: $e');
    print(st);
  }
}
