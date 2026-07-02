import 'package:flutter_test/flutter_test.dart';
import 'package:ujobs_app/core/models/job.dart';

Map<String, dynamic> _minimalJob({
  String id = '1',
  String title = 'Flutter Dev',
  String employmentType = 'full_time',
  String workplaceType = 'remote',
  String status = 'active',
}) =>
    {
      'id': id,
      'title': title,
      'description': 'Build apps',
      'employment_type': employmentType,
      'workplace_type': workplaceType,
      'status': status,
    };

void main() {
  group('Job.fromJson', () {
    test('parses required fields', () {
      final job = Job.fromJson(_minimalJob());
      expect(job.id, 1);
      expect(job.title, 'Flutter Dev');
      expect(job.employmentType, 'full_time');
      expect(job.workplaceType, 'remote');
    });

    test('parses status correctly', () {
      expect(Job.fromJson(_minimalJob(status: 'active')).status, JobStatus.active);
      expect(Job.fromJson(_minimalJob(status: 'paused')).status, JobStatus.paused);
      expect(Job.fromJson(_minimalJob(status: 'closed')).status, JobStatus.closed);
      expect(Job.fromJson(_minimalJob(status: 'draft')).status, JobStatus.draft);
      expect(Job.fromJson(_minimalJob(status: 'rejected')).status, JobStatus.rejected);
      expect(Job.fromJson(_minimalJob(status: 'unknown')).status, JobStatus.pending);
    });

    test('defaults isApplied and isSaved to false', () {
      final job = Job.fromJson(_minimalJob());
      expect(job.isApplied, false);
      expect(job.isSaved, false);
    });

    test('parses isSaved and isApplied flags', () {
      final job = Job.fromJson({
        ..._minimalJob(),
        'is_saved': true,
        'is_applied': true,
        'application_id': '99',
        'application_status': 'shortlisted',
      });
      expect(job.isSaved, true);
      expect(job.isApplied, true);
      expect(job.applicationId, '99');
      expect(job.applicationStatus, 'shortlisted');
    });

    test('parses salary fields', () {
      final job = Job.fromJson({
        ..._minimalJob(),
        'salary_min': '30000',
        'salary_max': '50000',
        'salary_currency': 'GBP',
        'salary_period': 'yearly',
      });
      expect(job.salaryMin, '30000');
      expect(job.salaryMax, '50000');
      expect(job.salaryCurrency, 'GBP');
      expect(job.salaryPeriod, 'yearly');
    });

    test('parses preferred_skills as JSON string', () {
      final job = Job.fromJson({
        ..._minimalJob(),
        'preferred_skills': '["Dart","Flutter","Riverpod"]',
      });
      expect(job.preferredSkills, ['Dart', 'Flutter', 'Riverpod']);
    });

    test('parses preferred_skills as List', () {
      final job = Job.fromJson({
        ..._minimalJob(),
        'preferred_skills': ['Dart', 'Flutter'],
      });
      expect(job.preferredSkills, ['Dart', 'Flutter']);
    });

    test('parses preferred_skills as comma-separated string', () {
      final job = Job.fromJson({
        ..._minimalJob(),
        'preferred_skills': 'Dart, Flutter, Riverpod',
      });
      expect(job.preferredSkills, ['Dart', 'Flutter', 'Riverpod']);
    });

    test('parses applicant count from _count.applications', () {
      final job = Job.fromJson({
        ..._minimalJob(),
        '_count': {'applications': 42},
      });
      expect(job.applicantCount, 42);
    });

    test('parses applicant count from applicants_count', () {
      final job = Job.fromJson({
        ..._minimalJob(),
        'applicants_count': 10,
      });
      expect(job.applicantCount, 10);
    });

    test('parses createdAt from posted_at', () {
      final job = Job.fromJson({
        ..._minimalJob(),
        'posted_at': '2025-01-15T10:00:00.000Z',
      });
      expect(job.createdAt, isNotNull);
      expect(job.createdAt!.year, 2025);
    });

    test('uses city as fallback for location', () {
      final job = Job.fromJson({..._minimalJob(), 'city': 'London'});
      expect(job.location, 'London');
    });

    test('handles null optional fields gracefully', () {
      final job = Job.fromJson(_minimalJob());
      expect(job.salaryMin, isNull);
      expect(job.company, isNull);
      expect(job.preferredSkills, isNull);
      expect(job.screeningQuestions, isNull);
    });

    test('handles id as string or int', () {
      expect(Job.fromJson({..._minimalJob(), 'id': 5}).id, 5);
      expect(Job.fromJson({..._minimalJob(), 'id': '5'}).id, 5);
    });

    test('parses screening questions', () {
      final job = Job.fromJson({
        ..._minimalJob(),
        'screening_questions': [
          {'id': 1, 'question': 'Years of experience?'}
        ],
      });
      expect(job.screeningQuestions!.length, 1);
      expect(job.screeningQuestions![0]['question'], 'Years of experience?');
    });
  });
}
