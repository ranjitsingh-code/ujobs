import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/job.dart';

final demoEmployerJobsProvider =
    StateNotifierProvider<DemoEmployerJobsNotifier, List<Job>>((ref) {
      return DemoEmployerJobsNotifier();
    });

class DemoEmployerJobsNotifier extends StateNotifier<List<Job>> {
  DemoEmployerJobsNotifier()
    : super([
        Job(
          id: 1,
          title: 'Software Engineer',
          description: '[{"insert":"We are looking for a skilled Software Engineer to join our dynamic team. You will be responsible for building high-performance, scalable applications. Your daily tasks will include writing clean, maintainable code, reviewing pull requests, and collaborating with cross-functional teams.\\n"}]',
          category: 'Engineering',
          employmentType: 'Full-Time',
          workplaceType: 'Remote',
          location: 'San Francisco, USA',
          salaryMin: '\$120,000',
          salaryMax: '\$160,000',
          status: JobStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          closesAt: DateTime.now().add(const Duration(days: 28)),
          applicantCount: 5,
          viewCount: 120,
          responsibilities: '• Develop and maintain scalable software solutions\n• Collaborate with cross-functional teams\n• Write clean, robust, and well-documented code\n• Conduct code reviews and provide feedback\n• Troubleshoot, debug and optimize applications',
          requiredSkills: '• 3+ years of experience in Software Development\n• Strong proficiency in Dart and Flutter\n• Experience with RESTful APIs\n• Familiarity with Git and CI/CD pipelines',
          preferredSkills: ['Node.js', 'AWS', 'Docker', 'Agile Methodologies'],
          benefits: ['Health Insurance', 'Remote Work', 'Gym Membership', '401(k) Matching', 'Unlimited PTO'],
          education: 'Bachelor\'s Degree in Computer Science or related field',
          openings: '3',
          applyVia: 'platform',
          resumeRequirement: 'required',
          coverLetterRequirement: 'optional',
          experienceLevel: 'Mid-Level',
          languages: ['English'],
          certifications: ['AWS Certified Developer'],
          ageMin: '22',
          ageMax: '45',
          screeningQuestions: [
            {'text': 'Do you have 3+ years of experience in Flutter?', 'is_required': true},
            {'text': 'Are you comfortable working in a fully remote environment?', 'is_required': true},
          ],
        ),
        Job(
          id: 2,
          title: 'Website Developer',
          description: '[{"insert":"Looking for an experienced Website Developer to design, build, and maintain our company websites. You should be proficient in modern web frameworks and have a strong eye for UI/UX design. You will work closely with the marketing team to ensure optimal website performance and SEO.\\n"}]',
          category: 'Engineering',
          employmentType: 'Full-Time',
          workplaceType: 'Hybrid',
          location: 'New York, USA',
          salaryMin: '\$90,000',
          salaryMax: '\$130,000',
          status: JobStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          closesAt: DateTime.now().add(const Duration(days: 15)),
          applicantCount: 2,
          viewCount: 85,
          responsibilities: '• Build scalable, responsive web applications\n• Optimize websites for maximum speed and scalability\n• Implement SEO best practices\n• Work with the design team to bridge the gap between graphical design and technical implementation',
          requiredSkills: '• 4+ years of web development experience\n• Proficiency in React or Vue.js\n• Strong HTML5, CSS3, and JavaScript skills\n• Experience with responsive and adaptive design',
          preferredSkills: ['Next.js', 'TypeScript', 'Tailwind CSS', 'Figma'],
          benefits: ['Health Insurance', 'Dental & Vision', 'Commuter Benefits', 'Learning Stipend'],
          education: 'Bachelor\'s Degree or equivalent experience',
          openings: '1',
          applyVia: 'platform',
          resumeRequirement: 'required',
          coverLetterRequirement: 'required',
          experienceLevel: 'Senior',
          languages: ['English', 'Spanish'],
          certifications: [],
          screeningQuestions: [
            {'text': 'Can you share a link to your portfolio?', 'is_required': true},
          ],
        ),
        Job(
          id: 3,
          title: 'Mobile Application Developer',
          description: '[{"insert":"Seeking a Mobile Application Developer with Flutter experience to build and maintain both iOS and Android applications. You will be an integral part of our core product team, ensuring that our mobile applications are robust, performant, and user-friendly.\\n"}]',
          category: 'Engineering',
          employmentType: 'Contract',
          workplaceType: 'Remote',
          location: 'London, UK',
          salaryMin: '£60,000',
          salaryMax: '£85,000',
          status: JobStatus.paused,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          closesAt: DateTime.now().add(const Duration(days: 20)),
          applicantCount: 3,
          viewCount: 210,
          responsibilities: '• Design and build advanced applications for the iOS and Android platforms\n• Collaborate with cross-functional teams to define, design, and ship new features\n• Work on bug fixing and improving application performance\n• Continuously discover, evaluate, and implement new technologies',
          requiredSkills: '• 2+ years of mobile development experience\n• Experience with Flutter and Dart\n• Understanding of Apple\'s design principles and interface guidelines\n• Familiarity with cloud message APIs and push notifications',
          preferredSkills: ['Swift', 'Kotlin', 'Firebase', 'SQLite'],
          benefits: ['Flexible Hours', 'Equipment Allowance', 'Remote Work Options'],
          education: 'Diploma or Degree in related field',
          openings: '2',
          applyVia: 'platform',
          resumeRequirement: 'required',
          coverLetterRequirement: 'optional',
          experienceLevel: 'Junior-Mid',
          languages: ['English'],
        ),
        Job(
          id: 4,
          title: 'SEO Expert',
          description: '[{"insert":"We need an SEO Expert to boost our organic reach and drive massive traffic to our main platforms. You will be conducting keyword research, competitive analysis, and executing full-scale SEO strategies.\\n"}]',
          category: 'Marketing',
          employmentType: 'Full-Time',
          workplaceType: 'Remote',
          location: 'Remote',
          salaryMin: '\$70,000',
          salaryMax: '\$100,000',
          status: JobStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          closesAt: DateTime.now().add(const Duration(days: 30)),
          applicantCount: 1,
          viewCount: 45,
          responsibilities: '• Conduct keyword research using various tools (like Ahrefs, SEMrush)\n• Optimize website content, landing pages, and paid search copy\n• Direct off-page optimization projects (e.g. link-building)\n• Monitor and evaluate search results and search performance across major search channels',
          requiredSkills: '• Proven experience as an SEO Expert or similar role\n• Familiarity with standard and current SEO practices\n• Knowledge of HTML/CSS\n• Experience with SEO reporting',
          preferredSkills: ['Google Analytics', 'Content Marketing', 'Copywriting'],
          benefits: ['Health Insurance', 'Remote Work', 'Performance Bonuses'],
          experienceLevel: 'Mid-Level',
          languages: ['English'],
          screeningQuestions: [
            {'text': 'What is your most successful SEO campaign to date?', 'is_required': true},
          ],
        ),
        Job(
          id: 5,
          title: 'Data Analyst',
          description: '[{"insert":"Join our data team as a Data Analyst. You will be responsible for interpreting data, analyzing results, and providing ongoing reports. You will work closely with management to prioritize business and information needs.\\n"}]',
          category: 'Data Science',
          employmentType: 'Full-Time',
          workplaceType: 'Onsite',
          location: 'Berlin, Germany',
          salaryMin: '€65,000',
          salaryMax: '€90,000',
          status: JobStatus.closed,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          closesAt: DateTime.now().add(const Duration(days: 25)),
          applicantCount: 4,
          viewCount: 150,
          responsibilities: '• Interpret data, analyze results using statistical techniques\n• Develop and implement databases, data collection systems\n• Acquire data from primary or secondary data sources\n• Identify, analyze, and interpret trends or patterns in complex data sets',
          requiredSkills: '• Proven working experience as a Data Analyst\n• Technical expertise regarding data models, database design development\n• Strong knowledge of and experience with reporting packages\n• Knowledge of statistics and experience using statistical packages for analyzing datasets',
          preferredSkills: ['Python', 'R', 'Tableau', 'PowerBI'],
          benefits: ['Relocation Assistance', 'Health Insurance', 'Gym Membership', 'Catered Lunches'],
          education: 'Master\'s Degree preferred',
          openings: '1',
          experienceLevel: 'Senior',
          languages: ['English', 'German'],
        ),
        Job(
          id: 6,
          title: 'Cybersecurity Expert',
          description: '[{"insert":"Protect our infrastructure as a Cybersecurity Expert. You will be analyzing security logs, identifying vulnerabilities, and implementing robust security measures across all our cloud environments.\\n"}]',
          category: 'Security',
          employmentType: 'Full-Time',
          workplaceType: 'Hybrid',
          location: 'Toronto, Canada',
          salaryMin: 'CAD 110,000',
          salaryMax: 'CAD 150,000',
          status: JobStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          closesAt: DateTime.now().add(const Duration(days: 14)),
          applicantCount: 2,
          viewCount: 90,
          responsibilities: '• Monitor computer networks for security issues\n• Investigate security breaches and other cybersecurity incidents\n• Install security measures and operate software to protect systems\n• Document security breaches and assess the damage they cause\n• Work with the IT team to perform tests and uncover network vulnerabilities',
          requiredSkills: '• 5+ years of experience in cybersecurity\n• Proficiency with firewalls, endpoint security, and intrusion detection systems\n• Knowledge of latest cybersecurity trends and hacker tactics\n• Strong analytical and problem-solving skills',
          preferredSkills: ['Ethical Hacking', 'Cloud Security (AWS/Azure)', 'Cryptography'],
          benefits: ['Health Insurance', 'Retirement Plan', 'Continuing Education Stipend'],
          education: 'Bachelor\'s Degree in Cybersecurity or Information Technology',
          certifications: ['CISSP', 'CEH'],
          experienceLevel: 'Senior',
        ),
        Job(
          id: 7,
          title: 'Digital Marketer',
          description: '[{"insert":"Looking for a versatile Digital Marketer to oversee our online marketing strategy. You will be managing social media campaigns, email marketing, and paid advertising.\\n"}]',
          category: 'Marketing',
          employmentType: 'Part-Time',
          workplaceType: 'Remote',
          location: 'Remote',
          salaryMin: '\$40,000',
          salaryMax: '\$60,000',
          status: JobStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
          closesAt: DateTime.now().add(const Duration(days: 10)),
          applicantCount: 5,
          viewCount: 300,
          responsibilities: '• Design and oversee all aspects of our digital marketing department\n• Develop and monitor campaign budgets\n• Plan and manage our social media platforms\n• Prepare accurate reports on our marketing campaign\'s overall performance',
          requiredSkills: '• Proven experience in digital marketing\n• Demonstrable experience leading and managing SEO/SEM, marketing database, email, social media\n• Highly creative with experience in identifying target audiences',
          preferredSkills: ['HubSpot', 'Mailchimp', 'Adobe Creative Suite'],
          benefits: ['Flexible Schedule', 'Remote Work', 'Performance Bonuses'],
          experienceLevel: 'Mid-Level',
          languages: ['English'],
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
      preferredSkills: (data['preferred_skills'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      benefits: (data['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      education: data['education'] as String?,
      openings: data['openings']?.toString(),
      applyVia: data['apply_via'] as String?,
      resumeRequirement: data['resume_requirement'] as String?,
      coverLetterRequirement: data['cover_letter_requirement'] as String?,
      experienceLevel: data['experience_level'] as String?,
      languages: (data['languages'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      certifications: (data['certifications'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      ageMin: data['age_min']?.toString(),
      ageMax: data['age_max']?.toString(),
      screeningQuestions: (data['screening_questions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      status: JobStatus.pending,
      createdAt: DateTime.now(),
      closesAt: DateTime.now().add(const Duration(days: 30)),
      applicantCount: 5, // Added for testing applicants
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
            preferredSkills: (data['preferred_skills'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
            benefits: (data['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
            education: data['education'] as String?,
            openings: data['openings']?.toString(),
            applyVia: data['apply_via'] as String?,
            resumeRequirement: data['resume_requirement'] as String?,
            coverLetterRequirement: data['cover_letter_requirement'] as String?,
            experienceLevel: data['experience_level'] as String?,
            languages: (data['languages'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
            certifications: (data['certifications'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
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
