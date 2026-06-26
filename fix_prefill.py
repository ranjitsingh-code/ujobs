import re

with open('lib/features/employer/jobs/post_job_screen.dart', 'r') as f:
    text = f.read()

target = """              PostJobState(
                title: job.title,
                description: job.description,
                city: job.location ?? '',
                employmentType: job.employmentType,
                workplaceType: job.workplaceType,
                salaryMin: job.salaryMin ?? '',
                salaryMax: job.salaryMax ?? '',
              ),"""

replacement = """              PostJobState(
                title: job.title,
                description: job.description,
                category: job.category ?? '',
                openings: job.openings ?? '1',
                employmentType: job.employmentType,
                workplaceType: job.workplaceType,
                city: job.location ?? '',
                salaryMin: job.salaryMin ?? '',
                salaryMax: job.salaryMax ?? '',
                currency: job.salaryCurrency ?? 'GBP',
                salaryPeriod: job.salaryPeriod ?? 'monthly',
                experience: job.experienceLevel ?? '',
                requirements: job.requiredSkills ?? '',
                responsibilities: job.responsibilities ?? '',
                education: job.education ?? '',
                preferredSkills: job.preferredSkills ?? [],
                languages: job.languages ?? [],
                certifications: job.certifications ?? [],
                benefits: job.benefits ?? [],
                applyVia: job.applyVia ?? 'internal',
                resumeRequirement: job.resumeRequirement ?? 'required',
                coverLetterRequirement: job.coverLetterRequirement ?? 'optional',
                screeningQuestions: (job.screeningQuestions ?? []).map((q) => ScreeningQuestion(
                  text: q['question_text'] ?? q['text'] ?? q['question'] ?? '',
                  isRequired: q['is_required'] ?? true,
                )).toList(),
              ),"""

if target in text:
    text = text.replace(target, replacement)
    with open('lib/features/employer/jobs/post_job_screen.dart', 'w') as f:
        f.write(text)
    print("Success")
else:
    print("Target not found")
