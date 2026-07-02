import 'package:flutter_test/flutter_test.dart';
import 'package:ujobs_app/core/models/application.dart';

Map<String, dynamic> _minimalApp({
  String stage = 'applied',
  Map<String, dynamic>? job,
}) =>
    {
      'id': '10',
      'stage': stage,
      'applied_at': '2025-03-01T08:00:00.000Z',
      'job': job ??
          {
            'id': '1',
            'title': 'Flutter Dev',
            'description': 'Build apps',
            'employment_type': 'full_time',
            'workplace_type': 'remote',
            'status': 'active',
          },
    };

void main() {
  group('Application.fromJson', () {
    test('parses id, status, createdAt', () {
      final app = Application.fromJson(_minimalApp());
      expect(app.id, 10);
      expect(app.status, ApplicationStatus.applied);
      expect(app.createdAt.year, 2025);
    });

    test('parses nested job', () {
      final app = Application.fromJson(_minimalApp());
      expect(app.job.title, 'Flutter Dev');
      expect(app.job.employmentType, 'full_time');
    });

    test('parses job from jobs key (array)', () {
      final json = {
        'id': '20',
        'stage': 'shortlisted',
        'applied_at': '2025-04-01T00:00:00.000Z',
        'jobs': [
          {
            'id': '2',
            'title': 'Backend Dev',
            'description': 'Build APIs',
            'employment_type': 'full_time',
            'workplace_type': 'onsite',
            'status': 'active',
          }
        ],
      };
      final app = Application.fromJson(json);
      expect(app.job.title, 'Backend Dev');
    });

    test('status mapping — all stages', () {
      final stages = {
        'shortlisted': ApplicationStatus.shortlisted,
        'interview': ApplicationStatus.interviewing,
        'interviewing': ApplicationStatus.interviewing,
        'offered': ApplicationStatus.offered,
        'hired': ApplicationStatus.hired,
        'rejected': ApplicationStatus.rejected,
        'saved': ApplicationStatus.saved,
        'applied': ApplicationStatus.applied,
        'unknown': ApplicationStatus.applied,
      };
      for (final entry in stages.entries) {
        final app = Application.fromJson(_minimalApp(stage: entry.key));
        expect(app.status, entry.value, reason: 'stage: ${entry.key}');
      }
    });

    test('parses cover_letter', () {
      final json = {
        ..._minimalApp(),
        'cover_letter': 'I am a great fit.',
      };
      expect(Application.fromJson(json).coverLetter, 'I am a great fit.');
    });

    test('fallback createdAt to now when date missing', () {
      final json = {
        'id': '5',
        'stage': 'applied',
        'job': {
          'id': '1',
          'title': 'Test',
          'description': '',
          'employment_type': 'full_time',
          'workplace_type': 'remote',
          'status': 'active',
        },
      };
      final app = Application.fromJson(json);
      expect(app.createdAt, isNotNull);
    });

    test('copyWith preserves unchanged fields', () {
      final app = Application.fromJson(_minimalApp());
      final copy = app.copyWith(status: ApplicationStatus.hired);
      expect(copy.status, ApplicationStatus.hired);
      expect(copy.id, app.id);
      expect(copy.job.title, app.job.title);
    });
  });
}
