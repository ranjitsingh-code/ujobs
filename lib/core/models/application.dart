import 'job.dart';

enum ApplicationStatus { applied, reviewing, shortlisting, rejected, accepted }

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

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] as int,
      job: Job.fromJson(json['job']),
      status: _parseStatus(json['status'] as String?),
      coverLetter: json['cover_letter'] as String?,
      resume: json['resume'] as String?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static ApplicationStatus _parseStatus(String? status) {
    switch (status) {
      case 'reviewing': return ApplicationStatus.reviewing;
      case 'shortlisting': return ApplicationStatus.shortlisting;
      case 'rejected': return ApplicationStatus.rejected;
      case 'accepted': return ApplicationStatus.accepted;
      default: return ApplicationStatus.applied;
    }
  }
}
