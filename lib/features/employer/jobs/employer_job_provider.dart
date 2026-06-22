import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/job.dart';
import '../../../core/models/company.dart';

final demoEmployerJobsProvider =
    StateNotifierProvider<DemoEmployerJobsNotifier, List<Job>>((ref) {
      return DemoEmployerJobsNotifier();
    });

class DemoEmployerJobsNotifier extends StateNotifier<List<Job>> {
  DemoEmployerJobsNotifier()
    : super([
        Job(
          id: 1,
          company: Company(
            id: 1,
            name: 'TechCorp Solutions',
            location: 'San Francisco, CA',
          ),
          title: 'Software Engineer',
          description: 'Full stack development role',
          category: 'Engineering',
          employmentType: 'Full-Time',
          workplaceType: 'Remote',
          location: 'San Francisco, USA',
          salaryMin: '\$120,000',
          salaryMax: '\$160,000',
          status: JobStatus.active,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          closesAt: DateTime.now().add(const Duration(days: 28)),
          applicantCount: 524,
          viewCount: 1205,
          experienceLevel: 'Mid-Level',
        ),
        Job(
          id: 2,
          company: Company(
            id: 2,
            name: 'Global Innovations',
            location: 'New York, NY',
          ),
          title: 'Product Manager',
          description: 'Lead cross-functional teams',
          category: 'Product Management',
          employmentType: 'Part-Time',
          workplaceType: 'Hybrid',
          location: 'New York, USA',
          salaryMin: '\$90,000',
          salaryMax: '\$130,000',
          status: JobStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          closesAt: DateTime.now().add(const Duration(days: 15)),
          applicantCount: 842,
          viewCount: 3021,
          experienceLevel: 'Senior',
        ),
        Job(
          id: 3,
          company: Company(id: 3, name: 'Design Co', location: 'London, UK'),
          title: 'UX/UI Designer',
          description: 'Create beautiful user experiences',
          category: 'Design',
          employmentType: 'Contract',
          workplaceType: 'On-site',
          location: 'London, UK',
          salaryMin: '\$80,000',
          salaryMax: '\$110,000',
          status: JobStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 6)),
          closesAt: DateTime.now().add(const Duration(days: 20)),
          applicantCount: 312,
          viewCount: 890,
          experienceLevel: 'Mid-Level',
        ),
        Job(
          id: 4,
          company: Company(id: 4, name: 'Startup Inc', location: 'Austin, TX'),
          title: 'Marketing Intern',
          description: 'Assist with digital marketing',
          category: 'Marketing',
          employmentType: 'Internship',
          workplaceType: 'Remote',
          location: 'Austin, TX',
          salaryMin: '\$30,000',
          salaryMax: '\$45,000',
          status: JobStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
          closesAt: DateTime.now().add(const Duration(days: 30)),
          applicantCount: 150,
          viewCount: 450,
          experienceLevel: 'Entry Level',
        ),
        Job(
          id: 5,
          company: Company(
            id: 5,
            name: 'Data Insights',
            location: 'Chicago, IL',
          ),
          title: 'Temporary Data Analyst',
          description: 'Analyze data for a short-term project',
          category: 'Data Science',
          employmentType: 'Temporary',
          workplaceType: 'Hybrid',
          location: 'Chicago, IL',
          salaryMin: '\$60,000',
          salaryMax: '\$80,000',
          status: JobStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          closesAt: DateTime.now().add(const Duration(days: 25)),
          applicantCount: 900,
          viewCount: 4000,
          experienceLevel: 'Junior',
        ),
        Job(
          id: 6,
          company: Company(
            id: 1,
            name: 'TechCorp Solutions',
            location: 'San Francisco, CA',
          ),
          title: 'Backend Engineer',
          description: 'Node.js and MongoDB',
          category: 'Engineering',
          employmentType: 'Full-Time',
          workplaceType: 'On-site',
          location: 'San Francisco, CA',
          salaryMin: '\$140,000',
          salaryMax: '\$180,000',
          status: JobStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 28)),
          closesAt: DateTime.now().add(const Duration(days: 10)),
          applicantCount: 210,
          viewCount: 650,
          experienceLevel: 'Senior',
        ),
      ]);

  Job addFromForm(Map<String, dynamic> data) {
    final job = Job(
      id: DateTime.now().millisecondsSinceEpoch,
      title: data['title'] as String,
      description: data['description'] as String,
      category: data['category'] as String?,
      employmentType: data['employment_type'] as String? ?? 'full_time',
      workplaceType: data['workplace_type'] as String? ?? 'onsite',
      location: data['city'] as String?,
      salaryMin: data['salary_min'] as String?,
      salaryMax: data['salary_max'] as String?,
      responsibilities: data['responsibilities'] as String?,
      requiredSkills: data['required_skills'] as String?,
      preferredSkills: (data['preferred_skills'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      benefits: (data['benefits'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      education: data['education'] as String?,
      openings: data['openings']?.toString(),
      applyVia: data['apply_via'] as String?,
      resumeRequirement: data['resume_requirement'] as String?,
      coverLetterRequirement: data['cover_letter_requirement'] as String?,
      experienceLevel: data['experience_level'] as String?,
      languages: (data['languages'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      certifications: (data['certifications'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      ageMin: data['age_min']?.toString(),
      ageMax: data['age_max']?.toString(),
      screeningQuestions: (data['screening_questions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      status: JobStatus.pending,
      createdAt: DateTime.now(),
      closesAt: DateTime.now().add(const Duration(days: 30)),
      applicantCount: 524, // Added for testing applicants
    );
    state = [job, ...state];
    return job;
  }

  void updateFromForm(int id, Map<String, dynamic> data) {
    state = [
      for (final job in state)
        if (job.id == id)
          job.copyWith(
            title: data['title'] as String?,
            description: data['description'] as String?,
            category: data['category'] as String?,
            employmentType: data['employment_type'] as String?,
            workplaceType: data['workplace_type'] as String?,
            location: data['city'] as String?,
            salaryMin: data['salary_min'] as String?,
            salaryMax: data['salary_max'] as String?,
            responsibilities: data['responsibilities'] as String?,
            requiredSkills: data['required_skills'] as String?,
            preferredSkills: (data['preferred_skills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList(),
            benefits: (data['benefits'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList(),
            education: data['education'] as String?,
            openings: data['openings']?.toString(),
            applyVia: data['apply_via'] as String?,
            resumeRequirement: data['resume_requirement'] as String?,
            coverLetterRequirement: data['cover_letter_requirement'] as String?,
            experienceLevel: data['experience_level'] as String?,
            languages: (data['languages'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList(),
            certifications: (data['certifications'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList(),
            ageMin: data['age_min']?.toString(),
            ageMax: data['age_max']?.toString(),
            screeningQuestions: (data['screening_questions'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList(),
          )
        else
          job,
    ];
  }

  void updateStatus(int id, JobStatus status) {
    state = [
      for (final job in state)
        if (job.id == id) job.copyWith(status: status) else job,
    ];
  }

  void deleteJob(int id) {
    state = state.where((job) => job.id != id).toList();
  }
}

final employerJobsProvider = FutureProvider.family<List<Job>, String?>((
  ref,
  status,
) async {
  final jobs = ref.watch(demoEmployerJobsProvider);
  if (status == null) return jobs;
  return jobs.where((job) => job.status.name == status).toList();
});

final employerJobDetailProvider = FutureProvider.family<Job, int>((
  ref,
  id,
) async {
  final jobs = ref.watch(demoEmployerJobsProvider);
  return jobs.firstWhere((job) => job.id == id);
});
