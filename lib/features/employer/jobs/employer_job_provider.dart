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
            name: 'Softmaya',
            location: 'London, GB',
            industry: 'Technology',
            size: '11-50 employees',
            isVerified: true,
            founded: '2026',
            website: 'https://softmaya.com',
            linkedinUrl: 'https://linkedin.com/company/softmaya',
            facebookUrl: 'https://facebook.com/softmaya',
            description:
                'SoftMaya is a leading software development company specializing in digital banking, eMoney solutions, payment gateways, CRM systems, and custom software development. We help businesses accelerate their digital transformation through secure, scalable, and innovative technology solutions. Our team is dedicated to building high-performance web, mobile, and enterprise applications that simplify operations, improve customer experiences, and drive business growth. With expertise in fintech, payment processing, and business automation, SoftMaya delivers reliable solutions tailored to the unique needs of each client. We focus on innovation, security, and quality, ensuring that every product we develop meets the highest industry standards. From digital banking platforms and payment systems to custom business applications, SoftMaya empowers organizations to succeed in an increasingly digital world. Our mission is to provide cutting-edge technology solutions that enable businesses to grow faster, operate more efficiently, and deliver exceptional value to their customers',
          ),
          title: 'Software Engineer',
          description:
              'Zelis is modernizing the healthcare financial experience in the United States (U.S.) across payers, providers, and healthcare consumers. We serve more than 750 payers, including the top five national health plans, regional health plans, TPAs and millions of healthcare providers and consumers across our platform of solutions. Zelis sees across the system to identify, optimize, and solve problems holistically with technology built by healthcare experts – driving real, measurable results for clients.\n\nAt Zelis, AI is woven into the fabric of how we work. Every associate is expected - and empowered - to partner with AI to challenge the status quo, accelerate innovation, and amplify their impact. This is a place for builders with a growth mindset who act with agility, embrace change, and use modern technology to shape smarter solutions, exceptional experiences, and the future of our industry for our clients, customers, and our culture.',
          category: 'Software Development',
          employmentType: 'Full-time',
          workplaceType: 'On-site',
          location: 'London, GB',
          salaryMin: '£5k',
          salaryMax: '£8k/yr',
          status: JobStatus.active,
          createdAt: DateTime.now(),
          closesAt: DateTime(2026, 10, 24),
          applicantCount: 524,
          viewCount: 1205,
          openings: '1',
          experienceLevel: '',
          responsibilities:
              'Design, develop, and maintain scalable web applications using .NET Core, Angular, and React.\n\nImplement and manage Azure Functions, Key Vaults, and Blob/Table Storage for secure and efficient cloud operations.\n\nDevelop and manage Azure API Management (APIM) policies and configurations.\n\nApply OOP principles and design patterns to build robust, maintainable, and reusable code.\n\nCollaborate with cross-functional teams to define, design, and ship new features.\n\nEnsure the performance, quality, and responsiveness of applications.\n\nParticipate in code reviews and provide constructive feedback.\n\nTroubleshoot and resolve technical issues across the full stack.',
          requiredSkills:
              'Strong experience in .NET Core / .NET 6+ development.\n\nProficiency in Angular and React frameworks.\n\nHands-on experience with Azure Functions, Key Vaults, and Azure Storage.\n\nSolid understanding of Azure API Management (APIM) and policy creation.\n\nDeep knowledge of OOP concepts and design patterns.\n\nExperience with RESTful APIs, microservices architecture, and CI/CD pipelines.\n\nFamiliarity with Git, DevOps practices, and agile methodologies.\n\nExcellent problem-solving and communication skills.',
          benefits: ['Work From Home', 'Leave Encashment'],
          preferredSkills: ['ASP.NET', 'React'],
          languages: ['English'],
          certifications: [],
          screeningQuestions: [
            {'question': 'What is your notifice period?'},
            {'question': 'when you available for interview?'},
            {'question': 'Do you have php experience?'},
          ],
        ),
        Job(
          id: 2,
          company: Company(
            id: 2,
            name: 'Global Innovations',
            location: 'New York, NY',
            industry: 'Technology',
            size: '50-200 employees',
            isVerified: true,
            founded: '2015',
            website: 'https://example.com',
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
          company: Company(
            id: 3,
            name: 'Design Co',
            location: 'London, UK',
            industry: 'Technology',
            size: '50-200 employees',
            isVerified: true,
            founded: '2015',
            website: 'https://example.com',
          ),
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
          company: Company(
            id: 4,
            name: 'Startup Inc',
            location: 'Austin, TX',
            industry: 'Technology',
            size: '50-200 employees',
            isVerified: true,
            founded: '2015',
            website: 'https://example.com',
          ),
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
            industry: 'Technology',
            size: '50-200 employees',
            isVerified: true,
            founded: '2015',
            website: 'https://example.com',
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
            industry: 'Technology',
            size: '50-200 employees',
            isVerified: true,
            founded: '2015',
            website: 'https://example.com',
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
