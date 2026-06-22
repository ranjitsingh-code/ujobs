import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/application.dart';
import '../../../core/models/job.dart';
import '../../employer/jobs/employer_job_provider.dart';

final seekerApplicationsProvider =
    FutureProvider.family<List<Application>, String?>((ref, status) async {
      // Wait a bit to simulate network
      await Future.delayed(const Duration(milliseconds: 500));

      final jobs = ref.watch(demoEmployerJobsProvider);

      // Create mock applications
      final mockApps = [
        Application(
          id: 1,
          job: jobs.first,
          status: ApplicationStatus.applied,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        if (jobs.length > 1)
          Application(
            id: 2,
            job: jobs[1],
            status: ApplicationStatus.applied,
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        if (jobs.length > 2)
          Application(
            id: 3,
            job: jobs[2],
            status: ApplicationStatus.rejected,
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
      ];

      return mockApps;
    });
