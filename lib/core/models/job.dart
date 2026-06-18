import 'company.dart';

enum JobStatus { active, pending, draft, closed }

class Job {
  final int id;
  final String title;
  final String description;
  final String? category;
  final String employmentType; // e.g., full_time, part_time
  final String workplaceType; // e.g., remote, onsite, hybrid
  final String? location;
  final String? salaryMin;
  final String? salaryMax;
  final String? experienceLevel;
  final JobStatus status;
  final Company? company;
  final DateTime? createdAt;
  final bool isSaved;

  Job({
    required this.id,
    required this.title,
    required this.description,
    this.category,
    required this.employmentType,
    required this.workplaceType,
    this.location,
    this.salaryMin,
    this.salaryMax,
    this.experienceLevel,
    this.status = JobStatus.pending,
    this.company,
    this.createdAt,
    this.isSaved = false,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String?,
      employmentType: json['employment_type'] as String,
      workplaceType: json['workplace_type'] as String,
      location: json['location'] as String?,
      salaryMin: json['salary_min']?.toString(),
      salaryMax: json['salary_max']?.toString(),
      experienceLevel: json['experience_level'] as String?,
      status: _parseStatus(json['status'] as String?),
      company: json['company'] != null ? Company.fromJson(json['company']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      isSaved: json['is_saved'] ?? false,
    );
  }

  static JobStatus _parseStatus(String? status) {
    switch (status) {
      case 'active': return JobStatus.active;
      case 'pending': return JobStatus.pending;
      case 'draft': return JobStatus.draft;
      case 'closed': return JobStatus.closed;
      default: return JobStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'employment_type': employmentType,
    'workplace_type': workplaceType,
    'location': location,
    'salary_min': salaryMin,
    'salary_max': salaryMax,
    'experience_level': experienceLevel,
    'status': status.name,
    'company': company?.toJson(),
    'created_at': createdAt?.toIso8601String(),
  };
}
