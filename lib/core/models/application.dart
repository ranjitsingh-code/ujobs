import 'job.dart';

enum ApplicationStatus {
  saved,
  applied,
  shortlisted,
  interviewing,
  offered,
  hired,
  rejected,
}

class Application {
  final int id;
  final Job job;
  final ApplicationStatus status;
  final String? coverLetter;
  final String? resume; // URL
  final DateTime createdAt;

  Application({
    required this.id,
    required this.job,
    this.status = ApplicationStatus.applied,
    this.coverLetter,
    this.resume,
    required this.createdAt,
  });

  Application copyWith({
    int? id,
    Job? job,
    ApplicationStatus? status,
    String? coverLetter,
    String? resume,
    DateTime? createdAt,
  }) {
    return Application(
      id: id ?? this.id,
      job: job ?? this.job,
      status: status ?? this.status,
      coverLetter: coverLetter ?? this.coverLetter,
      resume: resume ?? this.resume,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Application.fromJson(Map<String, dynamic> json) {
    dynamic jobDataRaw = json['jobs'] ?? json['job'];
    if (jobDataRaw is List) {
      jobDataRaw = jobDataRaw.isNotEmpty ? jobDataRaw.first : {};
    }
    
    // Merge root properties into jobData just in case the API flattens 
    // some job fields (like applicants_count, posted_at, employment_type) into the root application object.
    Map<String, dynamic> jobData = Map<String, dynamic>.from(jobDataRaw ?? {});
    json.forEach((key, value) {
      if (!jobData.containsKey(key) && value != null && key != 'id' && key != 'jobs' && key != 'job' && key != 'created_at') {
        jobData[key] = value;
      }
    });

    return Application(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      job: Job.fromJson(jobData),
      status: _parseStatus(json['stage'] ?? json['status']),
      coverLetter: json['cover_letter'] as String?,
      resume: json['resume'] as String?,
      createdAt: DateTime.tryParse(json['applied_at'] ?? json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  static ApplicationStatus _parseStatus(String? status) {
    switch (status) {
      case 'shortlisted':
        return ApplicationStatus.shortlisted;
      case 'interview':
      case 'interviewing':
        return ApplicationStatus.interviewing;
      case 'offered':
        return ApplicationStatus.offered;
      case 'hired':
        return ApplicationStatus.hired;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'saved':
        return ApplicationStatus.saved;
      default:
        return ApplicationStatus.applied;
    }
  }
}
