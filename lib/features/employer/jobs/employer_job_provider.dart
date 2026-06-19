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
          id: 101,
          title: 'Senior Flutter Developer',
          description:
              'Build and maintain polished mobile experiences using Flutter and Dart.',
          employmentType: 'full_time',
          workplaceType: 'remote',
          location: 'Dhaka, Bangladesh',
          salaryMin: '90000',
          salaryMax: '140000',
          status: JobStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Job(
          id: 102,
          title: 'Product Designer',
          description:
              'Design accessible product flows for candidates and hiring teams.',
          employmentType: 'full_time',
          workplaceType: 'hybrid',
          location: 'Dhaka, Bangladesh',
          status: JobStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Job(
          id: 103,
          title: 'Backend Engineer',
          description:
              'Develop reliable APIs and services for the UJobs platform.',
          employmentType: 'contract',
          workplaceType: 'onsite',
          location: 'Chattogram, Bangladesh',
          status: JobStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Job(
          id: 104,
          title: 'Growth Marketing Specialist',
          description:
              'Plan and execute measurable acquisition campaigns across digital channels.',
          employmentType: 'full_time',
          workplaceType: 'hybrid',
          location: 'Dhaka, Bangladesh',
          status: JobStatus.draft,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ]);

  Job addFromForm(Map<String, dynamic> data) {
    final job = Job(
      id: DateTime.now().millisecondsSinceEpoch,
      title: data['title'] as String,
      description: data['description'] as String,
      employmentType: data['employment_type'] as String? ?? 'full_time',
      workplaceType: data['workplace_type'] as String? ?? 'onsite',
      location: data['city'] as String?,
      salaryMin: data['salary_min'] as String?,
      salaryMax: data['salary_max'] as String?,
      status: JobStatus.pending,
      createdAt: DateTime.now(),
    );
    state = [job, ...state];
    return job;
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
