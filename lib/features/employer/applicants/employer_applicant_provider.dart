import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/applicant.dart';

final employerApplicantsProvider =
    StateNotifierProvider<EmployerApplicantsNotifier, List<Applicant>>((ref) {
      return EmployerApplicantsNotifier();
    });

class EmployerApplicantsNotifier extends StateNotifier<List<Applicant>> {
  EmployerApplicantsNotifier() : super(_demoApplicants);

  void updateStatus(String applicantId, String newStatus) {
    state = state.map((applicant) {
      if (applicant.id == applicantId) {
        return applicant.copyWith(status: newStatus);
      }
      return applicant;
    }).toList();
  }

  void markAsMessaged(String applicantId) {
    state = state.map((applicant) {
      if (applicant.id == applicantId) {
        return applicant.copyWith(hasMessaged: true);
      }
      return applicant;
    }).toList();
  }
}

final _demoApplicants = [
  Applicant(
    id: 'a1',
    avatarUrl: 'https://i.pravatar.cc/150?u=alice',
    name: 'Alice Johnson',
    initials: 'AJ',
    role: 'Software Engineer',
    targetJobTitle: 'Software Engineer',
    status: 'hired',
    appliedAt: DateTime.now().subtract(const Duration(days: 20)),
    email: 'alice@example.com',
    phone: '+1 (555) 123-4567',
    hasMessaged: true,
    location: 'San Francisco, CA',
    experienceYears: '5 Years',
    expectedSalary: r'$140,000',
    availability: '2 Weeks Notice',
    about:
        'Passionate software engineer with 5 years of experience building scalable web and mobile applications using Flutter and Node.js. Strong focus on clean code and performance optimization.',
    coverLetter:
        'Dear Hiring Manager,\n\nI am writing to express my strong interest in the Software Engineer position. With my extensive background in Flutter and Dart, I have successfully delivered multiple cross-platform applications that reached thousands of users.\n\nIn my previous role at TechCorp, I led the mobile development team and improved application performance by 40%. I am excited about the opportunity to bring my skills to your team and contribute to your innovative products.\n\nThank you for your consideration.\n\nSincerely,\nAlice Johnson',
    skills: ['Flutter', 'Dart', 'Firebase', 'Node.js', 'React'],
    screeningAnswers: {
      'Do you have 3+ years of experience in Flutter?':
          'Yes, I have been working with Flutter since 2019.',
      'Are you comfortable working in a fully remote environment?':
          'Absolutely. I have worked remotely for the past 3 years.',
    },
    workExperience: [
      {
        'title': 'Senior Mobile Developer',
        'company': 'TechCorp Solutions',
        'location': 'Remote',
        'period': 'Jan 2022 - Present',
        'description':
            'Lead developer for the flagship mobile app. Managed a team of 4 developers and implemented CI/CD pipelines.',
      },
      {
        'title': 'Flutter Developer',
        'company': 'AppWorks Inc',
        'location': 'San Francisco, CA',
        'period': 'Mar 2019 - Dec 2021',
        'description':
            'Developed cross-platform mobile apps for various clients. Integrated REST APIs and third-party SDKs.',
      },
    ],
    education: [
      {
        'school': 'University of California, Berkeley',
        'degree': 'Bachelor of Science',
        'field': 'Computer Science',
        'grade': '3.8 GPA',
      },
    ],
  ),
  Applicant(
    id: 'a2',
    avatarUrl: 'https://i.pravatar.cc/150?u=bob',
    name: 'Bob Smith',
    initials: 'BS',
    role: 'Software Engineer',
    targetJobTitle: 'Software Engineer',
    status: 'shortlisted',
    appliedAt: DateTime.now().subtract(const Duration(days: 3)),
    email: 'bob@example.com',
    phone: '+1 (555) 987-6543',
    hasMessaged: true,
    location: 'Austin, TX',
    experienceYears: '3 Years',
    expectedSalary: r'$120,000',
    availability: 'Immediate',
    about:
        'Dedicated developer specializing in front-end technologies and cross-platform mobile development.',
    coverLetter:
        'Hi Team,\n\nI would love to join as a Software Engineer. I have built several personal projects in Flutter and have 3 years of professional experience with React Native. I am quick to learn and eager to transition fully into Flutter development.',
    skills: ['React Native', 'JavaScript', 'Flutter (Basic)', 'Git'],
    screeningAnswers: {
      'Do you have 3+ years of experience in Flutter?':
          'I have 3 years of mobile experience, primarily in React Native, with 6 months in Flutter.',
      'Are you comfortable working in a fully remote environment?':
          'Yes, I prefer remote work.',
    },
    workExperience: [
      {
        'title': 'Mobile Developer',
        'company': 'Digital Frontiers',
        'location': 'Austin, TX',
        'period': 'Jun 2021 - Present',
        'description':
            'Built and maintained multiple React Native applications.',
      },
    ],
    education: [
      {
        'school': 'University of Texas',
        'degree': 'Bachelor of Arts',
        'field': 'Software Engineering',
        'grade': '3.6 GPA',
      },
    ],
  ),
  Applicant(
    id: 'a3',
    avatarUrl: 'https://i.pravatar.cc/150?u=charlie',
    name: 'Charlie Brown',
    initials: 'CB',
    role: 'Website Developer',
    targetJobTitle: 'Website Developer',
    status: 'interviewing',
    appliedAt: DateTime.now().subtract(const Duration(days: 10)),
    email: 'charlie@example.com',
    phone: '+1 (555) 456-7890',
    hasMessaged: true,
    location: 'New York, NY',
    experienceYears: '6 Years',
    expectedSalary: r'$110,000',
    availability: '1 Month',
    about:
        'Creative web developer with a strong eye for design and expertise in modern JavaScript frameworks.',
    coverLetter:
        'To the Hiring Team,\n\nI am applying for the Website Developer position. With over 6 years of experience building responsive, accessible, and performant web applications using React and Vue.js, I am confident I can make an immediate impact.',
    skills: ['React', 'Vue.js', 'TypeScript', 'CSS/SASS', 'Figma'],
    screeningAnswers: {
      'Can you share a link to your portfolio?': 'https://charliebrown.dev',
    },
    workExperience: [
      {
        'title': 'Frontend Engineer',
        'company': 'WebStudio NY',
        'location': 'New York, NY',
        'period': 'Aug 2018 - Present',
        'description':
            'Developed high-traffic e-commerce websites and internal dashboards.',
      },
    ],
    education: [
      {
        'school': 'New York University',
        'degree': 'Bachelor of Fine Arts',
        'field': 'Interactive Media Arts',
        'grade': '3.9 GPA',
      },
    ],
  ),
  Applicant(
    id: 'a4',
    avatarUrl: 'https://i.pravatar.cc/150?u=diana',
    name: 'Diana Prince',
    initials: 'DP',
    role: 'Mobile Application Developer',
    targetJobTitle: 'Mobile Application Developer',
    status: 'applied',
    appliedAt: DateTime.now().subtract(const Duration(hours: 5)),
    email: 'diana@example.com',
    phone: '+1 (555) 321-0987',
    hasMessaged: false,
    location: 'London, UK',
    experienceYears: '4 Years',
    expectedSalary: '£75,000',
    availability: 'Immediate',
    skills: ['Swift', 'Objective-C', 'Flutter', 'Firebase'],
    about:
        'Experienced iOS developer expanding into cross-platform development with Flutter.',
    workExperience: [
      {
        'title': 'iOS Developer',
        'company': 'British Tech',
        'location': 'London',
        'period': '2020 - 2024',
        'description': 'Developed native iOS applications.',
      },
    ],
    education: [
      {
        'school': 'Oxford University',
        'degree': 'BSc',
        'field': 'Computer Science',
        'grade': 'First Class',
      },
    ],
  ),
  Applicant(
    id: 'a5',
    avatarUrl: 'https://i.pravatar.cc/150?u=evan',
    name: 'Evan Wright',
    initials: 'EW',
    role: 'SEO Expert',
    targetJobTitle: 'SEO Expert',
    status: 'offered',
    appliedAt: DateTime.now().subtract(const Duration(days: 14)),
    email: 'evan@example.com',
    phone: '+1 (555) 654-3210',
    hasMessaged: true,
    location: 'Remote',
    experienceYears: '7 Years',
    expectedSalary: r'$95,000',
    availability: '2 Weeks',
    skills: ['SEO', 'Google Analytics', 'Ahrefs', 'Content Strategy'],
    about:
        'Results-driven SEO specialist who increased organic traffic by 300% in my last role.',
    screeningAnswers: {
      'What is your most successful SEO campaign to date?':
          'I led a campaign for an e-commerce brand that resulted in a 300% increase in organic traffic over 6 months by targeting long-tail keywords and optimizing site speed.',
    },
    workExperience: [
      {
        'title': 'SEO Manager',
        'company': 'GrowthHackers',
        'location': 'Remote',
        'period': '2019 - Present',
        'description': 'Managed SEO strategy for 10+ enterprise clients.',
      },
    ],
    education: [
      {
        'school': 'Marketing Institute',
        'degree': 'BA',
        'field': 'Marketing',
        'grade': 'Pass',
      },
    ],
  ),
  Applicant(
    id: 'a6',
    name: 'Fiona Gallagher',
    initials: 'FG',
    role: 'Data Analyst',
    targetJobTitle: 'Data Analyst',
    status: 'rejected',
    appliedAt: DateTime.now().subtract(const Duration(days: 30)),
    email: 'fiona@example.com',
    phone: '+1 (555) 111-2222',
    hasMessaged: false,
    location: 'Berlin, Germany',
    experienceYears: '2 Years',
    expectedSalary: '€70,000',
    availability: '1 Month',
    skills: ['SQL', 'Python', 'Tableau', 'Excel'],
    about: 'Junior data analyst with a strong mathematical background.',
    workExperience: [
      {
        'title': 'Data Intern',
        'company': 'DataCorp',
        'location': 'Berlin',
        'period': '2022 - 2024',
        'description': 'Assisted in data cleaning and report generation.',
      },
    ],
    education: [
      {
        'school': 'Technical University Berlin',
        'degree': 'BSc',
        'field': 'Mathematics',
        'grade': '1.5',
      },
    ],
  ),
  Applicant(
    id: 'a7',
    name: 'George Mason',
    initials: 'GM',
    role: 'Cybersecurity Expert',
    targetJobTitle: 'Cybersecurity Expert',
    status: 'shortlisted',
    appliedAt: DateTime.now().subtract(const Duration(days: 1)),
    email: 'george@example.com',
    phone: '+1 (555) 333-4444',
    hasMessaged: false,
    location: 'Toronto, Canada',
    experienceYears: '8 Years',
    expectedSalary: 'CAD 130,000',
    availability: 'Immediate',
    skills: ['Network Security', 'Penetration Testing', 'CISSP', 'Python'],
    about:
        'Certified Information Systems Security Professional with 8 years of experience in enterprise environments.',
    workExperience: [
      {
        'title': 'Security Consultant',
        'company': 'SecureNet',
        'location': 'Toronto',
        'period': '2016 - Present',
        'description':
            'Conducted penetration tests and security audits for financial institutions.',
      },
    ],
    education: [
      {
        'school': 'University of Toronto',
        'degree': 'MSc',
        'field': 'Cybersecurity',
        'grade': 'A',
      },
    ],
  ),
  Applicant(
    id: 'a8',
    name: 'Hannah Abbott',
    initials: 'HA',
    role: 'Digital Marketer',
    targetJobTitle: 'Digital Marketer',
    status: 'applied',
    appliedAt: DateTime.now().subtract(const Duration(hours: 2)),
    email: 'hannah@example.com',
    phone: '+1 (555) 555-6666',
    hasMessaged: false,
    location: 'Remote',
    experienceYears: '1 Year',
    expectedSalary: r'$50,000',
    availability: 'Immediate',
    skills: ['Social Media', 'Content Creation', 'Canva'],
    about: 'Enthusiastic marketer looking for an entry-level opportunity.',
    workExperience: [],
    education: [
      {
        'school': 'State University',
        'degree': 'BA',
        'field': 'Communications',
        'grade': '3.2 GPA',
      },
    ],
  ),
];
